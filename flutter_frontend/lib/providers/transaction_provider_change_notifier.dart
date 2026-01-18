import 'dart:async';
import 'package:flutter/foundation.dart';
import '../repositories/api_repository.dart';
import '../models/transaction.dart';
import '../models/api_response.dart' as Response;
import 'global_providers.dart';

class TransactionProvider extends ChangeNotifier {
  final ApiRepository _apiRepository = sharedApiRepository;
  List<Transaction> _transactions = [];
  String _message = '';
  bool _isLoading = false;
  bool _hasFetched = false;
  DateTime? _lastFetchTime;
  Completer<void>? _fetchCompleter; // To prevent duplicate requests

  List<Transaction> get transactions => _transactions;
  String get message => _message;
  bool get isLoading => _isLoading;
  bool get hasFetched => _hasFetched;

  // Properties for home screen
  double get income {
    return _transactions
        .where((transaction) => transaction.type == 'income')
        .map((transaction) => double.tryParse(transaction.amount.toString()) ?? 0.0)
        .fold(0.0, (prev, amount) => prev + amount);
  }

  double get expense {
    return _transactions
        .where((transaction) => transaction.type == 'expense')
        .map((transaction) => double.tryParse(transaction.amount.toString()) ?? 0.0)
        .fold(0.0, (prev, amount) => prev + amount);
  }

  double get balance {
    return income - expense;
  }

  // Aliases for dashboard screen compatibility
  double get totalIncome {
    return income;
  }

  double get totalExpenses {
    return expense;
  }

  // Method for home screen
  Future<void> fetchDashboardSummary() async {
    // Re-fetch transactions to update dashboard
    await fetchTransactions();
  }

  Future<void> fetchDashboardData() async {
    await fetchDashboardSummary();
  }

  Future<void> fetchTransactions() async {
    // Guard: Prevent multiple simultaneous requests
    if (_isLoading) return;
    
    // Check if there's already a fetch in progress
    if (_fetchCompleter != null && !_fetchCompleter!.isCompleted) {
      // Wait for the ongoing fetch to complete
      await _fetchCompleter!.future;
      return;
    }
    
    // Optional: Add caching to prevent too frequent requests
    final now = DateTime.now();
    if (_hasFetched && _lastFetchTime != null && 
        now.difference(_lastFetchTime!).inMilliseconds < 500) {
      return; // Debounce: prevent too frequent calls
    }

    _isLoading = true;
    _lastFetchTime = now;
    _fetchCompleter = Completer<void>();
    notifyListeners();

    try {
      final Response.ApiResponse response = await _apiRepository.getTransactions();

      if (response.success) {
        List<Transaction> newTransactions = [];

        if (response.data is List) {
          newTransactions = (response.data as List).map((json) => Transaction.fromJson(json)).toList();
        } else if (response.data is Map<String, dynamic>) {
          final responseData = response.data as Map<String, dynamic>;
          final transactionListData = responseData['data'] as List<dynamic>?;

          if (transactionListData != null) {
            newTransactions = transactionListData.map((json) => Transaction.fromJson(json)).toList();
          }
        }

        // Only update if data actually changed
        if (!_listsEqual(_transactions, newTransactions)) {
          _transactions = newTransactions;
        }
        
        _message = 'Transactions loaded successfully';
        _hasFetched = true;
      } else {
        _message = response.message ?? 'Failed to load transactions';
      }
    } catch (e) {
      _message = e.toString();
    } finally {
      _isLoading = false;
      if (!_fetchCompleter!.isCompleted) {
        _fetchCompleter!.complete();
      }
      notifyListeners();
    }
  }

