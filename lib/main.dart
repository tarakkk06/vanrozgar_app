import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/app_state_provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (FirebaseOptionsConfig.isConfigured) {
    await Firebase.initializeApp(
      options: FirebaseOptionsConfig.currentPlatform,
    );
  }
  runApp(const VanRozgarApp());
}

class VanRozgarApp extends StatelessWidget {
  const VanRozgarApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
      ],
      child: MaterialApp(
        title: 'VanRozgar 2.0',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashWelcomeScreen(),
      ),
    );
  }
}
