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

  List<Transaction> get transactions => _transactions;
  String get message => _message;
  bool get isLoading => _isLoading;

  // Properties for home screen
  double get income {
    return _transactions
        .where((transaction) => transaction.type == 'income')
        .map((transaction) => transaction.amount)
        .fold(0.0, (prev, amount) => prev + amount);
  }

  double get expense {
    return _transactions
        .where((transaction) => transaction.type == 'expense')
        .map((transaction) => transaction.amount)
        .fold(0.0, (prev, amount) => prev + amount);
  }

  double get balance {
    return income - expense;
  }

  // Method for home screen
  Future<void> fetchDashboardSummary() async {
    // Re-fetch transactions to update dashboard
    await fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    print("TransactionProvider: Starting fetchTransactions"); // Debug log

    try {
      final Response.ApiResponse response = await _apiRepository.getTransactions();
      print("TransactionProvider: Received response, success: ${response.success}"); // Debug log
      print("TransactionProvider: Response data: ${response.data}"); // Debug log

      if (response.success) {
        // Dari log, response.data bisa langsung berisi array transaksi atau objek dengan key 'data'
        if (response.data is List) {
          // Jika response.data langsung array transaksi
          try {
            List<Transaction> processedTransactions = [];
            for (int i = 0; i < (response.data as List).length; i++) {
              dynamic item = (response.data as List)[i];
              print("TransactionProvider: Processing transaction at index $i: $item"); // Debug log

              if (item is Map<String, dynamic>) {
                processedTransactions.add(Transaction.fromJson(item));
              } else {
                print("TransactionProvider: Item at index $i is not a Map<String, dynamic>, it's ${item.runtimeType}"); // Debug log
              }
            }
            _transactions = processedTransactions;
            _message = 'Transactions loaded successfully (${_transactions.length} items)';
            print("TransactionProvider: Loaded ${_transactions.length} transactions"); // Debug log
          } catch (e, stackTrace) {
            print("TransactionProvider: Error during mapping: $e"); // Debug log
            print("Stack trace: $stackTrace"); // Debug log
            _transactions = []; // Set to empty list to prevent crash
          }
        } else if (response.data is Map<String, dynamic>) {
          // Jika response.data adalah objek dengan key 'data' (struktur paginasi Laravel)
          final responseData = response.data as Map<String, dynamic>;
          final transactionListData = responseData['data'] as List<dynamic>?;

          if (transactionListData != null) {
            try {
              List<Transaction> processedTransactions = [];
              for (int i = 0; i < transactionListData.length; i++) {
                dynamic item = transactionListData[i];
                print("TransactionProvider: Processing transaction at index $i: $item"); // Debug log

                if (item is Map<String, dynamic>) {
                  processedTransactions.add(Transaction.fromJson(item));
                } else {
                  print("TransactionProvider: Item at index $i is not a Map<String, dynamic>, it's ${item.runtimeType}"); // Debug log
                }
              }
              _transactions = processedTransactions;
              _message = 'Transactions loaded successfully (${_transactions.length} items)';
              print("TransactionProvider: Loaded ${_transactions.length} transactions"); // Debug log
            } catch (e, stackTrace) {
              print("TransactionProvider: Error during mapping: $e"); // Debug log
              print("Stack trace: $stackTrace"); // Debug log
              _transactions = []; // Set to empty list to prevent crash
            }
          } else {
            _message = 'Transaction data is null';
            print("TransactionProvider: Error - Transaction data is null in response"); // Debug log
          }
        } else {
          _message = 'Format respons API tidak dikenali';
          print("TransactionProvider: Error - Format respons tidak dikenali: ${response.data?.runtimeType}"); // Debug log
        }
      } else {
        _message = response.message ?? 'Failed to load transactions';
        print("TransactionProvider: Error - ${_message}"); // Debug log
      }
    } catch (e, stackTrace) {
      _message = e.toString();
      print("TransactionProvider: Exception caught: $e"); // Debug log
      print("Stack trace: $stackTrace"); // Debug log
    } finally {
      notifyListeners();
    }
  }

  Future<bool> createTransaction({
    required String amount,
    required String type,
    required int categoryId,
    String? description,
    String? date,
  }) async {
    try {
      final Response.ApiResponse response = await _apiRepository.createTransaction(
        amount: amount,
        type: type,
        categoryId: categoryId,
        description: description,
        date: date,
      );

      if (response.success) {
        await fetchTransactions(); // Refresh the list
        _message = 'Transaction created successfully';
        return true;
      } else {
        _message = response.message ?? 'Failed to create transaction';
        return false;
      }
    } catch (e) {
      _message = e.toString();
      return false;
    }
  }

  Future<bool> createTransactionSimple(int categoryId, String amount, String type, String? description, String? date) async {
    try {
      final response = await _apiRepository.createTransactionSimple(
        categoryId,
        amount,
        type,
        description,
        date,
      );

      if (response.success) {
        await fetchTransactions(); // Refresh the list
        _message = 'Transaction created successfully';
        return true;
      } else {
        _message = response.message ?? 'Failed to create transaction';
        return false;
      }
    } catch (e) {
      _message = e.toString();
      return false;
    }
  }

  Future<bool> updateTransaction(int id, int categoryId, String amount, String type, String? description, String? date) async {
    try {
      final response = await _apiRepository.updateTransaction(
        id,
        categoryId,
        amount,
        type,
        description,
        date,
      );

      if (response.success) {
        await fetchTransactions(); // Refresh the list
        _message = 'Transaction updated successfully';
        return true;
      } else {
        _message = response.message ?? 'Failed to update transaction';
        return false;
      }
    } catch (e) {
      _message = e.toString();
      return false;
    }
  }

  Future<bool> updateTransactionNamed({
    required int id,
    required int categoryId,
    required String amount,
    required String type,
    String? description,
    String? date,
  }) async {
    try {
      final response = await _apiRepository.updateTransaction(
        id,
        categoryId,
        amount,
        type,
        description,
        date,
      );

      if (response.success) {
        await fetchTransactions(); // Refresh the list
        _message = 'Transaction updated successfully';
        return true;
      } else {
        _message = response.message ?? 'Failed to update transaction';
        return false;
      }
    } catch (e) {
      _message = e.toString();
      return false;
    }
  }

  Future<bool> deleteTransaction(int id) async {
    try {
      final response = await _apiRepository.deleteTransaction(id);

      if (response.success) {
        await fetchTransactions(); // Refresh the list
        _message = 'Transaction deleted successfully';
        return true;
      } else {
        _message = response.message ?? 'Failed to delete transaction';
        return false;
      }
    } catch (e) {
      _message = e.toString();
      return false;
    }
  }

  void setMessage(String message) {
    _message = message;
    notifyListeners();
  }
}