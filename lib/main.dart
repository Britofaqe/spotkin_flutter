import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:spotkin_flutter/app_core.dart';

import 'helpers/load_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setUrlStrategy(PathUrlStrategy()); // Use path URL strategy
  Map<String, dynamic> config = await loadConfig();

  setupServiceLocator(config: config);
  // await getIt.allReady(); // Wait for all async registrations
  String jobs = await loadJobs();
  runApp(MyApp(config, jobs));
}

Future<String> loadJobs() async {
  return await rootBundle.loadString('assets/sample_jobs.json');
}

class MyApp extends StatelessWidget {
  final Map<String, dynamic> config;
  final String jobs;

  MyApp(this.config, this.jobs);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Spotify Web Auth',
      theme: spotifyThemeData,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Container(
          color: Colors.black, // Match your scaffold background color
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: child!,
            ),
          ),
        );
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(
            builder: (context) => AuthScreen(config: config),
          );
        }
        // Handle Spotify callback
        if (settings.name!.startsWith('/?')) {
          final uri = Uri.parse(settings.name!);
          final code = uri.queryParameters['code'];
          final error = uri.queryParameters['error'];

          if (code != null) {
            print('Received Spotify callback with authorization code: $code');
            return MaterialPageRoute(
              builder: (context) => AuthScreen(
                config: config,
                initialAuthCode: code,
              ),
            );
          } else if (error != null) {
            print('Received Spotify callback with error: $error');
            return MaterialPageRoute(
              builder: (context) => AuthScreen(
                config: config,
                initialError: error,
              ),
            );
          }
        }
        return null;
      },
    );
  }
}

const spotifyWidgetColor = Color(0xFF121212);
final spotifyThemeData = ThemeData(
  primarySwatch: Colors.green,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: spotifyWidgetColor,
  appBarTheme: const AppBarTheme(
    backgroundColor: spotifyWidgetColor,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
        color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.green,
    textTheme: ButtonTextTheme.primary,
    // padding: const EdgeInsets.all(16.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25),
    ),
  ),
  expansionTileTheme: ExpansionTileThemeData(
    backgroundColor: spotifyWidgetColor,
    collapsedBackgroundColor: spotifyWidgetColor,
    textColor: Colors.white,
    collapsedTextColor: Colors.white,
    iconColor: Colors.white,
    collapsedIconColor: Colors.white,
    // shape: RoundedRectangleBorder(
    //   borderRadius: BorderRadius.circular(4),
    //   // side: BorderSide(color: Colors.white24),
    // ),
  ),
  textTheme: TextTheme(
    titleLarge:
        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    bodyMedium: const TextStyle(color: Colors.white70),
    // titleMedium: TextStyle(color: Colors.white54),
    labelMedium: TextStyle(color: Colors.grey[400]),
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: spotifyWidgetColor,
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: const BorderSide(color: Colors.white24),
    ),
    labelStyle: const TextStyle(color: Colors.white54),
  ),
  iconTheme: const IconThemeData(color: Colors.white),
  dividerTheme: const DividerThemeData(
    color: Colors.white10,
    thickness: 1,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(Colors.green),
      foregroundColor: MaterialStateProperty.all(Colors.white),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),
  ),
  listTileTheme: const ListTileThemeData(
    tileColor: Color(0xFF121212),
    textColor: Colors.white,
    iconColor: Colors.white54,
  ),
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.all(Colors.white),
    trackColor: MaterialStateProperty.all(Colors.green),

    // overlayColor: MaterialStateProperty.all(Colors.green),
  ),
);
