import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider_change_notifier.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryDarkColor,
              ],
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, child) {
          // Load transactions when screen is first built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!transactionProvider.hasFetched) {
              transactionProvider.fetchTransactions();
            }
          });

          if (transactionProvider.isLoading && transactionProvider.transactions.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final transactions = transactionProvider.transactions;

          return RefreshIndicator(
            onRefresh: () async {
              transactionProvider.fetchTransactions();
            },
            child: transactions.isEmpty
                ? const Center(
                    child: Text('No transactions yet'),
                  )
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return _buildTransactionCard(transaction);
                    },
                  ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final isIncome = transaction.type == 'income';
    final amountColor = isIncome ? AppTheme.incomeColor : AppTheme.expenseColor;
    final backgroundColor = isIncome ? AppTheme.incomeLightColor : AppTheme.expenseLightColor;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isIncome ? Icons.add : Icons.remove,
            color: amountColor,
          ),
        ),
        title: Text(
          transaction.description ?? 'No description',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              transaction.category?.name ?? 'Uncategorized',
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor),
            ),
            const SizedBox(height: 4),
            Text(
              transaction.date ?? '',
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isIncome ? '+' : '-'}Rp ${transaction.amount}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}