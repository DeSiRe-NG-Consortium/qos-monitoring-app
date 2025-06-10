import 'package:flutter/material.dart';
import 'package:flutter_connectivity_test/src/models/customsetting.dart';
import 'package:flutter_connectivity_test/src/service/settings_service.dart';
import 'package:flutter_speed_test_plus/flutter_speed_test_plus.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../service/local_notification_service.dart';

class SpeedTest extends StatefulWidget {
  final Function setDLRunning;
  final Function setULRunning;
  final bool isOffline;

  const SpeedTest(
      {super.key, required this.setDLRunning, required this.setULRunning, required this.isOffline});

  @override
  State<SpeedTest> createState() => _SpeedTestState();
}

class _SpeedTestState extends State<SpeedTest>
    with SingleTickerProviderStateMixin {
  late AnimationController animControllerChart;

  final speedTest = FlutterInternetSpeedTest();
  bool downloadRunning = false;
  bool uploadRunning = false;

  double downloadProgress = 0.0;
  double uploadProgress = 0.0;

  List<CustomSetting> settings = [];

  String downloadSpeed = "-";
  String uploadSpeed = "-";

  @override
  void initState() {
    super.initState();

    animControllerChart = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 200,
            height: 188,
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
              ),
              itemCount: 2,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {},
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
                          children: getBottomWidgetForIndex(index),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
              padding: EdgeInsets.only(top: 0, left: 96, right: 96),
              child: ElevatedButton(
                style: ButtonStyle(
                  shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  elevation: const WidgetStatePropertyAll<double>(3.0),
                  backgroundColor:
                      WidgetStatePropertyAll<Color>(/*widget.isOffline ? Colors.grey :*/ Colors.red),
                ),
                onPressed: () async {
                  /*widget.isOffline ? 
                    DialogService.showSnackbar(context, 'No Internet connection established')
                  :*/
                  !downloadRunning && !uploadRunning
                    ? startSpeedTest()
                    : cancelSpeedTest();
                },
                child: Text(
                  (uploadRunning || downloadRunning) ? 'CANCEL' : 'SPEEDTEST',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  getBottomWidgetForIndex(index) {
    switch (index) {
      case 0:
        return [
          const Text(
            "Download",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          !downloadRunning
              ? Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12),
                  child: Text(
                    downloadSpeed,
                    textAlign: TextAlign.center,
                    textScaler: const TextScaler.linear(0.9),
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )) //)
              : Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SpinKitDualRing(
                    //SpinKitSpinningLines(
                    color: Colors.red,
                    size: 52.0,
                    lineWidth: 2,
                    //itemCount: 5,
                    controller: animControllerChart,
                  )),
          if (downloadRunning)
            Text(
              '${downloadProgress.toStringAsFixed(0)}%',
              textAlign: TextAlign.center,
              textScaler: const TextScaler.linear(0.9),
              style: const TextStyle(
                fontSize: 40,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
        ];
      case 1:
        return [
          const Text(
            "Upload",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          !uploadRunning
              ? Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12),
                  child: Text(
                    uploadSpeed,
                    textAlign: TextAlign.center,
                    textScaler: const TextScaler.linear(0.9),
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )) //)
              : Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SpinKitDualRing(
                    //SpinKitSpinningLines(
                    color: Colors.red,
                    size: 52.0,
                    lineWidth: 2,
                    //itemCount: 5,
                    controller: animControllerChart,
                  )),
          if (uploadRunning)
            Text(
              '${uploadProgress.toStringAsFixed(0)}%',
              textAlign: TextAlign.center,
              textScaler: const TextScaler.linear(0.9),
              style: const TextStyle(
                fontSize: 40,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
        ];

      default:
        return [];
    }
  }

  void startSpeedTest() async {
    uploadProgress = 0.0;
    downloadProgress = 0.0;

    List<String> urls = await SettingsStorage.loadUrlSettings();
    //print('selected download server: ${urls[0] == '' ? SettingsStorage.defaultUrls[0] : urls[0]}');
    //print('selected upload server: ${urls[1] == '' ? SettingsStorage.defaultUrls[1] : urls[1]}');

    speedTest.startTesting(
      //useFastApi: true, 
      // Use custom server instead of Fast.com
      downloadTestServer: urls[0], //'http://speedtest.serverius.net', // Custom download server URL
      uploadTestServer: urls[1], //'http://nl.iperf.014.fr', // Custom upload server URL
      fileSizeInBytes: 1024000, // File size in MB for testing (default is 10MB)
      onStarted: () {
        //print('Speed test started');
        downloadRunning = true;
        uploadRunning = false;

        widget.setDLRunning(downloadRunning);
        widget.setULRunning(uploadRunning);
      },
      onCompleted: (TestResult download, TestResult upload) {
        //print('Download Speed: ${download.transferRate} Mbps');
        //print('Upload Speed: ${upload.transferRate} Mbps');

        for (CustomSetting setting in settings) {
          if (setting.id == 4 && setting.value > download.transferRate) {
            NotificationService().showLocalNotification(
                id: 15,
                title: 'Download (mbit/s) Warning',
                body:
                    'Download (mbit/s) is lower than ${setting.value} mbit/s\n\n${download.transferRate} mbit/s',
                payload: '');
          } else if (setting.id == 5 && setting.value > upload.transferRate) {
            NotificationService().showLocalNotification(
                id: 16,
                title: 'Upload (mbit/s) Warning',
                body:
                    'Upload (mbit/s) is lower than ${setting.value} mbit/s\n\n${upload.transferRate} mbit/s',
                payload: '');
          }
        }
      },
      onProgress: (double percent, TestResult data) {
        //print('Progress: $percent%');
        if (data.type == TestType.download) {
          downloadProgress = percent;
        } else {
          uploadProgress = percent;
        }
        setState(() {});
      },
      onError: (String errorMessage, String speedTestError) {
        //print('Error: $errorMessage');
        downloadRunning = false;
        uploadRunning = false;

        widget.setDLRunning(downloadRunning);
        widget.setULRunning(uploadRunning);

        setState(() {});
      },
      onDownloadComplete: (TestResult data) {
        //print('Download complete: ${data.transferRate} Mbps');
        downloadSpeed = '${data.transferRate.toStringAsFixed(1)} Mbps';
        downloadRunning = false;
        uploadRunning = true;

        widget.setDLRunning(downloadRunning);
        widget.setULRunning(uploadRunning);

        setState(() {});
      },
      onUploadComplete: (TestResult data) {
        //print('Upload complete: ${data.transferRate} Mbps');
        uploadSpeed = '${data.transferRate.toStringAsFixed(1)} Mbps';
        uploadRunning = false;

        widget.setDLRunning(downloadRunning);
        widget.setULRunning(uploadRunning);

        setState(() {});
      },
      onCancel: () {
        //print('Test cancelled');
        downloadRunning = false;
        uploadRunning = false;

        widget.setDLRunning(downloadRunning);
        widget.setULRunning(uploadRunning);

        setState(() {});
      },
    );
  }

  void cancelSpeedTest() {
    speedTest.cancelTest();
  }

  @override
  void dispose() {
    animControllerChart.dispose();
    super.dispose();
  }
}
