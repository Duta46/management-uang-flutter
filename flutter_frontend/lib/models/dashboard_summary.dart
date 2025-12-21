class DashboardSummary {
  final double monthlyIncome;
  final double monthlyExpense;
  final double fixedExpenses;
  final double variableExpenses;
  final double remainingBalance;
  final int daysLeft;
  final double recommendedDailyBudget;
  final List<TopCategory> topCategories;

  DashboardSummary({
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.fixedExpenses,
    required this.variableExpenses,
    required this.remainingBalance,
    required this.daysLeft,
    required this.recommendedDailyBudget,
    required this.topCategories,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    List<TopCategory> topCategories = [];
    if (json['top_categories'] != null) {
      topCategories = (json['top_categories'] as List)
          .map((item) => TopCategory.fromJson(item))
          .toList();
    }

    return DashboardSummary(
      monthlyIncome: (json['monthly_income'] is int) ? json['monthly_income'].toDouble() : json['monthly_income'],
      monthlyExpense: (json['monthly_expense'] is int) ? json['monthly_expense'].toDouble() : json['monthly_expense'],
      fixedExpenses: (json['fixed_expenses'] is int) ? json['fixed_expenses'].toDouble() : json['fixed_expenses'],
      variableExpenses: (json['variable_expenses'] is int) ? json['variable_expenses'].toDouble() : json['variable_expenses'],
      remainingBalance: (json['remaining_balance'] is int) ? json['remaining_balance'].toDouble() : json['remaining_balance'],
      daysLeft: json['days_left'],
      recommendedDailyBudget: (json['recommended_daily_budget'] is int) ? json['recommended_daily_budget'].toDouble() : json['recommended_daily_budget'],
      topCategories: topCategories,
    );
  }
}

class TopCategory {
  final String name;
  final double total;

  TopCategory({
    required this.name,
    required this.total,
  });

  factory TopCategory.fromJson(Map<String, dynamic> json) {
    return TopCategory(
      name: json['name'] ?? json['category_name'],
      total: (json['total'] is int) ? json['total'].toDouble() : json['total'],
    );
  }
}