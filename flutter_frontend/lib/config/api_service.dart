import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
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

     static Future<http.Response> get(String endpoint) async {
        final response = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/$endpoint'),
          headers: await getHeaders(),
        );
        return response;
      }

      static Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/$endpoint'),
          headers: await getHeaders(),
          body: jsonEncode(data),
        );
        return response;
      }

      static Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
        final response = await http.put(
          Uri.parse('${ApiConfig.baseUrl}/$endpoint'),
          headers: await getHeaders(),
          body: jsonEncode(data),
        );
        return response;
      }

      static Future<http.Response> delete(String endpoint) async {
       final response = await http.delete(
          Uri.parse('${ApiConfig.baseUrl}/$endpoint'),
          headers: await getHeaders(),
        );
        return response;
      }
    }