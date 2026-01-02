import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';
import '../config/api_config.dart';
import '../config/api_service.dart';

class TransactionReportService {
  // Get transactions for a specific month and year
  static Future<TransactionReportData?> getMonthlyTransactions({
    required int month,
    required int year,
  }) async {
    try {
      String url = '${ApiConfig.baseUrl}/reports/monthly';
      url += '?month=$month&year=$year';

      final response = await http.get(
        Uri.parse(url),
        headers: await ApiService.getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TransactionReportData.fromJson(data['data']);
      } else {
        throw Exception('Failed to load monthly transactions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting monthly transactions: $e');
      return null;
    }
  }

  // Get transactions for a specific date range
  static Future<TransactionReportData?> getTransactionsByDateRange({
    required String startDate,
    required String endDate,
  }) async {
    try {
      String url = '${ApiConfig.baseUrl}/reports/transactions';
      url += '?start_date=$startDate&end_date=$endDate';

      final response = await http.get(
        Uri.parse(url),
        headers: await ApiService.getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TransactionReportData.fromJson(data['data']);
      } else {
        throw Exception('Failed to load transactions by date range: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting transactions by date range: $e');
      return null;
    }
  }
}

class TransactionReportData {
  final String month;
  final String year;
  final double totalIncome;
  final double totalExpense;
  final double netTotal;
  final List<Transaction> incomeTransactions;
  final List<Transaction> expenseTransactions;

  TransactionReportData({
    required this.month,
    required this.year,
    required this.totalIncome,
    required this.totalExpense,
    required this.netTotal,
    required this.incomeTransactions,
    required this.expenseTransactions,
  });

  factory TransactionReportData.fromJson(Map<String, dynamic> json) {
    List<Transaction> incomeTransactions = [];
    List<Transaction> expenseTransactions = [];

    if (json['income_transactions'] != null) {
      incomeTransactions = (json['income_transactions'] as List)
          .map((item) => Transaction.fromJson(item))
          .toList();
    }

    if (json['expense_transactions'] != null) {
      expenseTransactions = (json['expense_transactions'] as List)
          .map((item) => Transaction.fromJson(item))
          .toList();
    }

    return TransactionReportData(
      month: json['month'] ?? '',
      year: json['year'] ?? '',
      totalIncome: (json['total_income'] is int) ? json['total_income'].toDouble() : (json['total_income'] ?? 0.0),
      totalExpense: (json['total_expense'] is int) ? json['total_expense'].toDouble() : (json['total_expense'] ?? 0.0),
      netTotal: (json['net_total'] is int) ? json['net_total'].toDouble() : (json['net_total'] ?? 0.0),
      incomeTransactions: incomeTransactions,
      expenseTransactions: expenseTransactions,
    );
  }
}