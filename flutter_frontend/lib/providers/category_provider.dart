import 'package:flutter/foundation.dart';
import '../models/category.dart' as CategoryModel;
import '../services/data_service.dart';

class CategoryProvider extends ChangeNotifier {
  List<CategoryModel.Category> _categories = [];
  bool _isLoading = false;
  String _message = '';
  bool _hasFetched = false;

  List<CategoryModel.Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String get message => _message;

  CategoryProvider() {
    // Fetch categories when the provider is first created if user is authenticated
    // We'll call fetchCategories later when we need it, not in constructor to avoid premature API calls
  }

  Future<void> fetchCategories() async {
    print("Memulai fetch kategori..."); // Debug log
    _isLoading = true;
    notifyListeners();

    try {
      print("Mengambil kategori dari API..."); // Debug log
      final response = await DataService.getCategories();
      print("Response dari API: ${response.success}, Message: ${response.message}"); // Debug log
      print("Response data: ${response.data}"); // Debug log

      if (response.success) {
        _categories = response.data?.data ?? [];
        _message = response.message;
        _hasFetched = true;
        print("Berhasil mengambil ${_categories.length} kategori"); // Debug log
        _categories.forEach((cat) => print("Kategori: ${cat.name}, Type: ${cat.type}")); // Debug log
      } else {
        _message = response.message;
        print("Gagal mengambil kategori: ${response.message}"); // Debug log
      }
    } catch (e) {
      _message = 'Gagal mengambil kategori: $e';
      print("Exception mengambil kategori: $e"); // Debug log
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method untuk mengecek apakah kategori sudah dimuat atau belum
  Future<void> ensureCategoriesLoaded() async {
    if (!_hasFetched || _categories.isEmpty) {
      await fetchCategories();
    }
  }

  Future<bool> createCategory(String name, String type) async {
    _isLoading = true;
    notifyListeners();

    try {
      print("Mengirim kategori baru ke API: $name, $type"); // Debug log
      final response = await DataService.createCategory(
        name: name,
        type: type,
      );
      print("Response dari API saat create: ${response.success}, Message: ${response.message}"); // Debug log

      if (response.success) {
        print("Berhasil membuat kategori, sekarang mengambil kembali semua kategori..."); // Debug log
        await fetchCategories(); // Refresh the list
        _message = response.message;
        print("Setelah fetchCategories, jumlah kategori sekarang: ${_categories.length}"); // Debug log
        return true;
      } else {
        _message = response.message;
        print("Gagal membuat kategori: ${response.message}"); // Debug log
        return false;
      }
    } catch (e) {
      _message = 'Gagal membuat kategori: $e';
      print("Exception saat membuat kategori: $e"); // Debug log
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateCategory(int id, String name, String type) async {
    _isLoading = true;
    notifyListeners();

    try {
      print("Mengirim pembaruan kategori ke API: id=$id, name=$name, type=$type"); // Debug log
      final response = await DataService.updateCategory(
        id: id,
        name: name,
        type: type,
      );
      print("Response dari API saat update: ${response.success}, Message: ${response.message}"); // Debug log

      if (response.success) {
        await fetchCategories(); // Refresh the list
        _message = response.message;
        print("Berhasil memperbarui kategori, jumlah kategori sekarang: ${_categories.length}"); // Debug log
        return true;
      } else {
        _message = response.message;
        print("Gagal memperbarui kategori: ${response.message}"); // Debug log
        return false;
      }
    } catch (e) {
      _message = 'Gagal memperbarui kategori: $e';
      print("Exception saat memperbarui kategori: $e"); // Debug log
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCategory(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      print("Mengirim permintaan hapus kategori ke API: id=$id"); // Debug log
      final response = await DataService.deleteCategory(id);
      print("Response dari API saat delete: ${response.success}, Message: ${response.message}"); // Debug log

      if (response.success) {
        await fetchCategories(); // Refresh the list after deletion
        _message = response.message;
        print("Berhasil menghapus kategori, jumlah kategori sekarang: ${_categories.length}"); // Debug log
        notifyListeners();
        return true;
      } else {
        _message = response.message;
        print("Gagal menghapus kategori: ${response.message}"); // Debug log
        return false;
      }
    } catch (e) {
      _message = 'Gagal menghapus kategori: $e';
      print("Exception saat menghapus kategori: $e"); // Debug log
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}