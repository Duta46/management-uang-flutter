import 'package:flutter/foundation.dart';
import '../repositories/api_repository.dart';
import '../models/api_models.dart' hide ApiResponse;
import '../models/api_response.dart' show ApiResponse;
import 'global_providers.dart';

class TransactionProvider extends ChangeNotifier {
  final ApiRepository _apiRepository = sharedApiRepository;
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<Transaction> get transactions => _transactions;

  Future<void> fetchTransactions({bool forceRefresh = false}) async {
    _isLoading = true;
    notifyListeners();

    final response = await _apiRepository.getTransactions();

    if (response.success && response.data != null) {
      final List<dynamic> transactionList = response.data['data']['data'];
      _transactions = transactionList.map((json) => Transaction.fromJson(json)).toList();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<ApiResponse> addTransaction(Transaction transaction) async {
    final response = await _apiRepository.addTransaction(transaction);
    if (response.success) {
      await fetchTransactions(); // Refresh the list
    }
    return response;
  }

  // Getters untuk menghitung total
  double get totalIncome {
    return _transactions
        .where((transaction) => transaction.type == 'income')
        .map((transaction) => transaction.amount)
        .fold(0.0, (prev, amount) => prev + amount);
  }

  double get totalExpense {
    return _transactions
        .where((transaction) => transaction.type == 'expense')
        .map((transaction) => transaction.amount)
        .fold(0.0, (prev, amount) => prev + amount);
  }

  double get balance {
    return totalIncome - totalExpense;
  }

  // Get monthly transactions for specific month and year
  List<Transaction> getMonthlyTransactions(int month, int year) {
    return _transactions.where((transaction) {
      if (transaction.date == null) return false;
      final transactionDate = transaction.date!;
      final matches = transactionDate.year == year && transactionDate.month == month;
      // Debug log
      // print("Transaction date: ${transaction.date}, Local date: $transactionDate, Matches: $matches, Filter: year=$year, month=$month");
      return matches;
    }).toList();
  }

  // Get monthly income for specific month and year
  double getMonthlyIncome(int month, int year) {
    return getMonthlyTransactions(month, year)
        .where((transaction) => transaction.type == 'income')
        .map((transaction) => transaction.amount)
        .fold(0.0, (prev, amount) => prev + amount);
  }

  // Get monthly expense for specific month and year
  double getMonthlyExpense(int month, int year) {
    return getMonthlyTransactions(month, year)
        .where((transaction) => transaction.type == 'expense')
        .map((transaction) => transaction.amount)
        .fold(0.0, (prev, amount) => prev + amount);
  }

  // Get monthly balance for specific month and year
  double getMonthlyBalance(int month, int year) {
    return getMonthlyIncome(month, year) - getMonthlyExpense(month, year);
  }
}