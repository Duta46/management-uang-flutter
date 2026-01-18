import 'package:flutter/foundation.dart';
import '../repositories/api_repository.dart';
import '../models/api_models.dart' hide ApiResponse;
import '../models/api_response.dart' show ApiResponse;
import '../utils/error_handler.dart';
import 'global_providers.dart';

class TransactionProvider extends ChangeNotifier {
  final ApiRepository _apiRepository = sharedApiRepository;
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<Transaction> get transactions => _transactions;
  String? get errorMessage => _errorMessage;

  Future<void> fetchTransactions({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiRepository.getTransactions();

      if (response.success && response.data != null) {
        final List<dynamic> transactionList = response.data['data']['data'];
        _transactions = transactionList.map((json) => Transaction.fromJson(json)).toList();
      } else {
        _errorMessage = response.message;
      }
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      _errorMessage = exception.message;
      debugPrint('TransactionProvider.fetchTransactions error: $exception');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ApiResponse> addTransaction(Transaction transaction) async {
    try {
      final response = await _apiRepository.addTransaction(transaction);
      if (response.success) {
        await fetchTransactions(); // Refresh the list
      }
      return response;
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      debugPrint('TransactionProvider.addTransaction error: $exception');
      return ApiResponse.error(message: exception.message);
    }
  }

  Future<ApiResponse> createTransaction({
    required String amount,
    required String type,
    required int categoryId,
    int? billReminderId,
    int? savingsGoalId,
    String? description,
    String? date,
  }) async {
    try {
      final response = await _apiRepository.createTransaction(
        amount: amount,
        type: type,
        categoryId: categoryId,
        billReminderId: billReminderId,
        savingsGoalId: savingsGoalId,
        description: description,
        date: date,
      );
      if (response.success) {
        await fetchTransactions(); // Refresh the list
      }
      return response;
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      debugPrint('TransactionProvider.createTransaction error: $exception');
      return ApiResponse.error(message: exception.message);
    }
  }

  Future<ApiResponse> updateTransaction(int id, int categoryId, String amount, String type, String? description, String? date, {int? billReminderId, int? savingsGoalId}) async {
    try {
      final response = await _apiRepository.updateTransaction(
        id: id,
        categoryId: categoryId,
        amount: amount,
        type: type,
        description: description,
        date: date,
        billReminderId: billReminderId,
        savingsGoalId: savingsGoalId,
      );
      if (response.success) {
        await fetchTransactions(); // Refresh the list
      }
      return response;
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      debugPrint('TransactionProvider.updateTransaction error: $exception');
      return ApiResponse.error(message: exception.message);
    }
  }

  Future<ApiResponse> deleteTransaction(int id) async {
    try {
      final response = await _apiRepository.deleteTransaction(id);
      if (response.success) {
        await fetchTransactions(); // Refresh the list
      }
      return response;
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      debugPrint('TransactionProvider.deleteTransaction error: $exception');
      return ApiResponse.error(message: exception.message);
    }
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