import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_frontend/models/savings_goal.dart';
import 'package:flutter_frontend/providers/savings_goal_provider.dart';
import 'package:flutter_frontend/widgets/savings_goal_item_card.dart';

class SavingsGoalScreen extends StatefulWidget {
  const SavingsGoalScreen({Key? key}) : super(key: key);

  @override
  State<SavingsGoalScreen> createState() => _SavingsGoalScreenState();
}

class _SavingsGoalScreenState extends State<SavingsGoalScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SavingsGoalProvider>(context, listen: false).fetchSavingsGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final savingsGoalProvider = Provider.of<SavingsGoalProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardTheme.color,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        elevation: 0,
        title: const Text('Tabungan & Target'),
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.titleLarge?.color,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/add-savings-goal');
            },
          ),
        ],
      ),
      body: savingsGoalProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => savingsGoalProvider.fetchSavingsGoals(),
              child: savingsGoalProvider.savingsGoals.isEmpty
                  ? Center(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Ikon tabungan di tengah
                            Icon(
                              Icons.savings_outlined,
                              size: 60,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            // Teks utama: "Belum Ada Tabungan & Target"
                            Text(
                              'Belum Ada Tabungan & Target',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.titleLarge?.color,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            // Teks deskripsi lebih kecil di bawahnya
                            Text(
                              'Tabungan & target akan muncul di sini setelah Anda menambahkannya',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: savingsGoalProvider.savingsGoals.length,
                      itemBuilder: (context, index) {
                        return SavingsGoalItemCard(
                          savingsGoal: savingsGoalProvider.savingsGoals[index],
                          onRefresh: () => savingsGoalProvider.fetchSavingsGoals(),
                        );
                      },
                    ),
            ),
    );
  }
}