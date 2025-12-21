class Debt {
  final int id;
  final int userId;
  final String creditorName;
  final double amount;
  final DateTime dueDate;
  final String status;
  final String? notes;

  Debt({
    required this.id,
    required this.userId,
    required this.creditorName,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.notes,
  });

  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      id: json['id'],
      userId: json['user_id'],
      creditorName: json['creditor_name'],
      amount: (json['amount'] is int) ? json['amount'].toDouble() : json['amount'],
      dueDate: DateTime.parse(json['due_date']),
      status: json['status'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'creditor_name': creditorName,
      'amount': amount,
      'due_date': dueDate.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
      'status': status,
      'notes': notes,
    };
  }
}

class DebtList {
  final List<Debt> debts;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  DebtList({
    required this.debts,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory DebtList.fromJson(Map<String, dynamic> json) {
    List<Debt> debts = [];
    if (json['data'] != null) {
      debts = (json['data'] as List)
          .map((item) => Debt.fromJson(item))
          .toList();
    }

    return DebtList(
      debts: debts,
      currentPage: json['current_page'],
      lastPage: json['last_page'],
      perPage: json['per_page'],
      total: json['total'],
    );
  }
}