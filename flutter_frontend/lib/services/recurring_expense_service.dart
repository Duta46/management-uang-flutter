import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recurring_expense.dart';
import '../config/api_config.dart';
import '../config/api_service.dart';

class RecurringExpenseService {
  static Future<RecurringExpenseList?> getAllRecurringExpenses() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/recurring-expenses'),
        headers: await ApiService.getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RecurringExpenseList.fromJson(data['data']);
      } else {
        throw Exception('Failed to load recurring expenses: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting recurring expenses: $e');
      return null;
    }
  }

  static Future<RecurringExpense?> createRecurringExpense({
    required String name,
    required double amount,
    required String cycle,
    required DateTime nextRunDate,
    bool autoAdd = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/recurring-expenses'),
        headers: await ApiService.getHeaders(),
        body: json.encode({
          'name': name,
          'amount': amount,
          'cycle': cycle,
          'next_run_date': nextRunDate.toIso8601String().split('T')[0],
          'auto_add': autoAdd,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return RecurringExpense.fromJson(data['data']);
      } else {
        throw Exception('Failed to create recurring expense: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating recurring expense: $e');
      return null;
    }
  }

  static Future<RecurringExpense?> updateRecurringExpense({
    required int id,
    String? name,
    double? amount,
    String? cycle,
    DateTime? nextRunDate,
    bool? autoAdd,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (amount != null) body['amount'] = amount;
      if (cycle != null) body['cycle'] = cycle;
      if (nextRunDate != null) body['next_run_date'] = nextRunDate.toIso8601String().split('T')[0];
      if (autoAdd != null) body['auto_add'] = autoAdd;

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/recurring-expenses/$id'),
        headers: await ApiService.getHeaders(),
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RecurringExpense.fromJson(data['data']);
      } else {
        throw Exception('Failed to update recurring expense: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating recurring expense: $e');
      return null;
    }
  }

  static Future<bool> deleteRecurringExpense(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/recurring-expenses/$id'),
        headers: await ApiService.getHeaders(),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting recurring expense: $e');
      return false;
    }
  }

  static Future<RecurringExpense?> toggleAutoAdd(int id) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/recurring-expenses/$id/toggle-auto-add'),
        headers: await ApiService.getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RecurringExpense.fromJson(data['data']);
      } else {
        throw Exception('Failed to toggle auto add: ${response.statusCode}');
      }
    } catch (e) {
      print('Error toggling auto add: $e');
      return null;
    }
  }
}