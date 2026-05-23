import 'package:flutter/material.dart';
import 'package:localservicemarket/app.dart';
import 'package:localservicemarket/core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const LocalServiceMarketApp());
}
