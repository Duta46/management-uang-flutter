import 'package:flutter/foundation.dart';
import '../models/api_models.dart';
import '../repositories/api_repository.dart';
import '../models/api_response.dart' as Response;
import '../providers/global_providers.dart';

/**
 * AI Analysis Provider using Qwen AI via OpenRouter
 * This provider manages AI-generated financial insights and analysis
 */
class AiAnalysisProvider extends ChangeNotifier {
  final ApiRepository _apiRepository = sharedApiRepository;

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _currentInsights;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get currentInsights => _currentInsights;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  /**
   * Get financial insights using Qwen AI via OpenRouter
   * Fetches AI-generated financial analysis based on user's transaction data
   */
  Future<Map<String, dynamic>?> getFinancialInsights({
    String analysisType = 'general',
    String? startDate,
    String? endDate,
  }) async {
    setLoading(true);
    setErrorMessage(null);

    try {
      final Response.ApiResponse response = await _apiRepository.getFinancialInsights(
        analysisType: analysisType,
        startDate: startDate,
        endDate: endDate,
      );

      if (response.success && response.data != null) {
        _currentInsights = response.data!;
        setLoading(false);
        notifyListeners(); // Notify listeners that insights have been updated
        return response.data!;
      } else {
        setErrorMessage(response.message ?? 'Failed to get financial insights');
        setLoading(false);
        return null;
      }
    } catch (e) {
      setErrorMessage(e.toString());
      setLoading(false);
      return null;
    }
  }

  /**
   * Get spending pattern analysis using Qwen AI via OpenRouter
   * Analyzes user's spending patterns and provides insights
   */
  Future<Map<String, dynamic>?> getSpendingPatternAnalysis({
    String? startDate,
    String? endDate,
  }) async {
    setLoading(true);
    setErrorMessage(null);

    try {
      final Response.ApiResponse response = await _apiRepository.getSpendingPatternAnalysis(
        startDate: startDate,
        endDate: endDate,
      );

      if (response.success && response.data != null) {
        // Optionally store this as current insights if it's the most recently fetched data
        _currentInsights = response.data!;
        setLoading(false);
        notifyListeners();
        return response.data!;
      } else {
        setErrorMessage(response.message ?? 'Failed to get spending pattern analysis');
        setLoading(false);
        return null;
      }
    } catch (e) {
      setErrorMessage(e.toString());
      setLoading(false);
      return null;
    }
  }

  /**
   * Get budget recommendations using Qwen AI via OpenRouter
   * Provides AI-generated budget recommendations based on user's financial data
   */
  Future<Map<String, dynamic>?> getBudgetRecommendations({
    String? startDate,
    String? endDate,
  }) async {
    setLoading(true);
    setErrorMessage(null);

    try {
      final Response.ApiResponse response = await _apiRepository.getBudgetRecommendations(
        startDate: startDate,
        endDate: endDate,
      );

      if (response.success && response.data != null) {
        // Optionally store this as current insights if it's the most recently fetched data
        _currentInsights = response.data!;
        setLoading(false);
        notifyListeners();
        return response.data!;
      } else {
        setErrorMessage(response.message ?? 'Failed to get budget recommendations');
        setLoading(false);
        return null;
      }
    } catch (e) {
      setErrorMessage(e.toString());
      setLoading(false);
      return null;
    }
  }

  /**
   * Get savings insights using Qwen AI via OpenRouter
   * Provides AI-generated insights about user's savings patterns
   */
  Future<Map<String, dynamic>?> getSavingsInsights({
    String? startDate,
    String? endDate,
  }) async {
    setLoading(true);
    setErrorMessage(null);

    try {
      final Response.ApiResponse response = await _apiRepository.getSavingsInsights(
        startDate: startDate,
        endDate: endDate,
      );

      if (response.success && response.data != null) {
        // Optionally store this as current insights if it's the most recently fetched data
        _currentInsights = response.data!;
        setLoading(false);
        notifyListeners();
        return response.data!;
      } else {
        setErrorMessage(response.message ?? 'Failed to get savings insights');
        setLoading(false);
        return null;
      }
    } catch (e) {
      setErrorMessage(e.toString());
      setLoading(false);
      return null;
    }
  }

  /**
   * Generate custom analysis using Qwen AI via OpenRouter
   * Creates custom AI-generated financial analysis based on specified parameters
   */
  Future<Map<String, dynamic>?> generateAnalysis({
    String analysisType = 'general',
    String? startDate,
    String? endDate,
  }) async {
    setLoading(true);
    setErrorMessage(null);

    try {
      final Response.ApiResponse response = await _apiRepository.generateAnalysis(
        analysisType: analysisType,
        startDate: startDate,
        endDate: endDate,
      );

      if (response.success && response.data != null) {
        // Optionally store this as current insights if it's the most recently fetched data
        _currentInsights = response.data!;
        setLoading(false);
        notifyListeners();
        return response.data!;
      } else {
        setErrorMessage(response.message ?? 'Failed to generate analysis');
        setLoading(false);
        return null;
      }
    } catch (e) {
      setErrorMessage(e.toString());
      setLoading(false);
      return null;
    }
  }

  /**
   * Ask a question to the financial chatbot using Qwen AI via OpenRouter
   * Sends user's question to the AI and returns the response
   */
  Future<Map<String, dynamic>?> askChatbotQuestion(String question) async {
    setLoading(true);
    setErrorMessage(null);

    try {
      final Response.ApiResponse response = await _apiRepository.askChatbotQuestion(question);

      if (response.success && response.data != null) {
        setLoading(false);
        return response.data!;
      } else {
        setErrorMessage(response.message ?? 'Failed to get response from chatbot');
        setLoading(false);
        return null;
      }
    } catch (e) {
      setErrorMessage(e.toString());
      setLoading(false);
      return null;
    }
  }

  /**
   * Get chatbot conversation history
   * Retrieves previous conversations with the financial chatbot
   */
  Future<Map<String, dynamic>?> getChatbotHistory({int limit = 10, int page = 1}) async {
    setLoading(true);
    setErrorMessage(null);

    try {
      final Response.ApiResponse response = await _apiRepository.getChatbotHistory(limit: limit, page: page);

      if (response.success && response.data != null) {
        setLoading(false);
        return response.data!;
      } else {
        setErrorMessage(response.message ?? 'Failed to get chatbot history');
        setLoading(false);
        return null;
      }
    } catch (e) {
      setErrorMessage(e.toString());
      setLoading(false);
      return null;
    }
  }
}