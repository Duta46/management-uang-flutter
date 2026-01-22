import 'dart:io';
import 'package:dio/dio.dart';
import '../models/api_models.dart' as Model;
import '../models/api_response.dart' as Response;
import '../config/api_config.dart';
import '../utils/error_handler.dart';
import 'base_repository.dart';

class ApiRepository extends BaseRepository {
  String get baseUrl {
    String url = ApiConfig.baseUrl;
    print('ApiRepository: Current baseUrl is $url');
    return url;
  }

  @override
  void setAuthToken(String? token) {
    super.setAuthToken(token);
  }

  Future<Response.ApiResponse> testConnection() async {
    try {
      final response = await dio.get('$baseUrl/health');
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  Future<Map<String, dynamic>> testLoginConnection(String email, String password) async {
    try {
      final response = await dio.post(
        '$baseUrl/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      return {
        'success': true,
        'data': response.data,
        'status_code': response.statusCode,
      };
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return {
        'success': false,
        'error': exception.message,
        'data': null,
      };
    }
  }

  Future<Response.ApiResponse> register(String name, String email, String password) async {
    try {
      final response = await dio.post(
        '$baseUrl/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        },
      );
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  Future<Response.ApiResponse> login(String email, String password) async {
    try {
      final response = await dio.post(
        '$baseUrl/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  Future<Response.ApiResponse> getCategories() async {
    try {
      final response = await dio.get('$baseUrl/categories');
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  Future<Response.ApiResponse> addCategory(String name, {bool isGlobal = false}) async {
    try {
      final response = await dio.post(
        '$baseUrl/categories',
        data: {
          'name': name,
          'is_global': isGlobal,
        },
      );
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  Future<Response.ApiResponse> updateCategory(int id, String name) async {
    try {
      final response = await dio.put(
        '$baseUrl/categories/$id',
        data: {
          'name': name,
        },
      );
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  Future<Response.ApiResponse> deleteCategory(int id) async {
    try {
      final response = await dio.delete('$baseUrl/categories/$id');
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  Future<Response.ApiResponse> getTransactions() async {
    try {
      final response = await dio.get('$baseUrl/transactions');
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  Future<Response.ApiResponse> createTransaction({
    required String amount,
    required String type,
    required int categoryId,
    int? billReminderId,
    int? savingsGoalId,
    String? description,
    String? date,
  }) async {
    try {
      final data = {
        'amount': amount,
        'type': type,
        'category_id': categoryId,
        'description': description ?? '',
        'date': date ?? DateTime.now().toIso8601String().split('T')[0],
      };

      if (billReminderId != null) {
        data['bill_reminder_id'] = billReminderId;
      }

      if (savingsGoalId != null) {
        data['savings_goal_id'] = savingsGoalId;
      }

      final response = await dio.post(
        '$baseUrl/transactions',
        data: data,
      );
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  Future<Response.ApiResponse> createTransactionSimple(int? categoryId, String amount, String type, String? description, String? date, {int? billReminderId, int? savingsGoalId}) async {
    try {
      final data = {
        'amount': amount,
        'type': type,
        'description': description ?? '',
        'date': date ?? DateTime.now().toIso8601String().split('T')[0],
      };

      // Hanya tambahkan category_id jika tidak null
      if (categoryId != null) {
        data['category_id'] = categoryId.toString();
      }

      if (billReminderId != null) {
        data['bill_reminder_id'] = billReminderId.toString();
      }

      if (savingsGoalId != null) {
        data['savings_goal_id'] = savingsGoalId.toString();
      }

      final response = await dio.post(
        '$baseUrl/transactions',
        data: data,
      );
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  Future<Response.ApiResponse> updateTransaction(int id, int? categoryId, String amount, String type, String? description, String? date, {int? billReminderId, int? savingsGoalId}) async {
    try {
      final data = {
        'amount': amount,
        'type': type,
        'description': description ?? '',
        'date': date ?? DateTime.now().toIso8601String().split('T')[0],
      };

      // Hanya tambahkan category_id jika tidak null
      if (categoryId != null) {
        data['category_id'] = categoryId.toString();
      }

      if (billReminderId != null) {
        data['bill_reminder_id'] = billReminderId.toString();
      }

      if (savingsGoalId != null) {
        data['savings_goal_id'] = savingsGoalId.toString();
      }

      final response = await dio.put(
        '$baseUrl/transactions/$id',
        data: data,
      );
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  Future<Response.ApiResponse> addTransaction(Model.Transaction transaction) async {
    try {
      final data = {
        'category_id': transaction.categoryId,
        'amount': transaction.amount,
        'type': transaction.type,
        'description': transaction.description ?? '',
        'date': transaction.date,
      };

      if (transaction.billReminderId != null) {
        data['bill_reminder_id'] = transaction.billReminderId;
      }

      if (transaction.savingsGoalId != null) {
        data['savings_goal_id'] = transaction.savingsGoalId;
      }

      final response = await dio.post(
        '$baseUrl/transactions',
        data: data,
      );
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  Future<Response.ApiResponse> deleteTransaction(int id) async {
    try {
      final response = await dio.delete('$baseUrl/transactions/$id');
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  Future<Response.ApiResponse> getMonthlyReport(int year, int month) async {
    try {
      final response = await dio.get(
        '$baseUrl/reports/monthly',
        queryParameters: {
          'year': year,
          'month': month,
        },
      );
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  Future<Response.ApiResponse> getDashboardSummary(int year, int month) async {
    try {
      final response = await dio.get(
        '$baseUrl/dashboard/summary',
        queryParameters: {
          'year': year,
          'month': month,
        },
      );
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  Future<Response.ApiResponse> getDashboardChart(int year, int month) async {
    try {
      final response = await dio.get(
        '$baseUrl/dashboard/chart',
        queryParameters: {
          'year': year,
          'month': month,
        },
      );
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  Future<Response.ApiResponse> healthCheck() async {
    try {
      final response = await dio.get('$baseUrl/health');
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  Future<Response.ApiResponse> logout() async {
    try {
      final response = await dio.post('$baseUrl/auth/logout');
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  Future<Response.ApiResponse> getProfile() async {
    try {
      final response = await dio.get('$baseUrl/auth/profile');
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  Future<Response.ApiResponse> updateProfile({
    String? name,
    String? email,
    String? profilePhoto,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (profilePhoto != null) data['profile_photo'] = profilePhoto;

      final response = await dio.put('$baseUrl/auth/profile', data: data);
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  Future<Response.ApiResponse> updateProfileWithPhoto({
    String? name,
    String? email,
    dynamic profileImage,
  }) async {
    try {
      FormData formData = FormData.fromMap({});

      print('Debug: Preparing form data for profile update');
      print('Debug: Name: $name, Email: $email, ProfileImage: $profileImage');

      if (name != null) {
        formData.fields.add(MapEntry('name', name));
        print('Debug: Added name to form data');
      }

      if (email != null) {
        formData.fields.add(MapEntry('email', email));
        print('Debug: Added email to form data');
      }

      if (profileImage != null) {
        print('Debug: Profile image is not null: $profileImage');
        if (profileImage is MultipartFile) {
          formData.files.add(MapEntry('profile_photo', profileImage));
          print('Debug: Added MultipartFile to form data');
        } else if (profileImage is String) {
          // If it's a file path, create MultipartFile from it
          File file = File(profileImage);
          String fileName = file.path.split('/').last;
          print('Debug: Creating MultipartFile from path: ${file.path}, filename: $fileName');
          formData.files.add(MapEntry('profile_photo', await MultipartFile.fromFile(file.path, filename: fileName)));
          print('Debug: Added file from path to form data');
        } else {
          print('Debug: Profile image is neither MultipartFile nor String: ${profileImage.runtimeType}');
        }
      } else {
        print('Debug: Profile image is null');
      }

      print('Debug: About to send request to $baseUrl/auth/profile');
      // Use POST instead of PUT for file uploads
      final response = await dio.post('$baseUrl/auth/profile', data: formData);
      print('Debug: Received response with status: ${response.statusCode}');
      print('Debug: Response data: ${response.data}');

      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      print('Debug: Error in updateProfileWithPhoto: $e');
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  Future<Response.ApiResponse> selfTest() async {
    try {
      final response = await dio.get('$baseUrl/self-test');
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  // AI Analysis Methods using Qwen AI via OpenRouter
  /*
   * Get financial insights using AI
   * Uses Qwen AI model via OpenRouter API for financial analysis
   */
  Future<Response.ApiResponse> getFinancialInsights({
    String analysisType = 'general',
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/ai-analysis/insights',
        queryParameters: {
          'type': analysisType,
          'start_date': startDate,
          'end_date': endDate,
        },
      );
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  /*
   * Get spending pattern analysis using AI
   * Uses Qwen AI model via OpenRouter API for spending pattern analysis
   */
  Future<Response.ApiResponse> getSpendingPatternAnalysis({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/ai-analysis/spending-pattern',
        queryParameters: {
          'start_date': startDate,
          'end_date': endDate,
        },
      );
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  /**
   * Get budget recommendations using AI
   * Uses Qwen AI model via OpenRouter API for budget recommendations
   */
  Future<Response.ApiResponse> getBudgetRecommendations({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/ai-analysis/budget-recommendations',
        queryParameters: {
          'start_date': startDate,
          'end_date': endDate,
        },
      );
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  /*
   * Get savings insights using AI
   * Uses Qwen AI model via OpenRouter API for savings analysis
   */
  Future<Response.ApiResponse> getSavingsInsights({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/ai-analysis/savings-insights',
        queryParameters: {
          'start_date': startDate,
          'end_date': endDate,
        },
      );
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  /*
   * Generate custom analysis using AI
   * Uses Qwen AI model via OpenRouter API for custom financial analysis
   */
  Future<Response.ApiResponse> generateAnalysis({
    String analysisType = 'general',
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/ai-analysis/generate',
        data: {
          'type': analysisType,
          'start_date': startDate,
          'end_date': endDate,
        },
      );
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  // Financial Chatbot Methods using Qwen AI via OpenRouter
  /*
   * Ask a question to the financial chatbot
   * Uses Qwen AI model via OpenRouter API for financial advice
   */
  Future<Response.ApiResponse> askChatbotQuestion(String question) async {
    try {
      print('Making request to: $baseUrl/chatbot/ask');
      print('Request data: {"question": "$question"}');

      final response = await dio.post(
        '$baseUrl/chatbot/ask',
        data: {
          'question': question,
        },
      );

      print('Received response: ${response.data}');
      print('Response status: ${response.statusCode}');

      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      print('Error in askChatbotQuestion: $e');
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  /*
   * Get chatbot conversation history
   * Retrieves previous conversations with the financial chatbot
   */
  Future<Response.ApiResponse> getChatbotHistory({int limit = 10, int page = 1}) async {
    try {
      final response = await dio.get(
        '$baseUrl/chatbot/history',
        queryParameters: {
          'limit': limit,
          'page': page,
        },
      );
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  // Ollama AI Integration Methods
  /*
   * Generate response using local Ollama model
   * Sends prompt to the local Ollama service via backend
   */
  Future<Response.ApiResponse> generateOllamaResponse({
    required String prompt,
    String? systemPrompt,
    Map<String, dynamic>? options,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/ollama/generate',
        data: {
          'prompt': prompt,
          'system_prompt': systemPrompt ?? 'You are a helpful assistant.',
          'options': options ?? {
            'temperature': 0.7,
            'max_tokens': 2048,
          }
        },
      );
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  /*
   * Generate financial insights using local Ollama model
   * Sends financial data to the local Ollama service via backend
   */
  Future<Response.ApiResponse> generateOllamaFinancialInsights({
    double? totalIncome,
    double? totalExpense,
    Map<String, dynamic>? categories,
    List<Map<String, dynamic>>? transactions,
    String? prompt,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/ollama/financial-insights',
        data: {
          'total_income': totalIncome,
          'total_expense': totalExpense,
          'categories': categories,
          'transactions': transactions,
          'prompt': prompt,
        },
      );
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  /*
   * Generate budget recommendations using local Ollama model
   * Sends financial data to the local Ollama service via backend
   */
  Future<Response.ApiResponse> generateOllamaBudgetRecommendations({
    double? totalIncome,
    Map<String, dynamic>? categories,
    String? prompt,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/ollama/budget-recommendations',
        data: {
          'total_income': totalIncome,
          'categories': categories,
          'prompt': prompt,
        },
      );
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  /*
   * Generate spending pattern analysis using local Ollama model
   * Sends financial data to the local Ollama service via backend
   */
  Future<Response.ApiResponse> generateOllamaSpendingPattern({
    List<Map<String, dynamic>>? transactions,
    Map<String, dynamic>? categories,
    Map<String, dynamic>? dailySpending,
    String? prompt,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/ollama/spending-pattern',
        data: {
          'transactions': transactions,
          'categories': categories,
          'daily_spending': dailySpending,
          'prompt': prompt,
        },
      );
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  /*
   * Test Ollama connection
   * Verifies that the local Ollama service is accessible via backend
   */
  Future<Response.ApiResponse> testOllamaConnection() async {
    try {
      final response = await dio.get('$baseUrl/ollama/test-connection');
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  /*
   * Get comprehensive financial report
   * Fetches detailed financial report data based on the specified period
   */
  Future<Response.ApiResponse> getComprehensiveReport(String period) async {
    try {
      final response = await dio.get('$baseUrl/financial-reports/comprehensive?period=$period');
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  /*
   * Get comprehensive financial report for specific month
   * Fetches detailed financial report data based on the specified period and month
   */
  Future<Response.ApiResponse> getComprehensiveReportForSpecificMonth(String period, String? monthYear) async {
    try {
      // Parse month and year from monthYear string (format: "Januari 2026")
      Map<String, dynamic>? queryParameters = {'period': period};

      if (monthYear != null && monthYear.isNotEmpty) {
        // Split the monthYear string to extract month and year
        List<String> parts = monthYear.split(' ');
        print('DEBUG API: Split monthYear: $monthYear, parts: $parts');

        if (parts.length >= 2) {
          String monthName = parts[0];
          String year = parts[1];
          print('DEBUG API: Extracted monthName: $monthName, year: $year');

          // Convert month name to number
          int monthNumber = _getMonthNumberFromName(monthName);
          print('DEBUG API: Converted monthNumber: $monthNumber');

          if (monthNumber > 0) {
            queryParameters['year'] = year;
            queryParameters['month'] = monthNumber.toString().padLeft(2, '0'); // Format as MM
            print('DEBUG API: Added to query params - year: $year, month: ${queryParameters['month']}');
          } else {
            print('DEBUG API: Invalid month name: $monthName');
          }
        } else {
          print('DEBUG API: Invalid monthYear format: $monthYear, parts length: ${parts.length}');
        }
      }

      print('DEBUG API: Request URL: $baseUrl/financial-reports/comprehensive');
      print('DEBUG API: Query parameters: $queryParameters');

      final response = await dio.get(
        '$baseUrl/financial-reports/comprehensive',
        queryParameters: queryParameters,
      );
      print('DEBUG API: Response status: ${response.statusCode}');
      print('DEBUG API: Response data: ${response.data}');

      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  int _getMonthNumberFromName(String monthName) {
    switch (monthName.toLowerCase()) {
      case 'januari': return 1;
      case 'februari': return 2;
      case 'maret': return 3;
      case 'april': return 4;
      case 'mei': return 5;
      case 'juni': return 6;
      case 'juli': return 7;
      case 'agustus': return 8;
      case 'september': return 9;
      case 'oktober': return 10;
      case 'november': return 11;
      case 'desember': return 12;
      default: return 0;
    }
  }

  /*
   * Get financial recommendations
   * Fetches AI-generated financial recommendations for the user
   */
  Future<Response.ApiResponse> getFinancialRecommendations() async {
    try {
      final response = await dio.get('$baseUrl/financial-analytics/recommendations');
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  /*
   * Get financial predictions
   * Fetches AI-generated financial predictions for the user
   */
  Future<Response.ApiResponse> getFinancialPredictions() async {
    try {
      final response = await dio.get('$baseUrl/financial-analytics/predictions');
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  /*
   * Get financial health score
   * Fetches the user's financial health score and related data
   */
  Future<Response.ApiResponse> getFinancialHealthScore() async {
    try {
      final response = await dio.get('$baseUrl/financial-analytics/health-score');
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  /*
   * Get savings goals
   * Fetches the user's savings goals
   */
  Future<Response.ApiResponse> getSavingsGoals() async {
    try {
      final response = await dio.get('$baseUrl/savings-goals');
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  /*
   * Get active savings goals (not achieved)
   * Fetches the user's active savings goals for use in transactions
   */
  Future<Response.ApiResponse> getActiveSavingsGoals() async {
    try {
      final response = await dio.get('$baseUrl/savings-goals-active');
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  /*
   * Create savings goal
   * Creates a new savings goal for the user
   */
  Future<Response.ApiResponse> createSavingsGoal({
    required String name,
    required double targetAmount,
    required DateTime targetDate,
    double currentAmount = 0.0,
    String? description,
  }) async {
    try {
      final response = await dio.post('$baseUrl/savings-goals', data: {
        'name': name,
        'target_amount': targetAmount.toStringAsFixed(2),
        'target_date': targetDate.toIso8601String().split('T')[0], // Format date as YYYY-MM-DD
        'current_amount': currentAmount.toStringAsFixed(2),
        if (description != null) 'description': description,
      });
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  /*
   * Update savings goal
   * Updates an existing savings goal
   */
  Future<Response.ApiResponse> updateSavingsGoal({
    required int id,
    required String name,
    required double targetAmount,
    required DateTime targetDate,
    double? currentAmount,
    String? description,
  }) async {
    try {
      final data = {
        'name': name,
        'target_amount': targetAmount.toStringAsFixed(2),
        'target_date': targetDate.toIso8601String().split('T')[0], // Format date as YYYY-MM-DD
        if (currentAmount != null) 'current_amount': currentAmount.toStringAsFixed(2),
        if (description != null) 'description': description,
      };

      final response = await dio.put('$baseUrl/savings-goals/$id', data: data);
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  /*
   * Delete savings goal
   * Deletes an existing savings goal
   */
  Future<Response.ApiResponse> deleteSavingsGoal(int id) async {
    try {
      final response = await dio.delete('$baseUrl/savings-goals/$id');
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  /*
   * Get bill reminders
   * Fetches the user's bill reminders
   */
  Future<Response.ApiResponse> getBillReminders() async {
    try {
      final response = await dio.get('$baseUrl/bill-reminders');
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  /*
   * Create bill reminder
   * Creates a new bill reminder for the user
   */
  Future<Response.ApiResponse> createBillReminder({
    required String name,
    required double amount,
    required DateTime dueDate,
    String? description,
    String frequency = 'monthly', // monthly, weekly, yearly, one_time
    bool isPaid = false,
    bool isActive = true,
    DateTime? nextDueDate,
  }) async {
    try {
      final response = await dio.post('$baseUrl/bill-reminders', data: {
        'name': name,
        'amount': amount,
        'due_date': dueDate.toIso8601String().split('T')[0], // Format date as YYYY-MM-DD
        'frequency': frequency,
        'is_paid': isPaid,
        'is_active': isActive,
        'next_due_date': nextDueDate?.toIso8601String().split('T')[0] ?? dueDate.toIso8601String().split('T')[0], // Use dueDate as default
        if (description != null) 'description': description,
      });
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  /*
   * Update bill reminder
   * Updates an existing bill reminder
   */
  Future<Response.ApiResponse> updateBillReminder({
    required int id,
    required String name,
    required double amount,
    required DateTime dueDate,
    String? description,
    String? frequency, // monthly, weekly, yearly, one_time
    bool? isPaid,
    bool? isActive,
    DateTime? nextDueDate,
  }) async {
    try {
      final data = {
        'name': name,
        'amount': amount,
        'due_date': dueDate.toIso8601String().split('T')[0], // Format date as YYYY-MM-DD
        if (frequency != null) 'frequency': frequency,
        if (isPaid != null) 'is_paid': isPaid,
        if (isActive != null) 'is_active': isActive,
        if (nextDueDate != null) 'next_due_date': nextDueDate.toIso8601String().split('T')[0],
        if (description != null) 'description': description,
      };

      final response = await dio.put('$baseUrl/bill-reminders/$id', data: data);
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  /*
   * Delete bill reminder
   * Deletes an existing bill reminder
   */
  Future<Response.ApiResponse> deleteBillReminder(int id) async {
    try {
      final response = await dio.delete('$baseUrl/bill-reminders/$id');
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }

  // Bill Reminder Notifications
  Future<Response.ApiResponse> getBillNotifications({int daysAhead = 7}) async {
    try {
      final response = await dio.get(
        '$baseUrl/dashboard/bill-notifications',
        queryParameters: {
          'days_ahead': daysAhead,
        },
      );
      return Response.ApiResponse.fromJson(response.data);
    } catch (e, stackTrace) {
      final exception = ErrorHandler.handle(e, stackTrace);
      return Response.ApiResponse.error(message: exception.message);
    }
  }
}