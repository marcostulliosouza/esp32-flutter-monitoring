import network
import socket
import dht
import machine
import time
import ujson as json  # JSON no MicroPython

# Configurações da rede Wi-Fi
ssid = 'SUA_REDE_WIFI'
password = 'SUA_SENHA'

station = network.WLAN(network.STA_IF)
station.active(True)
station.connect(ssid, password)

# Aguarda até que a conexão Wi-Fi esteja estabelecida
while not station.isconnected():
    pass

print('Conexão estabelecida')
print(station.ifconfig())

# Inicializa o sensor DHT11 e o LED
sensor = dht.DHT11(machine.Pin(4))
LED = machine.Pin(2, machine.Pin.OUT)

# Configura o servidor web
addr = socket.getaddrinfo('0.0.0.0', 8080)[0][-1]
server = socket.socket()
server.bind(addr)
server.listen(1)
print('Servidor ouvindo na porta 8080')

def json_response(temp, hum):
    data = {
        'temperature': float(temp),
        'humidity': float(hum)
    }
    return json.dumps(data)

def blink_LED():
    for i in range(3):
        LED.value(not LED.value())
        time.sleep(0.5) 
    LED.value(0)  # Desliga o LED

while True:
    try:
        client, addr = server.accept()
        print('Cliente conectado de', addr)
        request = client.recv(1024)
        request = str(request)
        print('Conteúdo do request =', request)
        
        # Pisca o LED ao receber uma solicitação
        blink_LED()
        
        # Ler os dados do sensor
        sensor.measure()
        temp = sensor.temperature()
        hum = sensor.humidity()
        
        # Enva a resposta ao cli
        response = json_response(temp, hum)
        client.send('HTTP/1.1 200 OK\n')
        client.send('Content-Type: application/json\n')  # Definindo o tipo de conteúdo como JSON
        client.send('Connection: close\n\n')
        client.sendall(response)
        client.close()
        
    except OSError as e:
        client.close()
        print('Erro no cliente:', e)

