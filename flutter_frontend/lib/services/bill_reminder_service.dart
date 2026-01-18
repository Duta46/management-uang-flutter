import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/bill_reminder.dart';
import '../services/data_service.dart';
import '../utils/logger.dart';

class BillReminderService {
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

  static Future<BillReminderApiResponse> getAllBillReminders() async {
    try {
      Logger.api('GET request to: ${ApiConfig.baseUrl}/bill-reminders');
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/bill-reminders'),
        headers: await getHeaders(),
      );

      Logger.api('GET response status: ${response.statusCode}');
      Logger.api('GET response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BillReminderApiResponse.fromJson(data);
      } else {
        return BillReminderApiResponse(
          success: false,
          message: 'Error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e, stackTrace) {
      Logger.error('GET bill reminders failed: $e', stackTrace: stackTrace);
      return BillReminderApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  static Future<BillReminderApiResponse> createBillReminder(BillReminder billReminder) async {
    try {
      Logger.api('POST request to: ${ApiConfig.baseUrl}/bill-reminders with data: ${billReminder.toJson()}');
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/bill-reminders'),
        headers: await getHeaders(),
        body: json.encode(billReminder.toJson()),
      );

      Logger.api('POST response status: ${response.statusCode}');
      Logger.api('POST response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return BillReminderApiResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        Logger.error('Authentication failed when creating bill reminder. Status: ${response.statusCode}');
        return BillReminderApiResponse(
          success: false,
          message: 'Authentication failed. Please log in again.',
        );
      } else {
        Logger.error('Failed to create bill reminder. Status: ${response.statusCode}, Body: ${response.body}');
        return BillReminderApiResponse(
          success: false,
          message: 'Error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e, stackTrace) {
      Logger.error('CREATE bill reminder failed: $e', stackTrace: stackTrace);
      return BillReminderApiResponse(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  static Future<BillReminderApiResponse> updateBillReminder(BillReminder billReminder) async {
    try {
      Logger.api('PUT request to: ${ApiConfig.baseUrl}/bill-reminders/${billReminder.id} with data: ${billReminder.toJson()}');
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/bill-reminders/${billReminder.id}'),
        headers: await getHeaders(),
        body: json.encode(billReminder.toJson()),
      );

      Logger.api('PUT response status: ${response.statusCode}');
      Logger.api('PUT response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BillReminderApiResponse.fromJson(data);
      } else {
        return BillReminderApiResponse(
          success: false,
          message: 'Error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e, stackTrace) {
      Logger.error('UPDATE bill reminder failed: $e', stackTrace: stackTrace);
      return BillReminderApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  static Future<BillReminderApiResponse> deleteBillReminder(int id) async {
    try {
      Logger.api('DELETE request to: ${ApiConfig.baseUrl}/bill-reminders/$id');
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/bill-reminders/$id'),
        headers: await getHeaders(),
      );

      Logger.api('DELETE response status: ${response.statusCode}');
      Logger.api('DELETE response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BillReminderApiResponse.fromJson(data);
      } else {
        return BillReminderApiResponse(
          success: false,
          message: 'Error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e, stackTrace) {
      Logger.error('DELETE bill reminder failed: $e', stackTrace: stackTrace);
      return BillReminderApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  static Future<BillReminderApiResponse> getBillRemindersWithStatus() async {
    try {
      Logger.api('GET request to: ${ApiConfig.baseUrl}/bill-reminders-with-status');
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/bill-reminders-with-status'),
        headers: await getHeaders(),
      );

      Logger.api('GET response status: ${response.statusCode}');
      Logger.api('GET response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BillReminderApiResponse.fromJson(data);
      } else {
        return BillReminderApiResponse(
          success: false,
          message: 'Error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e, stackTrace) {
      Logger.error('GET bill reminders with status failed: $e', stackTrace: stackTrace);
      return BillReminderApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }
}