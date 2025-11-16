import 'package:flutter/foundation.dart';
import '../models/financial_summary.dart';
import '../services/data_service.dart';

class FinancialSummaryProvider extends ChangeNotifier {
  FinancialSummary? _currentMonthSummary;
  FinancialSummary? _nextMonthSummary;
  List<FinancialSummary>? _monthlyData;
  bool _isLoading = false;
  String _message = '';

  FinancialSummary? get currentMonthSummary => _currentMonthSummary;
  FinancialSummary? get nextMonthSummary => _nextMonthSummary;
  List<FinancialSummary>? get monthlyData => _monthlyData;
  bool get isLoading => _isLoading;
  String get message => _message;

  Future<void> getFinancialSummary(int year, int month) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await DataService.getFinancialSummary(year: year, month: month);
      
      if (response.success && response.data != null) {
        _currentMonthSummary = response.data;
        _message = response.message;
      } else {
        _message = response.message;
      }
    } catch (e) {
      _message = 'Failed to get financial summary: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getMonthlyFinancialData(int year) async {
    _isLoading = true;
    notifyListeners();

    try {
      print("Requesting monthly financial data for year: $year"); // Debug log
      final response = await DataService.getMonthlyFinancialData(year: year);
      print("Response from API: ${response.success}, Message: ${response.message}"); // Debug log
      
      if (response.success) {
        _monthlyData = response.data?.monthlyData;
        _currentMonthSummary = response.data?.currentMonth;
        _nextMonthSummary = response.data?.nextMonth;
        _message = response.message;
        print("Monthly data loaded: ${_monthlyData?.length} months, Current month: ${_currentMonthSummary != null}"); // Debug log
      } else {
        _message = response.message;
        print("Failed to load monthly data: ${response.message}"); // Debug log
      }
    } catch (e) {
      _message = 'Failed to get monthly financial data: $e';
      print("Exception getting monthly financial data: $e"); // Debug log
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}