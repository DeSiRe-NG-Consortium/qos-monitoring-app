import 'package:connectivity_plus/connectivity_plus.dart';
//import 'package:flutter_connectivity_test/src/native/method_channel_network_details.dart';
//import 'package:flutter_connectivity_test/src/service/local_notification_service.dart';

getConnectivityInformationAndPush() async {
  final List<ConnectivityResult> connectivityResult =
      await (Connectivity().checkConnectivity());

  // This condition is for demo purposes only to explain every connection type.
  // Use conditions which work for your requirements.
  if (connectivityResult.contains(ConnectivityResult.mobile)) {
    // get information
    //String type = await NetworkInfoDetail().getNetworkDetail('com.example.network.type', 'getNetworkType');
    //String strength = await NetworkInfoDetail().getNetworkDetail('com.example.network.strength', 'getNetworkStrength');
    // Mobile network available.
    /*
    NotificationService().showLocalNotification(
                          id: 1, 
                          title: 'Network State', 
                          body: 'Mobile network available\nType: $type\nStrength: $strength', 
                          payload: ''
                        );
    */
  } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
    // Wi-fi is available.
    // Note for Android:
    // When both mobile and Wi-Fi are turned on system will return Wi-Fi only as active network type
    /*
    NotificationService().showLocalNotification(
                          id: 2, 
                          title: 'Network State', 
                          body: 'Wi-fi is available', 
                          payload: ''
                        );
    */
  } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
    // Ethernet connection available.
    /*
    NotificationService().showLocalNotification(
                          id: 3, 
                          title: 'Network State', 
                          body: 'Ethernet connection available', 
                          payload: ''
                        );
    */
  } else if (connectivityResult.contains(ConnectivityResult.vpn)) {
    // Vpn connection active.
    // Note for iOS and macOS:
    // There is no separate network interface type for [vpn].
    // It returns [other] on any device (also simulator)
    /*
    NotificationService().showLocalNotification(
                          id: 4, 
                          title: 'Network State', 
                          body: 'Vpn connection active', 
                          payload: ''
                        );
    */
  } else if (connectivityResult.contains(ConnectivityResult.bluetooth)) {
    // Bluetooth connection available.
    /*
    NotificationService().showLocalNotification(
                          id: 5, 
                          title: 'Network State', 
                          body: 'Vpn connection active', 
                          payload: ''
                        );
    */
  } else if (connectivityResult.contains(ConnectivityResult.other)) {
    // Connected to a network which is not in the above mentioned networks.
    /*
    NotificationService().showLocalNotification(
                          id: 6, 
                          title: 'Network State', 
                          body: 'Other connection active', 
                          payload: ''
                        );
    */
  } else if (connectivityResult.contains(ConnectivityResult.none)) {
    // No available network types
    /*
    NotificationService().showLocalNotification(
                          id: 7, 
                          title: 'Network State', 
                          body: 'No connection active', 
                          payload: ''
                        );
    */
  }
}
