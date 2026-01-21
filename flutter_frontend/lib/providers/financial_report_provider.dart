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
      // Jika pengguna telah memilih bulan spesifik, kita perlu mengirim informasi ini ke backend
      // Untuk sementara, kita tetap gunakan fungsi yang ada, namun nanti perlu diperbarui di backend
      // agar endpoint bisa menerima parameter bulan juga
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

  Future<void> fetchReportForSpecificMonth({String period = 'monthly', String? monthYear}) async {
    _isLoading = true;
    _selectedPeriod = period;
    notifyListeners();

    try {
      // Panggil endpoint dengan informasi bulan spesifik
      print('DEBUG: Calling getComprehensiveReportForSpecificMonth with period: $period, monthYear: $monthYear');
      final Response.ApiResponse response = await _apiRepository.getComprehensiveReportForSpecificMonth(period, monthYear);

      print('DEBUG: API Response success: ${response.success}');
      print('DEBUG: API Response data: ${response.data}');
      print('DEBUG: API Response message: ${response.message}');

      if (response.success) {
        _reportData = response.data;
        print('DEBUG: Setting report data to: $_reportData');
        _message = 'Report loaded successfully';
      } else {
        _message = response.message ?? 'Failed to load report';
      }
    } catch (e) {
      print('DEBUG: Error in fetchReportForSpecificMonth: $e');
      _message = 'Error loading report: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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