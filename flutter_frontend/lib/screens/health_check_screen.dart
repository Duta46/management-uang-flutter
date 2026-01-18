import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/api_repository.dart';
import '../providers/global_providers.dart';
import '../theme/app_theme.dart';

class HealthCheckScreen extends ConsumerStatefulWidget {
  const HealthCheckScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HealthCheckScreen> createState() => _HealthCheckScreenState();
}

class _HealthCheckScreenState extends ConsumerState<HealthCheckScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _healthData;
  Map<String, dynamic>? _selfTestData;

  Future<void> _checkHealth() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use the shared instance directly since it's a singleton
      final apiRepo = sharedApiRepository;

      // Check health endpoint
      final healthResponse = await apiRepo.healthCheck();
      if (healthResponse.success) {
        setState(() {
          _healthData = healthResponse.data;
        });
      }

      // Check self-test endpoint
      final selfTestResponse = await apiRepo.selfTest();
      if (selfTestResponse.success) {
        setState(() {
          _selfTestData = selfTestResponse.data;
        });
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkHealth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF667eea), // Biru keunguan
            Color(0xFF764ba2), // Ungu
            Color(0xFFc3a1d9), // Ungu lembut
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Health Check',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(
            color: Colors.white, // Warna ikon menjadi putih
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _checkHealth,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'API Health Check',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Teks menjadi putih
                    ),
                  ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  // Health status
                  if (_healthData != null) ...[
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Health Status',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black, // Warna teks hitam
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  _healthData!['status'] == 'OK'
                                      ? Icons.check_circle
                                      : Icons.error,
                                  color: _healthData!['status'] == 'OK'
                                      ? AppTheme.incomeColor
                                      : AppTheme.expenseColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _healthData!['status'] ?? 'Unknown',
                                  style: TextStyle(
                                    color: _healthData!['status'] == 'OK'
                                        ? AppTheme.incomeColor
                                        : AppTheme.expenseColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Database: ${_healthData!['database']}',
                              style: const TextStyle(
                                color: Colors.black, // Warna teks hitam
                              ),
                            ),
                            Text(
                              'Version: ${_healthData!['version']}',
                              style: const TextStyle(
                                color: Colors.black, // Warna teks hitam
                              ),
                            ),
                            Text(
                              'Timestamp: ${_healthData!['timestamp']}',
                              style: const TextStyle(
                                color: Colors.black, // Warna teks hitam
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Self-test results
                  if (_selfTestData != null) ...[
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'API Self-Test Results',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black, // Warna teks hitam
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  _selfTestData!['status'] == 'OK'
                                      ? Icons.check_circle
                                      : Icons.error,
                                  color: _selfTestData!['status'] == 'OK'
                                      ? AppTheme.incomeColor
                                      : AppTheme.expenseColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selfTestData!['status'] ?? 'Unknown',
                                  style: TextStyle(
                                    color: _selfTestData!['status'] == 'OK'
                                        ? AppTheme.incomeColor
                                        : AppTheme.expenseColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildApiStatusItem('Auth API',
                                _selfTestData!['api_check']['auth']),
                            _buildApiStatusItem('Category API',
                                _selfTestData!['api_check']['category']),
                            _buildApiStatusItem('Transaction API',
                                _selfTestData!['api_check']['transaction']),
                            _buildApiStatusItem('Report API',
                                _selfTestData!['api_check']['report']),
                            _buildApiStatusItem('Dashboard API',
                                _selfTestData!['api_check']['dashboard']),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: _checkHealth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF764ba2), // Warna aksen gradient (ungu kebiruan)
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Re-check API Status'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildApiStatusItem(String name, bool status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            status ? Icons.check_circle : Icons.cancel,
            color: status ? AppTheme.incomeColor : AppTheme.expenseColor,
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: const TextStyle(
              color: Colors.black, // Warna teks hitam
            ),
          ),
          const Spacer(),
          Text(
            status ? 'OK' : 'FAILED',
            style: TextStyle(
              color: status ? AppTheme.incomeColor : AppTheme.expenseColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
