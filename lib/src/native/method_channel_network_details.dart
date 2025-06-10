import 'package:flutter/services.dart';

class NetworkInfoDetail {
  static List<int> networkStrengthHistory = [];

  getNetworkDetail(String methodChannel, String invokeMethod) async {
    var platform = MethodChannel(methodChannel);
    try {
      final String networkType = await platform.invokeMethod(invokeMethod);
      return networkType;
    } catch (e) {
      return 'NetworkInfoDetail Error $e';
    }
  }

  getNetworkStrengthDetail(String methodChannel, String invokeMethod) async {
    var platform = MethodChannel(methodChannel);
    try {
      Map<Object?, Object?> networkStrength =
          await platform.invokeMethod(invokeMethod);
      return networkStrength;
    } catch (e) {
      return {'NAME': "unknown", 'RSRP': -0, 'RSRQ': -0, 'SINR': 0};
    }
  }

/*
  static Future<bool> bindToMobileNetwork(String methodChannel, String invokeMethod) async {
    var platform = MethodChannel(methodChannel);
    try {
      final bool result = await platform.invokeMethod(invokeMethod);
      print('Bindung an mobile Daten erfolgreich: $result');
      return result;
    } catch (e) {
      print('Fehler bei der Bindung: $e');
      return false;
    }
  }
*/

}
