import 'package:flutter/material.dart';
import 'package:flutter_frontend/theme/app_theme.dart';

class OtherFeaturesScreen extends StatelessWidget {
  const OtherFeaturesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitur Lainnya'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fitur Berbasis AI',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildComingSoonFeatureCard(
              context,
              'Analyst AI',
              'Dapatkan analisis mendalam, rekomendasi, dan prediksi keuangan menggunakan teknologi AI',
              Icons.auto_graph,
              AppTheme.primaryColor,
            ),
            const SizedBox(height: 12),
            _buildComingSoonFeatureCard(
              context,
              'Chatbot Keuangan',
              'Dapatkan bantuan keuangan secara instan',
              Icons.chat,
              AppTheme.incomeColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoonFeatureCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    String routeName = '/financial-insights';

    if (title.contains('Rekomendasi')) {
      routeName = '/financial-recommendations';
    } else if (title.contains('Prediksi')) {
      routeName = '/financial-predictions';
    }

    return Card(
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.pushNamed(context, routeName);
        },
      ),
    );
  }
}