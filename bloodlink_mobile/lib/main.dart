import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'config/routes.dart';
import 'config/theme.dart';
import 'core/services/api_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/notification_service.dart';
import 'providers/auth_provider.dart';
import 'providers/alerte_provider.dart';
import 'providers/location_provider.dart';

// Handler pour les notifications en arrière-plan
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Message reçu en arrière-plan: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation Firebase
  await Firebase.initializeApp();
  
  // Handler notifications en arrière-plan
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialisation des services
  await StorageService().init();
  ApiService().init();
  await NotificationService().initialize();

  runApp(const BloodLinkApp());
}

class BloodLinkApp extends StatelessWidget {
  const BloodLinkApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AlerteProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: MaterialApp(
        title: 'BloodLink',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('fr', 'FR'),
          Locale('en', 'US'),
        ],
        locale: const Locale('fr', 'FR'),
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.getRoutes(),
      ),
    );
  }
}