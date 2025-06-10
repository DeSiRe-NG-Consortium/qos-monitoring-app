import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_connectivity_test/main.dart';
import 'package:flutter_connectivity_test/src/components/networkstats.dart';
import 'package:flutter_connectivity_test/src/components/speedtest.dart';
import 'package:flutter_connectivity_test/src/settings_view.dart';

StreamSubscription<List<ConnectivityResult>>? subscription;

class HomeView extends StatefulWidget {
  static const routeName = '/home';

  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  bool uploadRunning = false;
  bool downloadRunning = false;

  bool isMobile = false;
  bool isOffline = false;

  //bool hasBind = false;
  
  @override
  void initState() {
    super.initState();

    asyncMethod();

    //BackgroundService.initializeService();

    // Received changes in available connectivity types!
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> connectivityResult) async {

      isMobile =
          connectivityResult.contains(ConnectivityResult.mobile) ? true : false;

      try {
        final result = await InternetAddress.lookup('www.google.com').timeout(Duration(seconds: 2));
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          isOffline = false;
        }
      } on Exception catch (_) {
        isOffline = true;
      }

      /*
      connectivityResult.contains(ConnectivityResult.none) ? true : false;
      */

      setState(() {
        
      });
      //getConnectivityInformationAndPush();
    });
  }

  void asyncMethod() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (willPop, result) async {
          await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('App wirklich schließen?',
                  style: TextStyle(color: Colors.white)),
              content: const Text('Möchtest du die App wirklich verlassen?',
                  style: TextStyle(color: Colors.white)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Abbrechen',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await notificationService?.cancelAllNotifications();
                    if (!context.mounted) {
                      return;
                    }
                    Navigator.of(context).pop(true);
                    exit(0);
                  },
                  child: const Text(
                    'Ja, beenden',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 189, 189, 189),
          body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              SizedBox(
                  height: MediaQuery.of(context).size.height * 0.16,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Spacer(),
                        Image.asset(width: 280, 'assets/images/logo_half2.png'),
                        const Spacer(
                          flex: 2,
                        ),
                        IconButton(
                            onPressed: () async {

                              //openWiFiSettings();
                              
                              /* */
                              Navigator.restorablePushNamed(
                                context,
                                SettingsView.routeName,
                              );
                              

/*
                              //String iperfPath = "/data/local/tmp/iperf3.18";
                              String iperfPath = "/data/data/com.example.flutter_connectivity_test/files/iperf3.18";
                              var result = await Process.run("chmod", ["777", iperfPath]);
                              print("stdout: ${result.stdout}");
                              print("stderr: ${result.stderr}");

                              //Process.run('/data/local/tmp/iperf3.18', ['-c', '192.168.0.170']).then((result) {
                              Process.run('/data/data/com.example.flutter_connectivity_test/files/iperf3.18', ['-c', '192.168.0.170']).then((result) {
                                print(result.stdout);
                                print(result.stderr);
                              });
*/

/*
                              if (!hasBind) {
                                print('try binding network to mobile...');
                                hasBind = await NetworkInfoDetail.bindToMobileNetwork(
                                          'com.example.network.bind', 'bindToMobileNetwork');
                              } else {
                                print('unbinding network...');
                                hasBind = await NetworkInfoDetail.bindToMobileNetwork(
                                          'com.example.network.bind', 'unbindToMobileNetwork');
                              }
*/    

                            },
                            icon: const Icon(Icons.settings,
                                color: Colors.black, size: 32)),
                        const Spacer(),
                      ])),
                      
              SizedBox(
                  height: MediaQuery.of(context).size.height * 0.47,
                  width: MediaQuery.of(context).size.width,
                  child: NetworkStats(
                    downloadRunning: downloadRunning,
                    uploadRunning: uploadRunning,
                    isMobile: isMobile,
                    isOffline: isOffline,)),
              SizedBox(
                  height: MediaQuery.of(context).size.height * 0.40,
                  width: MediaQuery.of(context).size.width,
                  child: SpeedTest(
                    setDLRunning: setDLRunning, setULRunning: setULRunning, isOffline: isOffline,)),
            ],
          ))),
        ));
  }

  setDLRunning(value) {
    setState(() {
      downloadRunning = value;
    });
  }

  setULRunning(value) {
    setState(() {
      uploadRunning = value;
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }
}
