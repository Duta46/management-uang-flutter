import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/api_repository.dart';
import '../models/api_models.dart';
import 'global_providers.dart';

final categoryProvider = StateNotifierProvider<CategoryNotifier, List<Category>>((ref) {
  return CategoryNotifier(ref);
});

class CategoryNotifier extends StateNotifier<List<Category>> {
  Ref ref;

  CategoryNotifier(this.ref) : super([]);

  Future<void> fetchCategories() async {
    final response = await ref.read(apiRepositoryProvider).getCategories();

    if (response.success && response.data != null) {
      final List<dynamic> categoryList = response.data['data'];
      state = categoryList.map((json) => Category.fromJson(json)).toList();
    }
  }
}