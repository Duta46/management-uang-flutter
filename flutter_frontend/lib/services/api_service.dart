import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/api_response.dart' as Response;
import '../config/api_config.dart';
import '../utils/logger.dart';
import '../models/budget.dart';
import '../models/savings_goal.dart';
import '../models/bill_reminder.dart';
import '../services/data_service.dart';

class ApiService {
  static Future<Map<String, String>> getHeaders() async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    String? token = DataService.getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Future<Response.ApiResponse> get(String endpoint) async {
    try {
      Logger.api('GET request to: ${ApiConfig.baseUrl}$endpoint');
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: await getHeaders(),
      );

      Logger.api('GET response status: ${response.statusCode}');
      Logger.api('GET response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Response.ApiResponse.fromJson(data);
      } else {
        return Response.ApiResponse(
          success: false,
          message: 'Error: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      Logger.error('GET request failed: $e', stackTrace: stackTrace);
      return Response.ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  static Future<Response.ApiResponse> post(String endpoint, Map<String, dynamic> data) async {
    try {
      Logger.api('POST request to: ${ApiConfig.baseUrl}$endpoint with data: $data');
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: await getHeaders(),
        body: jsonEncode(data),
      );

      Logger.api('POST response status: ${response.statusCode}');
      Logger.api('POST response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return Response.ApiResponse.fromJson(responseData);
      } else {
        return Response.ApiResponse(
          success: false,
          message: 'Error: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      Logger.error('POST request failed: $e', stackTrace: stackTrace);
      return Response.ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  static Future<Response.ApiResponse> put(String endpoint, Map<String, dynamic> data) async {
    try {
      Logger.api('PUT request to: ${ApiConfig.baseUrl}$endpoint with data: $data');
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: await getHeaders(),
        body: jsonEncode(data),
      );

      Logger.api('PUT response status: ${response.statusCode}');
      Logger.api('PUT response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return Response.ApiResponse.fromJson(responseData);
      } else {
        return Response.ApiResponse(
          success: false,
          message: 'Error: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      Logger.error('PUT request failed: $e', stackTrace: stackTrace);
      return Response.ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  static Future<Response.ApiResponse> delete(String endpoint) async {
    try {
      Logger.api('DELETE request to: ${ApiConfig.baseUrl}$endpoint');
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: await getHeaders(),
      );

      Logger.api('DELETE response status: ${response.statusCode}');
      Logger.api('DELETE response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return Response.ApiResponse.fromJson(responseData);
      } else {
        return Response.ApiResponse(
          success: false,
          message: 'Error: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      Logger.error('DELETE request failed: $e', stackTrace: stackTrace);
      return Response.ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  // Budget methods
  Future<BudgetApiResponse> getBudets() async {
    try {
      final response = await get('/budgets');
      if (response.success) {
        return BudgetApiResponse.fromJson(response.data);
      } else {
        return BudgetApiResponse(success: false, message: response.message);
      }
    } catch (e) {
      return BudgetApiResponse(success: false, message: e.toString());
    }
  }

  Future<BudgetApiResponse> createBudget(Budget budget) async {
    try {
      final response = await post('/budgets', budget.toJson());
      if (response.success) {
        return BudgetApiResponse.fromJson(response.data);
      } else {
        return BudgetApiResponse(success: false, message: response.message);
      }
    } catch (e) {
      return BudgetApiResponse(success: false, message: e.toString());
    }
  }

  Future<BudgetApiResponse> updateBudget(Budget budget) async {
    try {
      final response = await put('/budgets/${budget.id}', budget.toJson());
      if (response.success) {
        return BudgetApiResponse.fromJson(response.data);
      } else {
        return BudgetApiResponse(success: false, message: response.message);
      }
    } catch (e) {
      return BudgetApiResponse(success: false, message: e.toString());
    }
  }

  Future<BudgetApiResponse> deleteBudget(int id) async {
    try {
      final response = await delete('/budgets/$id');
      if (response.success) {
        return BudgetApiResponse.fromJson(response.data);
      } else {
        return BudgetApiResponse(success: false, message: response.message);
      }
    } catch (e) {
      return BudgetApiResponse(success: false, message: e.toString());
    }
  }

  // Savings Goal methods
  Future<SavingsGoalApiResponse> getSavingsGoals() async {
    try {
      final response = await get('/savings-goals');
      if (response.success) {
        return SavingsGoalApiResponse.fromJson(response.data);
      } else {
        return SavingsGoalApiResponse(success: false, message: response.message);
      }
    } catch (e) {
      return SavingsGoalApiResponse(success: false, message: e.toString());
    }
  }

  Future<SavingsGoalApiResponse> getActiveSavingsGoals() async {
    try {
      final response = await get('/savings-goals-active');
      if (response.success) {
        return SavingsGoalApiResponse.fromJson(response.data);
      } else {
        return SavingsGoalApiResponse(success: false, message: response.message);
      }
    } catch (e) {
      return SavingsGoalApiResponse(success: false, message: e.toString());
    }
  }

  Future<SavingsGoalApiResponse> createSavingsGoal(SavingsGoal savingsGoal) async {
    try {
      final response = await post('/savings-goals', savingsGoal.toJson());
      if (response.success) {
        return SavingsGoalApiResponse.fromJson(response.data);
      } else {
        return SavingsGoalApiResponse(success: false, message: response.message);
      }
    } catch (e) {
      return SavingsGoalApiResponse(success: false, message: e.toString());
    }
  }

  Future<SavingsGoalApiResponse> updateSavingsGoal(SavingsGoal savingsGoal) async {
    try {
      final response = await put('/savings-goals/${savingsGoal.id}', savingsGoal.toJson());
      if (response.success) {
        return SavingsGoalApiResponse.fromJson(response.data);
      } else {
        return SavingsGoalApiResponse(success: false, message: response.message);
      }
    } catch (e) {
      return SavingsGoalApiResponse(success: false, message: e.toString());
    }
  }

  Future<SavingsGoalApiResponse> deleteSavingsGoal(int id) async {
    try {
      final response = await delete('/savings-goals/$id');
      if (response.success) {
        return SavingsGoalApiResponse.fromJson(response.data);
      } else {
        return SavingsGoalApiResponse(success: false, message: response.message);
      }
    } catch (e) {
      return SavingsGoalApiResponse(success: false, message: e.toString());
    }
  }

  // Bill Reminder methods
  Future<BillReminderApiResponse> getBillReminders() async {
    try {
      final response = await get('/bill-reminders');
      if (response.success) {
        return BillReminderApiResponse.fromJson(response.data);
      } else {
        return BillReminderApiResponse(success: false, message: response.message);
      }
    } catch (e) {
      return BillReminderApiResponse(success: false, message: e.toString());
    }
  }

  Future<BillReminderApiResponse> createBillReminder(BillReminder billReminder) async {
    try {
      final response = await post('/bill-reminders', billReminder.toJson());
      if (response.success) {
        return BillReminderApiResponse.fromJson(response.data);
      } else {
        return BillReminderApiResponse(success: false, message: response.message);
      }
    } catch (e) {
      return BillReminderApiResponse(success: false, message: e.toString());
    }
  }

  Future<BillReminderApiResponse> updateBillReminder(BillReminder billReminder) async {
    try {
      final response = await put('/bill-reminders/${billReminder.id}', billReminder.toJson());
      if (response.success) {
        return BillReminderApiResponse.fromJson(response.data);
      } else {
        return BillReminderApiResponse(success: false, message: response.message);
      }
    } catch (e) {
      return BillReminderApiResponse(success: false, message: e.toString());
    }
  }

  Future<BillReminderApiResponse> deleteBillReminder(int id) async {
    try {
      final response = await delete('/bill-reminders/$id');
      if (response.success) {
        return BillReminderApiResponse.fromJson(response.data);
      } else {
        return BillReminderApiResponse(success: false, message: response.message);
      }
    } catch (e) {
      return BillReminderApiResponse(success: false, message: e.toString());
    }
  }

  // Financial Report methods
  Future<Response.ApiResponse> getComprehensiveReport(String period) async {
    try {
      final response = await get('/financial-reports/comprehensive?period=$period');
      return response;
    } catch (e) {
      return Response.ApiResponse(success: false, message: e.toString());
    }
  }

  // Category methods
  Future<Response.ApiResponse> getCategories() async {
    try {
      final response = await get('/categories');
      return response;
    } catch (e) {
      return Response.ApiResponse(success: false, message: e.toString());
    }
  }

  // Financial Analytics methods
  Future<Response.ApiResponse> getFinancialInsights() async {
    try {
      final response = await get('/financial-analytics/insights');
      return response;
    } catch (e) {
      return Response.ApiResponse(success: false, message: e.toString());
    }
  }

  Future<Response.ApiResponse> getFinancialRecommendations() async {
    try {
      final response = await get('/financial-analytics/recommendations');
      return response;
    } catch (e) {
      return Response.ApiResponse(success: false, message: e.toString());
    }
  }

  Future<Response.ApiResponse> getFinancialPredictions() async {
    try {
      final response = await get('/financial-analytics/predictions');
      return response;
    } catch (e) {
      return Response.ApiResponse(success: false, message: e.toString());
    }
  }

  Future<Response.ApiResponse> getFinancialHealthScore() async {
    try {
      final response = await get('/financial-analytics/health-score');
      return response;
    } catch (e) {
      return Response.ApiResponse(success: false, message: e.toString());
    }
  }

  // Notification methods
  Future<Response.ApiResponse> getUnreadNotifications() async {
    try {
      final response = await get('/financial-notifications/unread');
      return response;
    } catch (e) {
      return Response.ApiResponse(success: false, message: e.toString());
    }
  }

  // Profile methods
  Future<Response.ApiResponse> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await post('/profile/update', data);
      return response;
    } catch (e) {
      return Response.ApiResponse(success: false, message: e.toString());
    }
  }

  // Category methods
  Future<Response.ApiResponse> createCategory(Map<String, dynamic> data) async {
    try {
      final response = await post('/categories', data);
      return response;
    } catch (e) {
      return Response.ApiResponse(success: false, message: e.toString());
    }
  }

  Future<Response.ApiResponse> deleteCategory(int id) async {
    try {
      final response = await delete('/categories/$id');
      return response;
    } catch (e) {
      return Response.ApiResponse(success: false, message: e.toString());
    }
  }
}