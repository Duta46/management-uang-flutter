import 'package:flutter/foundation.dart';
import 'dart:async';
import '../repositories/api_repository.dart';
import '../models/api_response.dart' as Response;
import 'global_providers.dart';

class FinancialHealthProvider extends ChangeNotifier {
  final ApiRepository _apiRepository = sharedApiRepository;
  Map<String, dynamic>? _healthData;
  bool _isLoading = false;
  String _message = '';
  Timer? _refreshTimer;

  Map<String, dynamic>? get healthData => _healthData;
  bool get isLoading => _isLoading;
  String get message => _message;

  Future<void> fetchHealthData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final Response.ApiResponse response = await _apiRepository.getFinancialHealthScore();

      if (response.success) {
        _healthData = response.data as Map<String, dynamic>?;
        _message = 'Financial health data loaded successfully';
      } else {
        _message = response.message ?? 'Failed to load financial health data';
      }
    } catch (e) {
      _message = 'Error loading financial health data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fungsi untuk memulai refresh otomatis
  void startAutoRefresh(int intervalMinutes) {
    stopAutoRefresh(); // Hentikan timer sebelumnya jika ada

    _refreshTimer = Timer.periodic(Duration(minutes: intervalMinutes), (timer) {
      fetchHealthData();
    });
  }

  // Fungsi untuk menghentikan refresh otomatis
  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  void setMessage(String message) {
    _message = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}