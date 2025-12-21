class RecurringExpense {
  final int id;
  final int userId;
  final String name;
  final double amount;
  final String cycle;
  final DateTime nextRunDate;
  final bool autoAdd;

  RecurringExpense({
    required this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.cycle,
    required this.nextRunDate,
    required this.autoAdd,
  });

  factory RecurringExpense.fromJson(Map<String, dynamic> json) {
    return RecurringExpense(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      amount: (json['amount'] is int) ? json['amount'].toDouble() : json['amount'],
      cycle: json['cycle'],
      nextRunDate: DateTime.parse(json['next_run_date']),
      autoAdd: json['auto_add'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'amount': amount,
      'cycle': cycle,
      'next_run_date': nextRunDate.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
      'auto_add': autoAdd,
    };
  }
}

class RecurringExpenseList {
  final List<RecurringExpense> recurringExpenses;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  RecurringExpenseList({
    required this.recurringExpenses,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory RecurringExpenseList.fromJson(Map<String, dynamic> json) {
    List<RecurringExpense> expenses = [];
    if (json['data'] != null) {
      expenses = (json['data'] as List)
          .map((item) => RecurringExpense.fromJson(item))
          .toList();
    }

    return RecurringExpenseList(
      recurringExpenses: expenses,
      currentPage: json['current_page'],
      lastPage: json['last_page'],
      perPage: json['per_page'],
      total: json['total'],
    );
  }
}