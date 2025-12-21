import 'package:flutter/foundation.dart';
import '../repositories/api_repository.dart';
import '../models/category.dart' as Model;
import '../models/api_response.dart' as Response;
import 'global_providers.dart';

class CategoryProvider extends ChangeNotifier {
  final ApiRepository _apiRepository = sharedApiRepository;
  List<Model.Category> _categories = [];
  String _message = '';
  bool _isLoading = false;

  List<Model.Category> get categories => _categories;
  String get message => _message;
  bool get isLoading => _isLoading;

  Future<void> fetchCategories() async {
    print("CategoryProvider: Starting fetchCategories"); // Debug log

    try {
      final Response.ApiResponse response = await _apiRepository.getCategories();
      print("CategoryProvider: Received response, success: ${response.success}"); // Debug log
      print("CategoryProvider: Response data: ${response.data}"); // Debug log

      if (response.success) {
        // Dari log, response.data langsung berisi array kategori, bukan objek
        if (response.data is List) {
          // Jika response.data langsung array kategori
          try {
            List<Model.Category> processedCategories = [];
            for (int i = 0; i < (response.data as List).length; i++) {
              dynamic item = (response.data as List)[i];
              print("CategoryProvider: Processing category at index $i: $item"); // Debug log

              if (item is Map<String, dynamic>) {
                processedCategories.add(Model.Category.fromJson(item));
              } else {
                print("CategoryProvider: Item at index $i is not a Map<String, dynamic>, it's ${item.runtimeType}"); // Debug log
              }
            }
            _categories = processedCategories;
            _message = 'Kategori berhasil dimuat (${_categories.length} item)';
            print("CategoryProvider: Loaded ${_categories.length} categories"); // Debug log
          } catch (e) {
            print("CategoryProvider: Error during mapping: $e"); // Debug log
            _categories = []; // Set to empty list to prevent crash
          }
        } else if (response.data is Map<String, dynamic>) {
          // Jika response.data adalah objek dengan key 'data'
          final categoryList = (response.data as Map<String, dynamic>)['data'] as List<dynamic>?;
          if (categoryList != null) {
            try {
              List<Model.Category> processedCategories = [];
              for (int i = 0; i < categoryList.length; i++) {
                dynamic item = categoryList[i];
                print("CategoryProvider: Processing category at index $i: $item"); // Debug log

                if (item is Map<String, dynamic>) {
                  processedCategories.add(Model.Category.fromJson(item));
                } else {
                  print("CategoryProvider: Item at index $i is not a Map<String, dynamic>, it's ${item.runtimeType}"); // Debug log
                }
              }
              _categories = processedCategories;
              _message = 'Kategori berhasil dimuat (${_categories.length} item)';
              print("CategoryProvider: Loaded ${_categories.length} categories"); // Debug log
            } catch (e) {
              print("CategoryProvider: Error during mapping: $e"); // Debug log
              _categories = []; // Set to empty list to prevent crash
            }
          } else {
            _message = 'Data kategori tidak ditemukan dalam respons';
            print("CategoryProvider: Error - Data kategori tidak ditemukan"); // Debug log
          }
        } else {
          _message = 'Format respons API tidak dikenali';
          print("CategoryProvider: Error - Format respons tidak dikenali: ${response.data.runtimeType}"); // Debug log
        }
      } else {
        _message = response.message ?? 'Gagal memuat kategori';
        print("CategoryProvider: Error - ${_message}"); // Debug log
      }
    } catch (e) {
      _message = e.toString();
      print("CategoryProvider: Exception caught: $e"); // Debug log
    } finally {
      notifyListeners();
    }
  }

  Future<bool> createCategory(String name) async {
    try {
      final Response.ApiResponse response = await _apiRepository.addCategory(name);

      if (response.success) {
        await fetchCategories(); // Refresh the list
        _message = 'Kategori berhasil dibuat';
        return true;
      } else {
        _message = response.message ?? 'Gagal membuat kategori';
        return false;
      }
    } catch (e) {
      _message = e.toString();
      return false;
    }
  }

  Future<bool> updateCategory(int id, String name) async {
    try {
      final Response.ApiResponse response = await _apiRepository.updateCategory(id, name);

      if (response.success) {
        await fetchCategories(); // Refresh the list
        _message = 'Kategori berhasil diperbarui';
        return true;
      } else {
        _message = response.message ?? 'Gagal memperbarui kategori';
        return false;
      }
    } catch (e) {
      _message = e.toString();
      return false;
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      final Response.ApiResponse response = await _apiRepository.deleteCategory(id);

      if (response.success) {
        await fetchCategories(); // Refresh the list
        _message = 'Kategori berhasil dihapus';
        return true;
      } else {
        _message = response.message ?? 'Gagal menghapus kategori';
        return false;
      }
    } catch (e) {
      _message = e.toString();
      return false;
    }
  }

  void setMessage(String message) {
    _message = message;
    notifyListeners();
  }
}