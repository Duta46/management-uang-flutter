import 'package:flutter/foundation.dart';
import '../repositories/api_repository.dart';
import '../models/api_response.dart' as Response;
import 'global_providers.dart';

class FinancialReportProvider extends ChangeNotifier {
  final ApiRepository _apiRepository = sharedApiRepository;
  var _reportData;
  bool _isLoading = false;
  String _message = '';
  String _selectedPeriod = 'monthly';
  String _selectedMonth = '';

  dynamic get reportData => _reportData;
  bool get isLoading => _isLoading;
  String get message => _message;
  String get selectedPeriod => _selectedPeriod;
  String get selectedMonth => _selectedMonth;

  Future<void> fetchReport({String period = 'monthly'}) async {
    _isLoading = true;
    _selectedPeriod = period;
    notifyListeners();

    try {
      final Response.ApiResponse response = await _apiRepository.getComprehensiveReport(period);
      
      if (response.success) {
        _reportData = response.data;
        _message = 'Report loaded successfully';
      } else {
        _message = response.message ?? 'Failed to load report';
      }
    } catch (e) {
      _message = 'Error loading report: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void changePeriod(String period) {
    _selectedPeriod = period;
    fetchReport(period: period);
  }

  void setMessage(String message) {
    _message = message;
    notifyListeners();
  }

  void setSelectedMonth(String month) {
    _selectedMonth = month;
    notifyListeners();
  }
}