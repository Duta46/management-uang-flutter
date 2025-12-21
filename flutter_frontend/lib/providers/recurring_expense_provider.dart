import 'package:flutter/foundation.dart';
import '../models/recurring_expense.dart';
import '../services/recurring_expense_service.dart';

class RecurringExpenseProvider extends ChangeNotifier {
  List<RecurringExpense> _recurringExpenses = [];
  bool _isLoading = false;

  List<RecurringExpense> get recurringExpenses => _recurringExpenses;
  bool get isLoading => _isLoading;

  Future<void> fetchRecurringExpenses() async {
    _isLoading = true;
    notifyListeners();

    final result = await RecurringExpenseService.getAllRecurringExpenses();
    if (result != null) {
      _recurringExpenses = result.recurringExpenses;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createRecurringExpense({
    required String name,
    required double amount,
    required String cycle,
    required DateTime nextRunDate,
    bool autoAdd = false,
  }) async {
    final expense = await RecurringExpenseService.createRecurringExpense(
      name: name,
      amount: amount,
      cycle: cycle,
      nextRunDate: nextRunDate,
      autoAdd: autoAdd,
    );

    if (expense != null) {
      _recurringExpenses.add(expense);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> updateRecurringExpense({
    required int id,
    String? name,
    double? amount,
    String? cycle,
    DateTime? nextRunDate,
    bool? autoAdd,
  }) async {
    final expense = await RecurringExpenseService.updateRecurringExpense(
      id: id,
      name: name,
      amount: amount,
      cycle: cycle,
      nextRunDate: nextRunDate,
      autoAdd: autoAdd,
    );

    if (expense != null) {
      final index = _recurringExpenses.indexWhere((e) => e.id == id);
      if (index != -1) {
        _recurringExpenses[index] = expense;
        notifyListeners();
      }
      return true;
    }
    return false;
  }

  Future<bool> deleteRecurringExpense(int id) async {
    final success = await RecurringExpenseService.deleteRecurringExpense(id);
    if (success) {
      _recurringExpenses.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> toggleAutoAdd(int id) async {
    final expense = await RecurringExpenseService.toggleAutoAdd(id);
    if (expense != null) {
      final index = _recurringExpenses.indexWhere((e) => e.id == id);
      if (index != -1) {
        _recurringExpenses[index] = expense;
        notifyListeners();
      }
      return true;
    }
    return false;
  }
}