import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ai_analysis_provider.dart';
import '../theme/app_theme.dart';

/**
 * AI Insights Screen using Qwen AI via OpenRouter
 * This screen provides financial insights and analysis using AI
 */
class AiInsightsScreen extends StatefulWidget {
  const AiInsightsScreen({Key? key}) : super(key: key);

  @override
  State<AiInsightsScreen> createState() => _AiInsightsScreenState();
}

class _AiInsightsScreenState extends State<AiInsightsScreen> {
  @override
  void initState() {
    super.initState();
    // Load initial insights when the screen is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final aiProvider = Provider.of<AiAnalysisProvider>(context, listen: false);
      aiProvider.getFinancialInsights();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('AI Financial Insights'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              Navigator.pushNamed(context, '/chatbot');
            },
          ),
        ],
      ),
      body: Consumer<AiAnalysisProvider>(
        builder: (context, aiProvider, child) {
          if (aiProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (aiProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${aiProvider.errorMessage}',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      aiProvider.getFinancialInsights();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Check if we have stored insights, otherwise fetch them
          final insights = aiProvider.currentInsights;
          if (insights == null) {
            // If no insights are available, trigger loading
            WidgetsBinding.instance.addPostFrameCallback((_) {
              aiProvider.getFinancialInsights();
            });
            return const Center(
              child: Text('Loading insights...'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                _buildSummaryCards(insights),

                const SizedBox(height: 24),

                // Monthly Comparison
                _buildMonthlyComparison(insights),

                const SizedBox(height: 24),

                // Insights Section
                _buildInsightsSection(insights),

                const SizedBox(height: 24),

                // Recommendations Section
                _buildRecommendationsSection(insights),

                const SizedBox(height: 24),

                // Top Expense Categories
                _buildTopExpenseCategories(insights),

                const SizedBox(height: 24),

                // Top Income Categories
                _buildTopIncomeCategories(insights),

                const SizedBox(height: 24),

                // Action Buttons
                _buildActionButtons(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> insights) {
    final summary = insights['summary'] as Map<String, dynamic>?;
    
    if (summary == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Financial Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryCard(
                'Income',
                'Rp${summary['total_income']?.toStringAsFixed(0) ?? '0'}',
                Colors.green,
              ),
              _buildSummaryCard(
                'Expense',
                'Rp${summary['total_expense']?.toStringAsFixed(0) ?? '0'}',
                Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            'Net Balance',
            'Rp${summary['net_balance']?.toStringAsFixed(0) ?? '0'}',
            summary['net_balance'] is num && summary['net_balance'] > 0 ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 8),
          _buildSummaryCard(
            'Savings Rate',
            '${summary['savings_rate']?.toStringAsFixed(1) ?? '0'}%',
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection(Map<String, dynamic> insights) {
    final dailyTrend = insights['daily_spending_trend'] as Map<String, dynamic>?;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Spending Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (dailyTrend != null)
            Text(
              'Your daily spending is ${dailyTrend['trend'] == 'increasing' ? 'increasing' : dailyTrend['trend'] == 'decreasing' ? 'decreasing' : 'stable'} with an average of Rp${(dailyTrend['average_daily_spending'] ?? 0).toStringAsFixed(0)} per day.',
              style: const TextStyle(fontSize: 16),
            )
          else
            const Text('No spending trend data available.'),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(Map<String, dynamic> insights) {
    final recommendations = insights['recommendations'] as List<dynamic>?;
    
    if (recommendations == null || recommendations.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommendations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...recommendations.map((rec) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rec.toString(),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildMonthlyComparison(Map<String, dynamic> insights) {
    final comparison = insights['monthly_comparison'] as Map<String, dynamic>?;

    if (comparison == null) {
      return const SizedBox.shrink();
    }

    final currentPeriod = comparison['current_period'] as Map<String, dynamic>?;
    final previousPeriod = comparison['previous_period'] as Map<String, dynamic>?;
    final changes = comparison['changes'] as Map<String, dynamic>?;

    if (currentPeriod == null || previousPeriod == null || changes == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Comparison',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildComparisonCard(
                'Income',
                'Rp${currentPeriod['income']?.toStringAsFixed(0) ?? '0'}',
                changes['income_change'] is num && changes['income_change'] >= 0 ? Colors.green : Colors.red,
                '${changes['income_change_percent']?.toStringAsFixed(1) ?? '0'}%',
              ),
              _buildComparisonCard(
                'Expense',
                'Rp${currentPeriod['expense']?.toStringAsFixed(0) ?? '0'}',
                changes['expense_change'] is num && changes['expense_change'] >= 0 ? Colors.red : Colors.green,
                '${changes['expense_change_percent']?.toStringAsFixed(1) ?? '0'}%',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(String title, String value, Color color, String change) {
    bool isPositive = change.startsWith('+') || (!change.startsWith('-') && double.tryParse(change) != null && double.parse(change) > 0);

    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${isPositive ? '+' : ''}$change',
            style: TextStyle(
              fontSize: 12,
              color: isPositive ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopExpenseCategories(Map<String, dynamic> insights) {
    final topCategories = insights['top_expense_categories'] as Map<String, dynamic>?;

    if (topCategories == null || topCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Expense Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...topCategories.entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Rp${entry.value.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTopIncomeCategories(Map<String, dynamic> insights) {
    final topCategories = insights['top_income_categories'] as Map<String, dynamic>?;

    if (topCategories == null || topCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Income Sources',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...topCategories.entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Rp${entry.value.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              final aiProvider = Provider.of<AiAnalysisProvider>(context, listen: false);
              try {
                await aiProvider.getSpendingPatternAnalysis();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Analisis pola pengeluaran berhasil dimuat'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal memuat analisis pola pengeluaran: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Pola Pengeluaran'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              final aiProvider = Provider.of<AiAnalysisProvider>(context, listen: false);
              try {
                await aiProvider.getBudgetRecommendations();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rekomendasi anggaran berhasil dimuat'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal memuat rekomendasi anggaran: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Tips Anggaran'),
          ),
        ),
      ],
    );
  }
}