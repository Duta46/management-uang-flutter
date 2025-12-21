import 'package:flutter/foundation.dart';
import '../models/debt.dart';
import '../services/debt_service.dart';

class DebtProvider extends ChangeNotifier {
  List<Debt> _debts = [];
  bool _isLoading = false;

  List<Debt> get debts => _debts;
  bool get isLoading => _isLoading;

  Future<void> fetchDebts({String? status}) async {
    _isLoading = true;
    notifyListeners();

    final result = await DebtService.getAllDebts(status: status);
    if (result != null) {
      _debts = result.debts;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createDebt({
    required String creditorName,
    required double amount,
    required DateTime dueDate,
    String? status,
    String? notes,
  }) async {
    final debt = await DebtService.createDebt(
      creditorName: creditorName,
      amount: amount,
      dueDate: dueDate,
      status: status,
      notes: notes,
    );

    if (debt != null) {
      _debts.add(debt);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> updateDebt({
    required int id,
    String? creditorName,
    double? amount,
    DateTime? dueDate,
    String? status,
    String? notes,
  }) async {
    final debt = await DebtService.updateDebt(
      id: id,
      creditorName: creditorName,
      amount: amount,
      dueDate: dueDate,
      status: status,
      notes: notes,
    );

    if (debt != null) {
      final index = _debts.indexWhere((d) => d.id == id);
      if (index != -1) {
        _debts[index] = debt;
        notifyListeners();
      }
      return true;
    }
    return false;
  }

  Future<bool> deleteDebt(int id) async {
    final success = await DebtService.deleteDebt(id);
    if (success) {
      _debts.removeWhere((d) => d.id == id);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> markDebtAsPaid(int id) async {
    final debt = await DebtService.markDebtAsPaid(id);
    if (debt != null) {
      final index = _debts.indexWhere((d) => d.id == id);
      if (index != -1) {
        _debts[index] = debt;
        notifyListeners();
      }
      return true;
    }
    return false;
  }
}