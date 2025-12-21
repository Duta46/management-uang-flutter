import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dashboard_summary.dart';
import '../models/report.dart';
import '../config/api_config.dart';
import '../config/api_service.dart';

class DashboardService {
  static Future<DashboardSummary?> getDashboardSummary() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/dashboard/summary'),
        headers: await ApiService.getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DashboardSummary.fromJson(data['data']);
      } else {
        throw Exception('Failed to load dashboard summary: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting dashboard summary: $e');
      return null;
    }
  }
}

class ReportService {
  static Future<ReportData?> getMonthlyReport({String? month, String? year}) async {
    try {
      String url = '${ApiConfig.baseUrl}/reports/monthly';
      if (month != null) url += '?month=$month';
      if (year != null) {
        url += month != null ? '&year=$year' : '?year=$year';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: await ApiService.getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ReportData.fromJson(data['data']);
      } else {
        throw Exception('Failed to load monthly report: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting monthly report: $e');
      return null;
    }
  }

  static Future<WeeklyReportData?> getWeeklyReport({String? startDate}) async {
    try {
      String url = '${ApiConfig.baseUrl}/reports/weekly';
      if (startDate != null) {
        url += '?start_date=$startDate';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: await ApiService.getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeeklyReportData.fromJson(data['data']);
      } else {
        throw Exception('Failed to load weekly report: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting weekly report: $e');
      return null;
    }
  }

  static Future<CategoryReportData?> getCategoryReport({String? type, String? month, String? year}) async {
    try {
      String url = '${ApiConfig.baseUrl}/reports/category';
      if (type != null) url += '?type=$type';
      if (month != null) {
        url += type != null ? '&month=$month' : '?month=$month';
      }
      if (year != null) {
        url += (type != null || month != null) ? '&year=$year' : '?year=$year';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: await ApiService.getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CategoryReportData.fromJson(data['data']);
      } else {
        throw Exception('Failed to load category report: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting category report: $e');
      return null;
    }
  }
}