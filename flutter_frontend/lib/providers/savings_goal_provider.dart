import 'package:flutter/foundation.dart';
import '../models/savings_goal.dart';
import '../repositories/api_repository.dart';
import '../models/api_response.dart' as Response;
import 'global_providers.dart';

class SavingsGoalProvider extends ChangeNotifier {
  final ApiRepository _apiRepository = sharedApiRepository;
  List<SavingsGoal> _savingsGoals = [];
  bool _isLoading = false;
  String _message = '';

  List<SavingsGoal> get savingsGoals => _savingsGoals;
  bool get isLoading => _isLoading;
  String get message => _message;

  List<SavingsGoal> get activeSavingsGoals {
    return _savingsGoals.where((goal) => goal.status != 'completed' && goal.status != 'achieved').toList();
  }

  Future<void> fetchSavingsGoals() async {
    _isLoading = true;
    notifyListeners();

    try {
      final Response.ApiResponse response = await _apiRepository.getSavingsGoals();
      
      if (response.success) {
        if (response.data is List) {
          _savingsGoals = (response.data as List)
              .map((item) => SavingsGoal.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          final savingsGoalsData = data['data'] as List<dynamic>?;
          
          if (savingsGoalsData != null) {
            _savingsGoals = savingsGoalsData
                .map((item) => SavingsGoal.fromJson(item as Map<String, dynamic>))
                .toList();
          } else {
            _savingsGoals = [];
          }
        }
        _message = 'Savings goals loaded successfully (${_savingsGoals.length} items)';
      } else {
        _message = response.message ?? 'Failed to load savings goals';
      }
    } catch (e) {
      _message = 'Error loading savings goals: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createSavingsGoal({
    required String name,
    required double targetAmount,
    required DateTime targetDate,
    double currentAmount = 0.0,
    String? description,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiRepository.createSavingsGoal(
        name: name,
        targetAmount: targetAmount,
        targetDate: targetDate,
        currentAmount: currentAmount,
        description: description,
      );

      if (response.success) {
        await fetchSavingsGoals(); // Refresh the list
        _message = 'Savings goal created successfully';
        return true;
      } else {
        _message = response.message ?? 'Failed to create savings goal';
        return false;
      }
    } catch (e) {
      _message = 'Error creating savings goal: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateSavingsGoal({
    required int id,
    required String name,
    required double targetAmount,
    required DateTime targetDate,
    double? currentAmount,
    String? description,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiRepository.updateSavingsGoal(
        id: id,
        name: name,
        targetAmount: targetAmount,
        targetDate: targetDate,
        currentAmount: currentAmount,
        description: description,
      );

      if (response.success) {
        await fetchSavingsGoals(); // Refresh the list
        _message = 'Savings goal updated successfully';
        return true;
      } else {
        _message = response.message ?? 'Failed to update savings goal';
        return false;
      }
    } catch (e) {
      _message = 'Error updating savings goal: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteSavingsGoal(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiRepository.deleteSavingsGoal(id);

      if (response.success) {
        await fetchSavingsGoals(); // Refresh the list
        _message = 'Savings goal deleted successfully';
        return true;
      } else {
        _message = response.message ?? 'Failed to delete savings goal';
        return false;
      }
    } catch (e) {
      _message = 'Error deleting savings goal: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setMessage(String message) {
    _message = message;
    notifyListeners();
  }
}