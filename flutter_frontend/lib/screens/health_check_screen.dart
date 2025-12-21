import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/api_repository.dart';
import '../providers/global_providers.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Check'),
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
                  ),
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  // Health status
                  if (_healthData != null) ...[
                    Card(
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
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _healthData!['status'] ?? 'Unknown',
                                  style: TextStyle(
                                    color: _healthData!['status'] == 'OK'
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Database: ${_healthData!['database']}'),
                            Text('Version: ${_healthData!['version']}'),
                            Text('Timestamp: ${_healthData!['timestamp']}'),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Self-test results
                  if (_selfTestData != null) ...[
                    Card(
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
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selfTestData!['status'] ?? 'Unknown',
                                  style: TextStyle(
                                    color: _selfTestData!['status'] == 'OK'
                                        ? Colors.green
                                        : Colors.red,
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
                    child: const Text('Re-check API Status'),
                  ),
                ],
              ],
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
            color: status ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(name),
          const Spacer(),
          Text(
            status ? 'OK' : 'FAILED',
            style: TextStyle(
              color: status ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
