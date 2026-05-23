import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localservicemarket/app.dart';
import 'package:localservicemarket/core/di/injection.dart';
import 'package:localservicemarket/core/theme/app_colors.dart';
import 'package:localservicemarket/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = true;
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      ),
    ),
  );
  await configureDependencies();
  runApp(const LocalServiceMarketApp());
}
