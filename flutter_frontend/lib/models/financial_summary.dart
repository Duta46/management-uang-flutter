class FinancialSummary {
  final String month;
  final int year;
  final double totalIncome;
  final double totalExpense;
  final double netTotal;
  final double totalSaving;

  FinancialSummary({
    required this.month,
    required this.year,
    required this.totalIncome,
    required this.totalExpense,
    required this.netTotal,
    required this.totalSaving,
  });

  factory FinancialSummary.fromJson(dynamic json) {
    return FinancialSummary(
      month: json['month'] as String? ?? '',
      year: json['year'] as int? ?? 0,
      totalIncome: (json['total_income'] as num?)?.toDouble() ?? 0.0,
      totalExpense: (json['total_expense'] as num?)?.toDouble() ?? 0.0,
      netTotal: (json['net_total'] as num?)?.toDouble() ?? 0.0,
      totalSaving: (json['total_saving'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'year': year,
      'total_income': totalIncome,
      'total_expense': totalExpense,
      'net_total': netTotal,
      'total_saving': totalSaving,
    };
  }
}

class FinancialSummaryResponse {
  final bool success;
  final FinancialSummary? data;
  final String message;

  FinancialSummaryResponse({
    required this.success,
    this.data,
    required this.message,
  });

  factory FinancialSummaryResponse.fromJson(dynamic json) {
    FinancialSummary? summary;
    if (json['data'] != null) {
      summary = FinancialSummary.fromJson(json['data']);
    }

    return FinancialSummaryResponse(
      success: json['success'] as bool,
      data: summary,
      message: json['message'] as String,
    );
  }
}

class MonthlyFinancialData {
  final List<FinancialSummary>? monthlyData;
  final FinancialSummary? currentMonth;
  final FinancialSummary? nextMonth;

  MonthlyFinancialData({
    this.monthlyData,
    this.currentMonth,
    this.nextMonth,
  });

  factory MonthlyFinancialData.fromJson(dynamic json) {
    List<FinancialSummary>? monthlyData;
    if (json['monthly_data'] is List) {
      monthlyData = (json['monthly_data'] as List)
          .map((e) => FinancialSummary.fromJson(e))
          .toList();
    }

    return MonthlyFinancialData(
      monthlyData: monthlyData,
      currentMonth: json['current_month'] != null
          ? FinancialSummary.fromJson(json['current_month'])
          : null,
      nextMonth: json['next_month'] != null
          ? FinancialSummary.fromJson(json['next_month'])
          : null,
    );
  }
}

class YearlyFinancialData {
  final int year;
  final double totalIncome;
  final double totalExpense;
  final double netTotal;
  final double totalSaving;

  YearlyFinancialData({
    required this.year,
    required this.totalIncome,
    required this.totalExpense,
    required this.netTotal,
    required this.totalSaving,
  });

  factory YearlyFinancialData.fromJson(dynamic json) {
    return YearlyFinancialData(
      year: json['year'] as int? ?? 0,
      totalIncome: (json['total_income'] as num?)?.toDouble() ?? 0.0,
      totalExpense: (json['total_expense'] as num?)?.toDouble() ?? 0.0,
      netTotal: (json['net_total'] as num?)?.toDouble() ?? 0.0,
      totalSaving: (json['total_saving'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'total_income': totalIncome,
      'total_expense': totalExpense,
      'net_total': netTotal,
      'total_saving': totalSaving,
    };
  }
}

class MonthlyFinancialDataResponse {
  final bool success;
  final MonthlyFinancialData? data;
  final String message;

  MonthlyFinancialDataResponse({
    required this.success,
    this.data,
    required this.message,
  });

  factory MonthlyFinancialDataResponse.fromJson(dynamic json) {
    MonthlyFinancialData? monthlyData;
    if (json['data'] != null) {
      monthlyData = MonthlyFinancialData.fromJson(json['data']);
    }

    return MonthlyFinancialDataResponse(
      success: json['success'] as bool,
      data: monthlyData,
      message: json['message'] as String,
    );
  }
}