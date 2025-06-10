import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_connectivity_test/main.dart';
import 'package:flutter_connectivity_test/src/components/chartdialog.dart';
import 'package:flutter_connectivity_test/src/models/customsetting.dart';
import 'package:flutter_connectivity_test/src/models/latency_info.dart';
import 'package:flutter_connectivity_test/src/native/method_channel_network_details.dart';
import 'package:flutter_connectivity_test/src/service/latency_service.dart';
import 'package:flutter_connectivity_test/src/service/local_notification_service.dart';
import 'package:flutter_connectivity_test/src/service/settings_service.dart';

StreamSubscription? _updateSubscription;

class NetworkStats extends StatefulWidget {
  final bool downloadRunning;
  final bool uploadRunning;
  final bool isMobile;
  final bool isOffline;

  const NetworkStats(
      {super.key,
      required this.downloadRunning,
      required this.uploadRunning,
      required this.isMobile,
      required this.isOffline});

  @override
  State<NetworkStats> createState() => _NetworkStatsState();
}

class _NetworkStatsState extends State<NetworkStats>
    with SingleTickerProviderStateMixin {
  List<CustomSetting> _settings = [];

  String _networkInfo = '';
  Map<Object?, Object?> _networkStrength = {
    'NAME': "unknown",
    'RSRP': -0,
    'RSRQ': -0,
    'SINR': 0
  };
  String _networkLatency = '';
  String _networkJitter = '';

  bool showUpdateFlash = false;
  double _opacity = 1.0;
  int flashMs = 50;

  @override
  void initState() {
    super.initState();

    asyncMethod();

    //BackgroundService.initializeService();

    // Listen to updates from background service
    _updateSubscription =
        FlutterBackgroundService().on('update').listen((event) async {

      if (settingsUpdate) {

        urls = await SettingsStorage.loadUrlSettings();
        //print('new urls set: $urls');

        //print('settings updated!, reloading...');
        await loadSettings();
        settingsUpdate = false;
      }

      if (!widget.uploadRunning && !widget.downloadRunning) {
        _networkInfo = await NetworkInfoDetail()
            .getNetworkDetail('com.example.network.type', 'getNetworkType');
        //print('$_networkInfo , ${widget.isMobile}');

        _networkStrength = await NetworkInfoDetail().getNetworkStrengthDetail(
            'com.example.network.strength', 'getNetworkStrength');
        //print(_networkStrength["NAME"]);

        int rsrp = _networkStrength['RSRP'] == null ? 0 : (_networkStrength['RSRP'] as int);//.abs();
        int rsrq = _networkStrength['RSRQ'] == null ? 0 : (_networkStrength['RSRQ'] as int);//.abs();
        int sinr = _networkStrength['SINR'] == null ? 0 : (_networkStrength['SINR'] as int);//.abs();
        NetworkInfoDetail.networkStrengthHistory.add(rsrp);

        LatencyInfo latencyInfo = await LatencyInfos().getLatency(widget.isOffline);
        
        //print(latencyInfo.toString());

        _networkLatency = '${latencyInfo.latency}';
        _networkJitter = '${latencyInfo.jitter}';

        //print('isPausedOnReport: $isPausedOnReport');

        if (!isPausedOnReport) {
          for (CustomSetting setting in _settings) {
            if (setting.id == 0 &&
                setting.value >
                    //int.parse(_networkStrength.replaceAll(' dBm', '')).abs()) {
                    rsrp) {
                      //print('${setting.id} ${setting.showNotification}');
                      if (setting.showNotification) {
                        NotificationService().showLocalNotification(
                            id: 11,
                            title: 'Warning',
                            body:
                                'SS-RSRP is lower than ${setting.value} dB: $rsrp dB',
                            payload: '');
                      }
            } else if (setting.id == 1 &&
                setting.value >
                    //int.parse(_networkStrength.replaceAll(' dBm', '')).abs()) {
                    rsrq) {
                      //print('${setting.id} ${setting.showNotification}');
                      if (setting.showNotification) {
                        NotificationService().showLocalNotification(
                            id: 12,
                            title: 'Warning',
                            body:
                                'RSRQ is lower than ${setting.value} dB: $rsrq dB',
                            payload: '');
                      }
            } else if (setting.id == 2 &&
                setting.value >
                    sinr) {
                      //print('${setting.id} ${setting.showNotification}');
                      if (setting.showNotification) {
                        NotificationService().showLocalNotification(
                            id: 13,
                            title: 'Warning',
                            body:
                                'Signal to Noise Ratio is lower than ${setting.value} dB: $sinr dB',
                            payload: '');
                      }
            } else if (setting.id == 3 &&
                setting.value <
                    ((latencyInfo.latency != 'null ms')
                        ? int.parse(latencyInfo.latency!.replaceAll(' ms', ''))
                        : 0)) {
                          //print('${setting.id} ${setting.showNotification}');
                          if (setting.showNotification) {
                            NotificationService().showLocalNotification(
                                id: 14,
                                title: 'Warning',
                                body:
                                    'Latency is higher than ${setting.value} ms: ${latencyInfo.latency}',
                                payload: '');
                          }
            } else if (setting.id == 4 &&
                setting.value <
                    ((latencyInfo.jitter != '- ms')
                        ? int.parse(latencyInfo.jitter!.replaceAll(' ms', ''))
                        : 0)) {
              //print('${setting.id} ${setting.showNotification}');
              if (setting.showNotification) {
                NotificationService().showLocalNotification(
                  id: 15,
                  title: 'Warning',
                  body:
                      'Jitter is higher than ${setting.value} ms: ${latencyInfo.jitter}',
                  payload: '');
              }
            }
          }
        }

        setState(() {});

        if (showUpdateFlash) {
          setState(() {
            _opacity = 0.0;
          });
          Future.delayed(Duration(milliseconds: flashMs), () {
            setState(() {
              _opacity = 1.0;
            });
          });
        } else {
          setState(() {});
        }
      }
    });
  }

  void asyncMethod() async {
    await loadSettings();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            if (index == 1 || index == 2 || index == 3) {
              ChartDialog.show(context, index);
            }
          },
          child: GridTile(
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 166, 166, 166),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: getTopWidgetForIndex(index),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  getTopWidgetForIndex(index) {
    switch (index) {
      case 0:
        return [
          const Text(
            "Network Type",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          AnimatedOpacity(
              opacity: _opacity,
              duration: Duration(milliseconds: flashMs),
              child: Text(
                widget.isMobile ? _networkInfo : widget.isOffline ? 'OFFLINE' : 'WLAN',
                textAlign: TextAlign.center,
                textScaler: const TextScaler.linear(0.9),
                style: TextStyle(
                  fontSize: 40,
                  color: widget.isMobile && !widget.isOffline ? Colors.white : const Color.fromARGB(255, 255, 64, 0),
                  fontWeight: FontWeight.bold,
                ),
              )),
          AnimatedOpacity(
              opacity: _opacity,
              duration: Duration(milliseconds: flashMs),
              child: Text(
                _networkStrength["NAME"] != '' ? '${_networkStrength["NAME"]}' : '-',
                textAlign: TextAlign.center,
                textScaler: const TextScaler.linear(0.9),
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )),
        ];
      case 1:
        return [
          const Text(
            "Signal",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          AnimatedOpacity(
              opacity: _opacity,
              duration: Duration(milliseconds: flashMs),
              child: Text(
                (!widget.uploadRunning && !widget.downloadRunning && _networkStrength["SINR"] != null)
                    //? _networkInfo == '5G' ? '${_networkStrength["SINR"]} sinr' : '${_networkStrength["RSRQ"]} RSRQ'
                    ? _networkStrength["SINR"] == 2147483647 
                      ? _networkInfo == "5G" ? '- SINR' : '- SNR'
                      : _networkInfo == "5G" ? 'SINR ${_networkStrength["SINR"]} dB' : 'SNR ${_networkStrength["SINR"]} dB' 
                    : '-',
                textAlign: TextAlign.center,
                textScaler: const TextScaler.linear(0.9),
                style: const TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )),
          AnimatedOpacity(
              opacity: _opacity,
              duration: Duration(milliseconds: flashMs),
              child: Text(
                (!widget.uploadRunning && !widget.downloadRunning && _networkStrength["RSRP"] != null)
                    ? 'RSRP ${_networkStrength["RSRP"]} dB'
                    : 'RSRP - dB',
                textAlign: TextAlign.center,
                textScaler: const TextScaler.linear(0.9),
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )),
          AnimatedOpacity(
              opacity: _opacity,
              duration: Duration(milliseconds: flashMs),
              child: Text(
                (!widget.uploadRunning && !widget.downloadRunning && _networkStrength["RSRQ"] != null)
                    //? _networkInfo == '5G' ? '${_networkStrength["SINR"]} sinr' : '${_networkStrength["RSRQ"]} RSRQ'
                    ? 'RSRQ ${_networkStrength["RSRQ"]} dB' 
                    : 'RSRQ - dB',
                textAlign: TextAlign.center,
                textScaler: const TextScaler.linear(0.9),
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )),
        ];
      case 2:
        return [
          const Text(
            "Latency",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          AnimatedOpacity(
              opacity: _opacity,
              duration: Duration(milliseconds: flashMs),
              child: Text(
                (!widget.uploadRunning && !widget.downloadRunning && _networkLatency != 'null ms')
                    ? _networkLatency
                    : '- ms',
                textAlign: TextAlign.center,
                textScaler: const TextScaler.linear(0.9),
                style: TextStyle(
                  fontSize: 40,
                  color: widget.isMobile ? Colors.white : const Color.fromARGB(255, 255, 64, 0),
                  fontWeight: FontWeight.bold,
                ),
              )),
        ];
      case 3:
        return [
          const Text(
            "Jitter",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          AnimatedOpacity(
              opacity: _opacity,
              duration: Duration(milliseconds: flashMs),
              child: Text(
                (!widget.uploadRunning && !widget.downloadRunning && _networkJitter != '0 ms')
                    ? _networkJitter
                    : '- ms',
                textAlign: TextAlign.center,
                textScaler: const TextScaler.linear(0.9),
                style: TextStyle(
                  fontSize: 40,
                  color: widget.isMobile ? Colors.white : const Color.fromARGB(255, 255, 64, 0),
                  fontWeight: FontWeight.bold,
                ),
              )),
        ];
      default:
        return [];
    }
  }

  Future<void> loadSettings() async {
    _settings = await SettingsStorage.loadSettings();
    if (_settings.isEmpty) {
      _settings = await SettingsStorage.defaultSettings();
    }
  }

  @override
  void dispose() {
    _updateSubscription?.cancel();
    super.dispose();
  }
}
