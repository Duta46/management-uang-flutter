import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flutter_frontend/services/data_service.dart';
import 'package:flutter_frontend/models/budget.dart';
import 'package:flutter_frontend/models/savings_goal.dart';
import 'package:flutter_frontend/models/bill_reminder.dart';
import 'package:flutter_frontend/providers/auth_provider_change_notifier.dart';
import 'package:flutter_frontend/providers/category_provider_change_notifier.dart';
import 'package:flutter_frontend/providers/transaction_provider_change_notifier.dart';
import 'package:flutter_frontend/providers/budget_provider.dart';
import 'package:flutter_frontend/providers/savings_goal_provider.dart';
import 'package:flutter_frontend/providers/bill_reminder_provider.dart';
import 'package:flutter_frontend/providers/financial_report_provider.dart';
import 'package:flutter_frontend/providers/financial_health_provider.dart';
import 'package:flutter_frontend/providers/dashboard_provider.dart';
import 'package:flutter_frontend/providers/bill_notification_provider.dart';
// import 'package:flutter_frontend/providers/financial_insights_provider.dart'; // AI feature moved to coming soon
// import 'package:flutter_frontend/providers/financial_recommendations_provider.dart'; // AI feature moved to coming soon
// import 'package:flutter_frontend/providers/financial_predictions_provider.dart'; // AI feature moved to coming soon
// import 'package:flutter_frontend/providers/ai_analysis_provider.dart'; // AI feature commented out
import 'widgets/error_boundary.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/financial_dashboard_screen.dart';
import 'screens/onboarding_screen.dart';
// import 'screens/analyst_ai_screen.dart'; // AI feature moved to coming soon
import 'screens/budget/budget_screen.dart';
import 'screens/budget/add_budget_screen.dart';
import 'screens/budget/edit_budget_screen.dart';
import 'screens/categories/category_list_screen.dart';
import 'screens/transactions/transaction_list_screen.dart';
import 'screens/transactions/transaction_form_screen.dart';
import 'screens/savings/savings_goal_screen.dart';
import 'screens/savings/add_savings_goal_screen.dart';
import 'screens/savings/edit_savings_goal_screen.dart';
import 'screens/bill_reminder/bill_reminder_screen.dart';
import 'screens/bill_reminder/add_bill_reminder_screen.dart';
import 'screens/bill_reminder/edit_bill_reminder_screen.dart';
import 'screens/reports/financial_report_screen.dart';
import 'screens/financial_health/financial_health_screen.dart';
import 'screens/financial_notifications/financial_notifications_screen.dart';
import 'screens/coming_soon_screen.dart'; // New coming soon screen
import 'screens/other_features_screen.dart'; // Other features screen
import 'screens/help_screen.dart'; // Help screen
import 'screens/main_navigation_screen.dart'; // Main navigation screen
import 'screens/home/daily_transaction_screen.dart'; // Daily transaction screen
import 'screens/home/monthly_finance_screen.dart'; // Monthly finance screen
import 'screens/profile_screen.dart'; // Profile screen
import 'theme/app_theme.dart';
import 'utils/logger.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  // Initialize data service
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize locale data for Indonesian
  await initializeDateFormatting('id_ID', null);
  await DataService.initialize();

  // Set up global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    Logger.error('Flutter Error: ${details.exception}', stackTrace: details.stack);
  };

  // Set up uncaught error handling
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
          ChangeNotifierProvider<BudgetProvider>(
            create: (context) => BudgetProvider(),
          ),
          ChangeNotifierProvider<SavingsGoalProvider>(
            create: (context) => SavingsGoalProvider(),
          ),
          ChangeNotifierProvider<BillReminderProvider>(
            create: (context) => BillReminderProvider(),
          ),
          ChangeNotifierProvider<FinancialReportProvider>(
            create: (context) => FinancialReportProvider(),
          ),
          // ChangeNotifierProvider<FinancialInsightsProvider>(
          //   create: (context) => FinancialInsightsProvider(),
          // ), // AI feature moved to coming soon
          // ChangeNotifierProvider<FinancialRecommendationsProvider>(
          //   create: (context) => FinancialRecommendationsProvider(),
          // ), // AI feature moved to coming soon
          // ChangeNotifierProvider<FinancialPredictionsProvider>(
          //   create: (context) => FinancialPredictionsProvider(),
          // ), // AI feature moved to coming soon
          ChangeNotifierProvider<FinancialHealthProvider>(
            create: (context) => FinancialHealthProvider(),
          ),
          ChangeNotifierProvider<DashboardProvider>(
            create: (context) => DashboardProvider(),
          ),
          ChangeNotifierProvider<BillNotificationProvider>(
            create: (context) => BillNotificationProvider(),
          ),
          // ChangeNotifierProvider<AiAnalysisProvider>(
          //   create: (context) => AiAnalysisProvider(),
          // ), // AI feature commented out
        ],
        child: Builder(
          builder: (context) {
            return MaterialApp(
              title: 'Personal Finance App',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              // Tambahkan ini untuk mendukung lokal
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', 'US'), // English
                Locale('id', 'ID'), // Indonesian
              ],
              locale: const Locale('id', 'ID'), // Set default locale ke Indonesia
              home: _buildHomeScreen(context),
              routes: {
                // '/chatbot': (context) => const FinancialChatbotScreen(), // AI feature commented out
                // '/ollama': (context) => const OllamaScreen(), // AI feature commented out
                // '/ollama-chatbot': (context) => const OllamaFinancialChatbotScreen(), // AI feature commented out
                '/budget': (context) => const BudgetScreen(),
                '/add-budget': (context) => const AddBudgetScreen(),
                '/savings-goals': (context) => const SavingsGoalScreen(),
                '/add-savings-goal': (context) => const AddSavingsGoalScreen(),
                '/bill-reminders': (context) => const BillReminderScreen(),
                '/add-bill-reminder': (context) => const AddBillReminderScreen(),
                '/categories': (context) => const CategoryListScreen(),
                '/transactions': (context) => const TransactionListScreen(),
                '/add-transaction': (context) => const TransactionFormScreen(),
                '/financial-reports': (context) => const FinancialReportScreen(),
                '/financial-insights': (context) => const ComingSoonScreen(
                  featureName: 'Analyst AI',
                  description: 'Fitur ini akan memberikan analisis mendalam, rekomendasi, dan prediksi keuangan menggunakan teknologi AI.',
                ),
                '/financial-recommendations': (context) => const ComingSoonScreen(
                  featureName: 'Analyst AI',
                  description: 'Dapatkan rekomendasi personal untuk mengelola keuangan Anda dengan lebih efektif menggunakan AI.',
                ),
                '/financial-predictions': (context) => const ComingSoonScreen(
                  featureName: 'Analyst AI',
                  description: 'Prediksi kondisi keuangan Anda di masa depan berdasarkan tren saat ini menggunakan AI.',
                ),
                '/financial-health': (context) => const FinancialHealthScreen(),
                '/financial-notifications': (context) => const FinancialNotificationsScreen(),
                '/help': (context) => const HelpScreen(),
              },
              onGenerateRoute: (settings) {
                switch (settings.name) {
                  case '/edit-budget':
                    final budget = settings.arguments as Budget;
                    return MaterialPageRoute(
                      builder: (context) => EditBudgetScreen(budget: budget),
                    );
                  case '/edit-savings-goal':
                    final savingsGoal = settings.arguments as SavingsGoal;
                    return MaterialPageRoute(
                      builder: (context) => EditSavingsGoalScreen(savingsGoal: savingsGoal),
                    );
                  case '/edit-bill-reminder':
                    final billReminder = settings.arguments as BillReminder;
                    return MaterialPageRoute(
                      builder: (context) => EditBillReminderScreen(billReminder: billReminder),
                    );
                  default:
                    return null;
                }
              },
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
          // Cek apakah pengguna sudah melihat onboarding sebelumnya
          // Untuk sementara, langsung tampilkan login screen
          // Nanti bisa ditambahkan shared preferences untuk cek onboarding
          return const LoginScreen();
        }
      },
    );
  }
}