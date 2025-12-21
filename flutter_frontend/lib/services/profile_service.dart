import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../config/api_config.dart';
import '../config/api_service.dart';

class ProfileService {
  static Future<User?> updateAutoSaveSettings({
    double? autoSavePercentage,
    double? autoSaveFixedAmount,
    int? autoSavePercentageSavingId,
    int? autoSaveFixedAmountSavingId,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/profile'),
        headers: await ApiService.getHeaders(),
        body: json.encode({
          'auto_save_percentage': autoSavePercentage,
          'auto_save_fixed_amount': autoSaveFixedAmount,
          'auto_save_percentage_saving_id': autoSavePercentageSavingId,
          'auto_save_fixed_amount_saving_id': autoSaveFixedAmountSavingId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data['data']);
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating profile: $e');
      return null;
    }
  }

  static Future<User?> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/profile'),
        headers: await ApiService.getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data['data']);
      } else {
        throw Exception('Failed to get profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }
}