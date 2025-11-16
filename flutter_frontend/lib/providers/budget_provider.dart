import 'package:flutter/foundation.dart';
import '../models/budget.dart' as BudgetModel;
import '../services/data_service.dart';

class BudgetProvider extends ChangeNotifier {
  List<BudgetModel.Budget> _budgets = [];
  bool _isLoading = false;
  String _message = '';

  List<BudgetModel.Budget> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String get message => _message;

  Future<void> fetchBudgets() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await DataService.getBudgets();

      if (response.success) {
        _budgets = response.data?.data ?? [];
        _message = response.message;
      } else {
        _message = response.message;
      }
    } catch (e) {
      _message = 'Gagal mengambil anggaran: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createBudget(
    int categoryId,
    String amount,
    String month,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await DataService.createBudget(
        categoryId: categoryId,
        amount: amount,
        month: month,
      );

      if (response.success) {
        await fetchBudgets(); // Refresh the list
        _message = response.message;
        return true;
      } else {
        _message = response.message;
        return false;
      }
    } catch (e) {
      _message = 'Gagal membuat anggaran: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateBudget(
    int id,
    int categoryId,
    String amount,
    String month,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await DataService.updateBudget(
        id: id,
        categoryId: categoryId,
        amount: amount,
        month: month,
      );

      if (response.success) {
        await fetchBudgets(); // Refresh the list
        _message = response.message;
        return true;
      } else {
        _message = response.message;
        return false;
      }
    } catch (e) {
      _message = 'Gagal memperbarui anggaran: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteBudget(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await DataService.deleteBudget(id);

      if (response.success) {
        await fetchBudgets(); // Refresh the list after deletion
        _message = response.message;
        notifyListeners();
        return true;
      } else {
        _message = response.message;
        return false;
      }
    } catch (e) {
      _message = 'Gagal menghapus anggaran: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}