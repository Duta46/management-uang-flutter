import 'package:flutter/foundation.dart';
import '../models/transaction.dart' as TransactionModel;
import '../services/data_service.dart';

class TransactionProvider extends ChangeNotifier {
  List<TransactionModel.Transaction> _transactions = [];
  bool _isLoading = false;
  String _message = '';
  DateTime? _lastFetch;

  List<TransactionModel.Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String get message => _message;

  // Getter untuk statistik keuangan
  double get totalIncome {
    return _transactions
        .where((transaction) => transaction.type == 'income')
        .map((transaction) => double.tryParse(transaction.amount) ?? 0)
        .fold(0, (prev, element) => prev + element);
  }

  double get totalExpense {
    return _transactions
        .where((transaction) => transaction.type == 'expense')
        .map((transaction) => double.tryParse(transaction.amount) ?? 0)
        .fold(0, (prev, element) => prev + element);
  }

  double get balance => totalIncome - totalExpense;

  // Cek apakah data perlu diperbarui (cache selama 5 menit)
  bool get needsRefresh {
    if (_lastFetch == null) return true;
    return DateTime.now().difference(_lastFetch!) > const Duration(minutes: 5);
  }

  Future<void> fetchTransactions({bool forceRefresh = false}) async {
    // Jika data sudah ada dan tidak perlu di-refresh, lewati fetching
    if (_transactions.isNotEmpty && !forceRefresh && !needsRefresh) {
      print("Menggunakan cache transaksi, jumlah: ${_transactions.length}"); // Debug log
      notifyListeners();
      return;
    }

    print("Memulai fetch transaksi..."); // Debug log
    _isLoading = true;
    notifyListeners();

    try {
      final response = await DataService.getTransactions();

      if (response.success) {
        _transactions = response.data?.data ?? [];
        _lastFetch = DateTime.now(); // Simpan waktu fetch terakhir
        _message = response.message;
        print("Berhasil mengambil ${_transactions.length} transaksi"); // Debug log
      } else {
        _message = response.message;
        print("Gagal mengambil transaksi: ${response.message}"); // Debug log
      }
    } catch (e) {
      _message = 'Gagal mengambil transaksi: $e';
      print("Exception mengambil transaksi: $e"); // Debug log
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTransaction(
    int categoryId,
    String amount,
    String type,
    String? description,
    String? date,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await DataService.createTransaction(
        categoryId: categoryId,
        amount: amount,
        type: type,
        description: description,
        date: date,
      );

      if (response.success) {
        await fetchTransactions(forceRefresh: true); // Refresh the list
        _message = response.message;
        return true;
      } else {
        _message = response.message;
        return false;
      }
    } catch (e) {
      _message = 'Gagal membuat transaksi: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateTransaction(
    int id,
    int categoryId,
    String amount,
    String type,
    String? description,
    String? date,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await DataService.updateTransaction(
        id: id,
        categoryId: categoryId,
        amount: amount,
        type: type,
        description: description,
        date: date,
      );

      if (response.success) {
        await fetchTransactions(forceRefresh: true); // Refresh the list
        _message = response.message;
        return true;
      } else {
        _message = response.message;
        return false;
      }
    } catch (e) {
      _message = 'Gagal memperbarui transaksi: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteTransaction(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await DataService.deleteTransaction(id);

      if (response.success) {
        await fetchTransactions(forceRefresh: true); // Refresh the list after deletion
        _message = response.message;
        notifyListeners();
        return true;
      } else {
        _message = response.message;
        return false;
      }
    } catch (e) {
      _message = 'Gagal menghapus transaksi: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}