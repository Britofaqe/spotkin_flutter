import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setUrlStrategy(PathUrlStrategy()); // Use path URL strategy
  Map<String, dynamic> config = await loadConfig();
  String jobs = await loadJobs();
  runApp(MyApp(config, jobs));
}

Future<Map<String, dynamic>> loadConfig() async {
  String configString = await rootBundle.loadString('assets/config.json');
  // print('Loaded config: $configString');
  Map<String, dynamic> config = jsonDecode(configString);
  return config;
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
      theme: ThemeData(primarySwatch: Colors.blue),
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(
            builder: (context) => HomeScreen(config: config, jobs: jobs),
          );
        }
        // Handle Spotify callback
        if (settings.name!.startsWith('/?code=')) {
          final uri = Uri.parse(settings.name!);
          final code = uri.queryParameters['code'];
          return MaterialPageRoute(
            builder: (context) => HomeScreen(
              config: config,
              jobs: jobs,
              initialAuthCode: code,
            ),
          );
        }
        return null;
      },
    );
  }
}
