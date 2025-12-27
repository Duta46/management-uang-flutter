import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/api_response.dart' as Response;
import '../config/api_config.dart';
import '../utils/logger.dart';

class ApiService {
  static Future<Response.ApiResponse> get(String endpoint) async {
    try {
      Logger.api('GET request to: ${ApiConfig.baseUrl}$endpoint');
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
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
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
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
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
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
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
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
}