  // Helper method to compare two lists
  bool _listsEqual(List<Transaction> list1, List<Transaction> list2) {
    if (list1.length != list2.length) return false;
    
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].id != list2[i].id || 
          list1[i].amount != list2[i].amount ||
          list1[i].type != list2[i].type ||
          list1[i].description != list2[i].description ||
          list1[i].date != list2[i].date) {
        return false;
      }
    }
    return true;
  }

  Future<bool> createTransaction({
    required String amount,
    required String type,
    required int categoryId,
    int? billReminderId,
    String? description,
    String? date,
  }) async {
    if (_isLoading) return false;
    
    try {
      final Response.ApiResponse response = await _apiRepository.createTransaction(
        amount: amount,
        type: type,
        categoryId: categoryId,
        billReminderId: billReminderId,
        description: description,
        date: date,
      );

      if (response.success) {
        await fetchTransactions(); // Refresh the list
        _message = 'Transaction created successfully';
        return true;
      } else {
        _message = response.message ?? 'Failed to create transaction';
        notifyListeners(); // Notify listeners about the error
        return false;
      }
    } catch (e) {
      _message = e.toString();
      notifyListeners(); // Notify listeners about the error
      return false;
    }
  }

  Future<bool> createTransactionSimple(int? categoryId, String amount, String type, String? description, String? date, {int? billReminderId, int? savingsGoalId}) async {
    if (_isLoading) return false;

    try {
      final response = await _apiRepository.createTransactionSimple(
        categoryId,
        amount,
        type,
        description,
        date,
        billReminderId: billReminderId,
        savingsGoalId: savingsGoalId,
      );

      if (response.success) {
        await fetchTransactions(); // Refresh the list
        _message = 'Transaction created successfully';
        return true;
      } else {
        _message = response.message ?? 'Failed to create transaction';
        notifyListeners(); // Notify listeners about the error
        return false;
      }
    } catch (e) {
      _message = e.toString();
      notifyListeners(); // Notify listeners about the error
      return false;
    }
  }

  Future<bool> updateTransaction(int id, int? categoryId, String amount, String type, String? description, String? date, {int? billReminderId, int? savingsGoalId}) async {
    if (_isLoading) return false;

    try {
      final response = await _apiRepository.updateTransaction(
        id,
        categoryId,
        amount,
        type,
        description,
        date,
        billReminderId: billReminderId,
        savingsGoalId: savingsGoalId,
      );

      if (response.success) {
        await fetchTransactions(); // Refresh the list
        _message = 'Transaction updated successfully';
        return true;
      } else {
        _message = response.message ?? 'Failed to update transaction';
        notifyListeners(); // Notify listeners about the error
        return false;
      }
    } catch (e) {
      _message = e.toString();
      notifyListeners(); // Notify listeners about the error
      return false;
    }
  }

  Future<bool> updateTransactionNamed({
    required int id,
    required int? categoryId,
    required String amount,
    required String type,
    String? description,
    String? date,
    int? billReminderId,
    int? savingsGoalId,
  }) async {
    if (_isLoading) return false;

    try {
      final response = await _apiRepository.updateTransaction(
        id,
        categoryId,
        amount,
        type,
        description,
        date,
        billReminderId: billReminderId,
        savingsGoalId: savingsGoalId,
      );

      if (response.success) {
        await fetchTransactions(); // Refresh the list
        _message = 'Transaction updated successfully';
        return true;
      } else {
        _message = response.message ?? 'Failed to update transaction';
        notifyListeners(); // Notify listeners about the error
        return false;
      }
    } catch (e) {
      _message = e.toString();
      notifyListeners(); // Notify listeners about the error
      return false;
    }
  }

  Future<bool> deleteTransaction(int id) async {
    if (_isLoading) return false;
    
    try {
      final response = await _apiRepository.deleteTransaction(id);

      if (response.success) {
        await fetchTransactions(); // Refresh the list
        _message = 'Transaction deleted successfully';
        return true;
      } else {
        _message = response.message ?? 'Failed to delete transaction';
        notifyListeners(); // Notify listeners about the error
        return false;
      }
    } catch (e) {
      _message = e.toString();
      notifyListeners(); // Notify listeners about the error
      return false;
    }
  }

  void setMessage(String message) {
    _message = message;
    notifyListeners();
  }

  // Clear the fetched flag if needed
  void resetFetchState() {
    _hasFetched = false;
    _lastFetchTime = null;
  }
  
  // Dispose method to clean up resources
  @override
  void dispose() {
    _fetchCompleter?.complete();
    super.dispose();
  }
}