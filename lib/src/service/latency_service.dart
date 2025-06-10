import 'package:dart_ping/dart_ping.dart';
//import 'package:dart_ping_ios/dart_ping_ios.dart';
import 'package:flutter_connectivity_test/main.dart';
import 'package:flutter_connectivity_test/src/native/method_channel_network_details.dart';
import 'package:flutter_connectivity_test/src/models/latency_info.dart';
import 'package:mrx_charts/mrx_charts.dart';

class LatencyInfos {
  LatencyInfos._();

  static final LatencyInfos _instance = LatencyInfos._();

  factory LatencyInfos() {
    return _instance;
  }

  String _networkLatency = '';
  String _networkJitter = '';

  final List<int?> _pingLog = [];
  final List<int?> _jitterLog = [];

  List<ChartLineDataItem> getChartData(index) {
    int x = 0;
    List<ChartLineDataItem> items = [];
    switch (index) {
      case 1:
        for (int? item in NetworkInfoDetail.networkStrengthHistory) {
          items
              .add(ChartLineDataItem(value: item!.toDouble(), x: x.toDouble()));
          x++;
        }
        break;
      case 2:
        for (int? item in _pingLog) {
          items
              .add(ChartLineDataItem(value: item!.toDouble(), x: x.toDouble()));
          x++;
        }
        break;
      case 3:
        for (int? item in _jitterLog) {
          items
              .add(ChartLineDataItem(value: item!.toDouble(), x: x.toDouble()));
          x++;
        }
        break;
      default:
    }

    return items;
  }

  getLatency(isOffline) async {
    //print(isOffline);
    //if (isOffline) return LatencyInfo(latency: 'null ms', jitter: '0 ms');

    // Register DartPingIOS
    //DartPingIOS.register();
    try {
      PingData pingData =
        await Ping(urls[2] /* 'google.com' '8.8.8.8' */, count: 1).stream.first;

      // get latency from ping
      int? curLatency = pingData.response?.time?.inMilliseconds;
      _networkLatency = '$curLatency ms';
      if (curLatency != null) {
        _pingLog.add(curLatency);
      } else { _pingLog.add(0); }

      // calculate jitter (variant C)
      double value = calculateJitter(_pingLog.length > 10
          ? _pingLog.sublist(_pingLog.length - 10, _pingLog.length)
          : _pingLog);

      _networkJitter = curLatency != null ? '${value.toInt()} ms' : '- ms';
      _jitterLog.add(value.toInt());

      // return results
      return LatencyInfo(latency: _networkLatency, jitter: _networkJitter);

    } catch (e) {
      //print('ping error!');
      return LatencyInfo(latency: 'null ms', jitter: '0 ms');
    }
    
  }

  double calculateJitter(List<int?> latencies) {
    if (latencies.length < 2) return 0;
    double sum = 0;
    for (int i = 1; i < latencies.length; i++) {
      sum += (latencies[i]! - latencies[i - 1]!).abs();
    }
    return sum / (latencies.length - 1);
  }

}
