import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/alerte_provider.dart';
import 'providers/location_provider.dart';
import 'config/routes.dart';

class App extends StatelessWidget {
    const App({Key? key}) : super(key: key);

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
            initialRoute: AppRoutes.splash,
            routes: AppRoutes.getRoutes(),
        ),
        );
    }
}