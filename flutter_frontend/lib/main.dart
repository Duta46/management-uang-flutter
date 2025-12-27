import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flutter_frontend/providers/auth_provider_change_notifier.dart';
import 'package:flutter_frontend/providers/category_provider_change_notifier.dart';
import 'package:flutter_frontend/providers/transaction_provider_change_notifier.dart';
import 'package:flutter_frontend/providers/dashboard_provider.dart';
import 'widgets/error_boundary.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/main_navigation_screen.dart';
import 'theme/app_theme.dart';
import 'utils/logger.dart';

void main() {
  // Set up global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    Logger.error('Flutter Error: ${details.exception}', stackTrace: details.stack);
  };

  // Set up uncaught error handling
  // This approach is compatible with older Flutter versions
  runZonedGuarded(() {
    runApp(MyApp());
  }, (error, stackTrace) {
    Logger.error('Uncaught Error: $error', stackTrace: stackTrace);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(
            create: (context) => AuthProvider(),
          ),
          ChangeNotifierProvider<CategoryProvider>(
            create: (context) => CategoryProvider(),
          ),
          ChangeNotifierProvider<TransactionProvider>(
            create: (context) => TransactionProvider(),
          ),
          ChangeNotifierProvider<DashboardProvider>(
            create: (context) => DashboardProvider(),
          ),
        ],
        child: Builder(
          builder: (context) {
            return MaterialApp(
              title: 'Personal Finance App',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              home: _buildHomeScreen(context),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHomeScreen(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Muat user dari storage saat aplikasi dimulai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authProvider.loadCurrentUser();
    });

    // Gunakan Consumer untuk memantau perubahan auth state
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.currentUser != null) {
          return const MainNavigationScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}