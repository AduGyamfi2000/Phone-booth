import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'providers/user_provider.dart';
import 'screens/home_screen.dart';

class PhoneBoothApp extends StatelessWidget {
  const PhoneBoothApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider()..initialize(),
      child: MaterialApp(
        title: 'Phone Booth',
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
