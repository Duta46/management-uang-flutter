import 'package:flutter/foundation.dart';
import '../models/bill_reminder.dart';
import '../repositories/api_repository.dart';
import '../models/api_response.dart' as Response;
import 'global_providers.dart';

class BillReminderProvider extends ChangeNotifier {
  final ApiRepository _apiRepository = sharedApiRepository;
  List<BillReminder> _billReminders = [];
  bool _isLoading = false;
  String _message = '';

  List<BillReminder> get billReminders => _billReminders;
  bool get isLoading => _isLoading;
  String get message => _message;

  List<BillReminder> get activeBills {
    final now = DateTime.now();
    return _billReminders.where((bill) =>
      bill.dueDate != null &&
      bill.dueDate!.isNotEmpty &&
      DateTime.tryParse(bill.dueDate!)!.isAfter(now) &&
      bill.isPaid != true
    ).toList();
  }

  Future<void> fetchBillReminders() async {
    _isLoading = true;
    notifyListeners();

    try {
      final Response.ApiResponse response = await _apiRepository.getBillReminders();
      
      if (response.success) {
        if (response.data is List) {
          _billReminders = (response.data as List)
              .map((item) => BillReminder.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          final billRemindersData = data['data'] as List<dynamic>?;
          
          if (billRemindersData != null) {
            _billReminders = billRemindersData
                .map((item) => BillReminder.fromJson(item as Map<String, dynamic>))
                .toList();
          } else {
            _billReminders = [];
          }
        }
        _message = 'Bill reminders loaded successfully (${_billReminders.length} items)';
      } else {
        _message = response.message ?? 'Failed to load bill reminders';
      }
    } catch (e) {
      _message = 'Error loading bill reminders: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createBillReminder({
    required String name,
    required double amount,
    required DateTime dueDate,
    String? description,
    String frequency = 'monthly',
    bool isPaid = false,
    bool isActive = true,
    DateTime? nextDueDate,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiRepository.createBillReminder(
        name: name,
        amount: amount,
        dueDate: dueDate,
        description: description,
        frequency: frequency,
        isPaid: isPaid,
        isActive: isActive,
        nextDueDate: nextDueDate,
      );

      if (response.success) {
        await fetchBillReminders(); // Refresh the list
        _message = 'Bill reminder created successfully';
        return true;
      } else {
        _message = response.message ?? 'Failed to create bill reminder';
        return false;
      }
    } catch (e) {
      _message = 'Error creating bill reminder: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateBillReminder({
    required int id,
    required String name,
    required double amount,
    required DateTime dueDate,
    String? description,
    String? frequency,
    bool? isPaid,
    bool? isActive,
    DateTime? nextDueDate,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiRepository.updateBillReminder(
        id: id,
        name: name,
        amount: amount,
        dueDate: dueDate,
        description: description,
        frequency: frequency,
        isPaid: isPaid,
        isActive: isActive,
        nextDueDate: nextDueDate,
      );

      if (response.success) {
        await fetchBillReminders(); // Refresh the list
        _message = 'Bill reminder updated successfully';
        return true;
      } else {
        _message = response.message ?? 'Failed to update bill reminder';
        return false;
      }
    } catch (e) {
      _message = 'Error updating bill reminder: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteBillReminder(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiRepository.deleteBillReminder(id);

      if (response.success) {
        await fetchBillReminders(); // Refresh the list
        _message = 'Bill reminder deleted successfully';
        return true;
      } else {
        _message = response.message ?? 'Failed to delete bill reminder';
        return false;
      }
    } catch (e) {
      _message = 'Error deleting bill reminder: $e';
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