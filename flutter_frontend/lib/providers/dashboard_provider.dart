import 'package:flutter/foundation.dart';
import '../repositories/api_repository.dart';
import '../models/api_models.dart';
import 'global_providers.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiRepository _apiRepository = sharedApiRepository;
  Map<String, dynamic> _state = {};

  Map<String, dynamic> get state => _state;

  Future<void> fetchDashboardSummary(int year, int month) async {
    final response = await _apiRepository.getDashboardSummary(year, month);

    if (response.success && response.data != null) {
      _state = {
        'summary': response.data['data'],
        'lastUpdated': DateTime.now(),
      };
      notifyListeners();
    }
  }

  Future<void> fetchDashboardChart(int year, int month) async {
    final response = await _apiRepository.getDashboardChart(year, month);

    if (response.success && response.data != null) {
      _state = {
        ..._state,
        'chart': response.data['data'],
        'lastUpdated': DateTime.now(),
      };
      notifyListeners();
    }
  }
}