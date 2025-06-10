import 'package:flutter/material.dart';
import 'package:flutter_connectivity_test/src/home_view.dart';
import 'package:flutter_connectivity_test/src/settings_view.dart';
import 'package:flutter_connectivity_test/src/splash_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Providing a restorationScopeId allows the Navigator built by the
      // MaterialApp to restore the navigation stack when a user leaves and
      // returns to the app after it has been killed while running in the
      // background.
      restorationScopeId: 'app',

      navigatorKey: MyApp.navigatorKey, // GlobalKey()
      
      // Provide the generated AppLocalizations to the MaterialApp. This
      // allows descendant Widgets to display the correct translations
      // depending on the user's locale.
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English, no country code
      ],

      // Use AppLocalizations to configure the correct application title
      // depending on the user's locale.
      //
      // The appTitle is defined in .arb files found in the localization
      // directory.
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context)!.appTitle,

      //theme: ThemeData.light(),

      theme: ThemeData.dark().copyWith(
        textSelectionTheme: Theme.of(context).textSelectionTheme.copyWith(
          cursorColor: Colors.white70,
          selectionColor: Colors.white70,
          selectionHandleColor: Colors.white70,
        ),
      ),
    
      //darkTheme: ThemeData.dark()

      darkTheme: ThemeData.dark().copyWith(
        textSelectionTheme: Theme.of(context).textSelectionTheme.copyWith(
          cursorColor: Colors.white70,
          selectionColor: Colors.white70,
          selectionHandleColor: Colors.white70,
        ),
      ),

      // Define a function to handle named routes in order to support
      // Flutter web url navigation and deep linking.
      onGenerateRoute: (RouteSettings routeSettings) {
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (BuildContext context) {
            switch (routeSettings.name) {
              case SplashScreen.routeName:
                return const SplashScreen();
              case HomeView.routeName:
                return const HomeView();
              case SettingsView.routeName:
                return const SettingsView();
               
              default:
                return const SplashScreen();
            }
          },
        );
      },
    );
  }
}
