import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/api_repository.dart';

// Membuat singleton instance dari ApiRepository untuk manajemen token yang konsisten
final ApiRepository sharedApiRepository = ApiRepository();

final apiRepositoryProvider = Provider<ApiRepository>((ref) {
  return sharedApiRepository;
});