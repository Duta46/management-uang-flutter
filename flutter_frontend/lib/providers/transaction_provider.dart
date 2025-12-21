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
        .map((transaction) => double.tryParse(transaction.amount) ?? 0)
        .fold(0.0, (prev, amount) => prev + amount);
  }

  double get totalExpense {
    return _transactions
        .where((transaction) => transaction.type == 'expense')
        .map((transaction) => double.tryParse(transaction.amount) ?? 0)
        .fold(0.0, (prev, amount) => prev + amount);
  }

  double get balance {
    return totalIncome - totalExpense;
  }
}