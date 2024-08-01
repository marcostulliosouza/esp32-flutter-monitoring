# esp32-flutter-monitoring
![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)

![Aplicação](https://github.com/user-attachments/assets/df9a43de-3f0c-4d4b-bef2-315e4feeb0c8)
![Circuito Sketch](https://github.com/user-attachments/assets/26b14785-6995-47fd-84c5-bdf8a0bba473)


Este repositório contém dois projetos distintos para um sistema IoT que monitora e exibe dados de temperatura e umidade usando um ESP32 e um aplicativo Flutter.

## Estrutura do Repositório

O repositório está dividido em duas pastas principais:

- **`esp32/`**: Contém o código MicroPython para o ESP32, que coleta dados de um sensor DHT11 e os disponibiliza via HTTP.
- **`flutter/`**: Contém o aplicativo Flutter que consome os dados do ESP32 e apresenta gráficos de temperatura e umidade.

## Estrutura de Pastas


esp32-flutter-monitoring/
├── esp32/
│ └── main.py # Código MicroPython para o ESP32
└── flutter/
├── android/ # Configurações específicas do Android
├── ios/ # Configurações específicas do iOS
├── lib/
│ └── main.dart # Código principal do aplicativo Flutter
├── pubspec.yaml # Arquivo de configuração do Flutter
└── ... # Outros arquivos e pastas do Flutter

## Configuração do ESP32

1. **Conexão Wi-Fi**:
   - O código MicroPython do ESP32 se conecta à rede Wi-Fi especificada pelas variáveis `ssid` e `password`.

2. **Leitura do Sensor**:
   - O código lê dados de um sensor DHT11 conectado ao pino 4 do ESP32 e usa um LED integrado para indicar a atividade.

3. **Servidor Web**:
   - Um servidor HTTP é configurado para ouvir na porta 8080 e fornecer dados JSON com a temperatura e a umidade lidas.

### Código MicroPython

O código do ESP32 pode ser encontrado em `esp32/main.py`. Certifique-se de ajustar as configurações de rede conforme necessário.

## Configuração do Aplicativo Flutter

1. **Dependências**:
   - O projeto Flutter usa pacotes para geolocalização, gráficos e solicitação HTTP. As dependências estão listadas no arquivo `pubspec.yaml`.

2. **Permissões**:
   - Certifique-se de adicionar as permissões necessárias para acesso à localização e à internet no arquivo `AndroidManifest.xml` e `Info.plist` para Android e iOS, respectivamente.

3. **Atualização de Dados**:
   - O aplicativo consome dados do ESP32 a cada 30 segundos e os exibe em gráficos de temperatura e umidade.

### Execução do Projeto Flutter

1. **Instale as Dependências**:
   ```sh
   flutter pub get
2. **Execute o Aplicativo**:
   ```sh
   flutter run
3. **Configuração do Emulador**:
   - Certifique-se de que o emulador Android/IOS esteja configurado corretamento para visualizar o aplicativo.

## Licença

Este projeto está licenciado sob a MIT License.

## Contribuições

Contribuições são bem-vindas! Por favor, abra um `issue` ou envie um `pull request` se tiver sugestões ou correções.
