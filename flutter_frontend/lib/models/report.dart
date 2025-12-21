class ReportData {
  final String month;
  final String year;
  final double totalIncome;
  final double totalExpense;
  final double netTotal;
  final List<Transaction> incomeTransactions;
  final List<Transaction> expenseTransactions;

  ReportData({
    required this.month,
    required this.year,
    required this.totalIncome,
    required this.totalExpense,
    required this.netTotal,
    required this.incomeTransactions,
    required this.expenseTransactions,
  });

  factory ReportData.fromJson(Map<String, dynamic> json) {
    List<Transaction> incomeTransactions = [];
    List<Transaction> expenseTransactions = [];

    if (json['income_transactions'] != null) {
      incomeTransactions = (json['income_transactions'] as List)
          .map((item) => Transaction.fromJson(item))
          .toList();
    }

    if (json['expense_transactions'] != null) {
      expenseTransactions = (json['expense_transactions'] as List)
          .map((item) => Transaction.fromJson(item))
          .toList();
    }

    return ReportData(
      month: json['month'],
      year: json['year'],
      totalIncome: (json['total_income'] is int) ? json['total_income'].toDouble() : json['total_income'],
      totalExpense: (json['total_expense'] is int) ? json['total_expense'].toDouble() : json['total_expense'],
      netTotal: (json['net_total'] is int) ? json['net_total'].toDouble() : json['net_total'],
      incomeTransactions: incomeTransactions,
      expenseTransactions: expenseTransactions,
    );
  }
}

class WeeklyReportData {
  final String weekStart;
  final String weekEnd;
  final double totalIncome;
  final double totalExpense;
  final double netTotal;
  final List<Transaction> incomeTransactions;
  final List<Transaction> expenseTransactions;

  WeeklyReportData({
    required this.weekStart,
    required this.weekEnd,
    required this.totalIncome,
    required this.totalExpense,
    required this.netTotal,
    required this.incomeTransactions,
    required this.expenseTransactions,
  });

  factory WeeklyReportData.fromJson(Map<String, dynamic> json) {
    List<Transaction> incomeTransactions = [];
    List<Transaction> expenseTransactions = [];

    if (json['income_transactions'] != null) {
      incomeTransactions = (json['income_transactions'] as List)
          .map((item) => Transaction.fromJson(item))
          .toList();
    }

    if (json['expense_transactions'] != null) {
      expenseTransactions = (json['expense_transactions'] as List)
          .map((item) => Transaction.fromJson(item))
          .toList();
    }

    return WeeklyReportData(
      weekStart: json['week_start'],
      weekEnd: json['week_end'],
      totalIncome: (json['total_income'] is int) ? json['total_income'].toDouble() : json['total_income'],
      totalExpense: (json['total_expense'] is int) ? json['total_expense'].toDouble() : json['total_expense'],
      netTotal: (json['net_total'] is int) ? json['net_total'].toDouble() : json['net_total'],
      incomeTransactions: incomeTransactions,
      expenseTransactions: expenseTransactions,
    );
  }
}

class CategoryReportData {
  final String month;
  final String year;
  final String type;
  final double totalAmount;
  final List<CategorySpending> categories;

  CategoryReportData({
    required this.month,
    required this.year,
    required this.type,
    required this.totalAmount,
    required this.categories,
  });

  factory CategoryReportData.fromJson(Map<String, dynamic> json) {
    List<CategorySpending> categories = [];
    if (json['categories'] != null) {
      categories = (json['categories'] as List)
          .map((item) => CategorySpending.fromJson(item))
          .toList();
    }

    return CategoryReportData(
      month: json['month'],
      year: json['year'],
      type: json['type'],
      totalAmount: (json['total_amount'] is int) ? json['total_amount'].toDouble() : json['total_amount'],
      categories: categories,
    );
  }
}

class CategorySpending {
  final String categoryName;
  final double total;
  final int count;

  CategorySpending({
    required this.categoryName,
    required this.total,
    required this.count,
  });

  factory CategorySpending.fromJson(Map<String, dynamic> json) {
    return CategorySpending(
      categoryName: json['category_name'],
      total: (json['total'] is int) ? json['total'].toDouble() : json['total'],
      count: json['count'],
    );
  }
}

class Transaction {
  final int id;
  final int userId;
  final double amount;
  final String type;
  final String? description;
  final DateTime date;
  final int? categoryId;
  final String? categoryName;

  Transaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    this.description,
    required this.date,
    this.categoryId,
    this.categoryName,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      userId: json['user_id'],
      amount: (json['amount'] is int) ? json['amount'].toDouble() : json['amount'],
      type: json['type'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      categoryId: json['category_id'],
      categoryName: json['category_name'] ?? json['category']['name'],
    );
  }
}