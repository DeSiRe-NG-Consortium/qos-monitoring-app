import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_connectivity_test/main.dart';
import 'package:flutter_connectivity_test/src/home_view.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/splash';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController animController;

  @override
  void initState() {
    super.initState();

    animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));

    // Navigate to the main screen after a delay
    Timer(const Duration(seconds: splashscreenTime), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeView()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Center(
                child: Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.6),
                    child: RotationTransition(
                        turns: const AlwaysStoppedAnimation(15 / 360),
                        child:
                            //SpinKitFadingCube(
                            SpinKitCubeGrid(
                          color: Colors.red.withAlpha(212),
                          size: 96.0,
                          controller: animController,
                        )))),
            Center(
              child: Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height * 0.2),
                  child: Image.asset(
                    'assets/images/logo_full2.png',
                    width: 320,
                    height: 320,
                  )),
            ),
          ],
        ));
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }
}
