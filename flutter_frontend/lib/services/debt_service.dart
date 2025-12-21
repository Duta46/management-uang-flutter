import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/debt.dart';
import '../config/api_config.dart';
import '../config/api_service.dart';

class DebtService {
  static Future<DebtList?> getAllDebts({String? status}) async {
    try {
      String url = '${ApiConfig.baseUrl}/debts';
      if (status != null) {
        url += '?status=$status';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: await ApiService.getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DebtList.fromJson(data['data']);
      } else {
        throw Exception('Failed to load debts: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting debts: $e');
      return null;
    }
  }

  static Future<Debt?> createDebt({
    required String creditorName,
    required double amount,
    required DateTime dueDate,
    String? status,
    String? notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/debts'),
        headers: await ApiService.getHeaders(),
        body: json.encode({
          'creditor_name': creditorName,
          'amount': amount,
          'due_date': dueDate.toIso8601String().split('T')[0],
          'status': status ?? 'unpaid',
          'notes': notes,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Debt.fromJson(data['data']);
      } else {
        throw Exception('Failed to create debt: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating debt: $e');
      return null;
    }
  }

  static Future<Debt?> updateDebt({
    required int id,
    String? creditorName,
    double? amount,
    DateTime? dueDate,
    String? status,
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (creditorName != null) body['creditor_name'] = creditorName;
      if (amount != null) body['amount'] = amount;
      if (dueDate != null) body['due_date'] = dueDate.toIso8601String().split('T')[0];
      if (status != null) body['status'] = status;
      if (notes != null) body['notes'] = notes;

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/debts/$id'),
        headers: await ApiService.getHeaders(),
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Debt.fromJson(data['data']);
      } else {
        throw Exception('Failed to update debt: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating debt: $e');
      return null;
    }
  }

  static Future<bool> deleteDebt(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/debts/$id'),
        headers: await ApiService.getHeaders(),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting debt: $e');
      return false;
    }
  }

  static Future<Debt?> markDebtAsPaid(int id) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/debts/$id/mark-paid'),
        headers: await ApiService.getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Debt.fromJson(data['data']);
      } else {
        throw Exception('Failed to mark debt as paid: ${response.statusCode}');
      }
    } catch (e) {
      print('Error marking debt as paid: $e');
      return null;
    }
  }
}