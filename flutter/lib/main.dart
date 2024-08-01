import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:async';
import 'package:shimmer/shimmer.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT - Temperatura e Umidade',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(),
        ),
      ),
      home: SensorDataPage(),
    );
  }
}

class SensorDataPage extends StatefulWidget {
  @override
  _SensorDataPageState createState() => _SensorDataPageState();
}

class _SensorDataPageState extends State<SensorDataPage> {
  List<charts.Series<SensorData, DateTime>> _temperatureSeriesData = [];
  List<charts.Series<SensorData, DateTime>> _humiditySeriesData = [];
  List<SensorData> data = [];
  bool isLoading = false;
  String errorMessage = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchData();
    _timer = Timer.periodic(Duration(seconds: 30), (Timer t) => fetchData());
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse('http://IP_GERADO_ESP32:PORTA'));

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        double temperature = jsonResponse['temperature']?.toDouble() ?? 0.0;
        double humidity = jsonResponse['humidity']?.toDouble() ?? 0.0;

        setState(() {
          data.add(SensorData(DateTime.now(), temperature, humidity));
          _temperatureSeriesData = _createTemperatureSeriesData();
          _humiditySeriesData = _createHumiditySeriesData();
        });
      } else {
        setState(() {
          errorMessage = 'Falha ao carregar dados do sensor. Status: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao carregar dados: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<charts.Series<SensorData, DateTime>> _createTemperatureSeriesData() {
    return [
      charts.Series<SensorData, DateTime>(
        id: 'Temperatura',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (SensorData sensorData, _) => sensorData.time,
        measureFn: (SensorData sensorData, _) => sensorData.temperature,
        data: data,
        labelAccessorFn: (SensorData sensorData, _) => '${sensorData.temperature} °C',
      ),
    ];
  }

  List<charts.Series<SensorData, DateTime>> _createHumiditySeriesData() {
    return [
      charts.Series<SensorData, DateTime>(
        id: 'Umidade',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (SensorData sensorData, _) => sensorData.time,
        measureFn: (SensorData sensorData, _) => sensorData.humidity,
        data: data,
        labelAccessorFn: (SensorData sensorData, _) => '${sensorData.humidity} %',
      ),
    ];
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IoT - Temperatura e Umidade'),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            if (isLoading)
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 200.0,
                      color: Colors.white,
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      height: 200.0,
                      color: Colors.white,
                    ),
                  ],
                ),
              )
            else if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: TextStyle(color: Colors.red),
              )
            else
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(
                      'Temperatura',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Expanded(
                      child: charts.TimeSeriesChart(
                        _temperatureSeriesData,
                        animate: true,
                        dateTimeFactory: const charts.LocalDateTimeFactory(),
                        defaultRenderer: charts.LineRendererConfig(includePoints: true),
                        behaviors: [
                          charts.SeriesLegend(
                            position: charts.BehaviorPosition.end,
                            cellPadding: EdgeInsets.all(4.0),
                            horizontalFirst: false,
                            showMeasures: true,
                            measureFormatter: (num? value) => value == null ? '-' : '${value.toStringAsFixed(1)} °C',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Umidade',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Expanded(
                      child: charts.TimeSeriesChart(
                        _humiditySeriesData,
                        animate: true,
                        dateTimeFactory: const charts.LocalDateTimeFactory(),
                        defaultRenderer: charts.LineRendererConfig(includePoints: true),
                        behaviors: [
                          charts.SeriesLegend(
                            position: charts.BehaviorPosition.end,
                            cellPadding: EdgeInsets.all(4.0),
                            horizontalFirst: false,
                            showMeasures: true,
                            measureFormatter: (num? value) => value == null ? '-' : '${value.toStringAsFixed(1)} %',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SensorData {
  final DateTime time;
  final double temperature;
  final double humidity;

  SensorData(this.time, this.temperature, this.humidity);
}
