import network
import socket
import dht
import machine
import time

# Configurações da rede Wi-Fi
ssid = 'Amanda'
password = '31367783'

station = network.WLAN(network.STA_IF)
station.active(True)
station.connect(ssid, password)

# Aguarde até que a conexão Wi-Fi esteja estabelecida
while not station.isconnected():
    pass

print('Conexão estabelecida')
print(station.ifconfig())

# Inicialize o sensor DHT11 e o LED
sensor = dht.DHT11(machine.Pin(4))
LED = machine.Pin(2, machine.Pin.OUT)

# Configure o servidor web
addr = socket.getaddrinfo('0.0.0.0', 8080)[0][-1]
server = socket.socket()
server.bind(addr)
server.listen(1)
print('Servidor ouvindo na porta 8080')

def web_page(temp, hum):
    html = """<html>
        <head>
            <title>Leitura do Sensor DHT11</title>
        </head>
        <body>
            <h1>Leitura do Sensor DHT11</h1>
            <p>Temperatura: {} &deg;C</p>
            <p>Umidade: {} %</p>
        </body>
    </html>""".format(temp, hum)
    return html

def blink_LED():
    for i in range(3):
        LED.value(not LED.value())
        time.sleep(0.5)  # Tempo reduzido para um piscar mais rápido
    LED.value(0)  # Desliga o LED após piscar

while True:
    try:
        client, addr = server.accept()
        print('Cliente conectado de', addr)
        request = client.recv(1024)
        request = str(request)
        print('Conteúdo do request =', request)
        
        # Piscar o LED ao receber uma solicitação
        blink_LED()
        
        # Leia os dados do sensor
        sensor.measure()
        temp = sensor.temperature()
        hum = sensor.humidity()
        
        # Envie a resposta ao cliente
        response = web_page(temp, hum)
        client.send('HTTP/1.1 200 OK\n')
        client.send('Content-Type: text/html\n')
        client.send('Connection: close\n\n')
        client.sendall(response)
        client.close()
        
    except OSError as e:
        client.close()
        print('Erro no cliente:', e)
