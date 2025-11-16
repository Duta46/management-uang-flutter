import 'package:flutter/foundation.dart';
import '../models/saving.dart' as SavingModel;
import '../services/data_service.dart';

class SavingProvider extends ChangeNotifier {
  List<SavingModel.Saving> _savings = [];
  bool _isLoading = false;
  String _message = '';
  DateTime? _lastFetch;

  List<SavingModel.Saving> get savings => _savings;
  bool get isLoading => _isLoading;
  String get message => _message;

  // Cek apakah data perlu diperbarui (cache selama 5 menit)
  bool get needsRefresh {
    if (_lastFetch == null) return true;
    return DateTime.now().difference(_lastFetch!) > const Duration(minutes: 5);
  }

  Future<void> fetchSavings({bool forceRefresh = false}) async {
    // Jika data sudah ada dan tidak perlu di-refresh, lewati fetching
    if (_savings.isNotEmpty && !forceRefresh && !needsRefresh) {
      print("Menggunakan cache tabungan, jumlah: ${_savings.length}"); // Debug log
      notifyListeners();
      return;
    }

    print("Memuat data tabungan dari server..."); // Debug log
    _isLoading = true;
    notifyListeners();

    try {
      final response = await DataService.getSavings();

      if (response.success) {
        _savings = response.data?.data ?? [];
        _lastFetch = DateTime.now(); // Simpan waktu fetch terakhir
        _message = response.message;
        print("Berhasil mengambil ${_savings.length} tabungan dari server"); // Debug log
      } else {
        _message = response.message;
        print("Gagal mengambil data: ${response.message}"); // Debug log
      }
    } catch (e) {
      _message = 'Gagal mengambil tabungan: $e';
      print("Error mengambil tabungan: $e"); // Debug log
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createSaving(
    String goalName,
    String targetAmount,
    String currentAmount,
    String deadline,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      print("Mengirim permintaan pembuatan tabungan..."); // Debug log
      final response = await DataService.createSaving(
        goalName: goalName,
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        deadline: deadline,
      );

      if (response.success) {
        print("Sukses membuat tabungan, mereset data dari server..."); // Debug log
        await fetchSavings(forceRefresh: true); // Refresh the list
        _message = response.message;
        print("Jumlah tabungan setelah refresh: ${_savings.length}"); // Debug log
        return true;
      } else {
        _message = response.message;
        print("Gagal membuat tabungan: ${response.message}"); // Debug log
        return false;
      }
    } catch (e) {
      _message = 'Gagal membuat tabungan: $e';
      print("Exception saat membuat tabungan: $e"); // Debug log
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateSaving(
    int id,
    String goalName,
    String targetAmount,
    String currentAmount,
    String deadline,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await DataService.updateSaving(
        id: id,
        goalName: goalName,
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        deadline: deadline,
      );

      if (response.success) {
        await fetchSavings(forceRefresh: true); // Refresh the list
        _message = response.message;
        return true;
      } else {
        _message = response.message;
        return false;
      }
    } catch (e) {
      _message = 'Gagal memperbarui tabungan: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteSaving(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await DataService.deleteSaving(id);

      if (response.success) {
        await fetchSavings(forceRefresh: true); // Refresh the list after deletion
        _message = response.message;
        notifyListeners();
        return true;
      } else {
        _message = response.message;
        return false;
      }
    } catch (e) {
      _message = 'Gagal menghapus tabungan: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}