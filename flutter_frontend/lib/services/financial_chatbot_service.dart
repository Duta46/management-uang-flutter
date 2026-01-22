import 'package:flutter_frontend/models/chat_message.dart';
import 'package:flutter_frontend/providers/transaction_provider_change_notifier.dart';
import 'package:flutter_frontend/providers/savings_goal_provider.dart';
import 'package:flutter_frontend/providers/bill_reminder_provider.dart';
import 'package:provider/provider.dart';

class FinancialChatbotService {
  // Daftar intents yang didukung
  static const String INTENT_SALDO = 'saldo';
  static const String INTENT_PENGELUARAN = 'pengeluaran';
  static const String INTENT_PEMASUKAN = 'pemasukan';
  static const String INTENT_TRANSAKSI_TERAKHIR = 'transaksi_terakhir';
  static const String INTENT_TABUNGAN = 'tabungan';
  static const String INTENT_TAGIHAN = 'tagihan';
  static const String INTENT_REKOMENDASI = 'rekomendasi';
  static const String INTENT_BANTUAN = 'bantuan';
  static const String INTENT_SAMBUNG = 'sambung';
  static const String INTENT_KATEGORI = 'kategori';
  static const String INTENT_LAPORAN = 'laporan';
  static const String INTENT_ANGGARAN = 'anggaran';
  static const String INTENT_PERINGATAN = 'peringatan';
  static const String INTENT_TIPS = 'tips';
  static const String INTENT_ANALISIS = 'analisis';
  static const String INTENT_STATISTIK = 'statistik';
  static const String INTENT_TRANSAKSI_BULAN_DEPAN = 'transaksi_bulan_depan';
  static const String INTENT_TAHUNAN = 'tahunan';

  // Pola kata kunci untuk masing-masing intent
  static final Map<String, List<String>> keywordPatterns = {
    INTENT_SALDO: [
      'saldo', 'uang', 'uangku', 'uang saya', 'uang berapa', 'uang berapa saya',
      'balance', 'my balance', 'uangku sekarang', 'berapa uangku', 'uangku berapa',
      'jumlah uang', 'jumlah uangku', 'total uang', 'total saldo', 'jumlah saldo'
    ],
    INTENT_PENGELUARAN: [
      'pengeluaran', 'keluar', 'uang keluar', 'uang habis', 'pengeluaran bulan ini',
      'expense', 'expenses', 'outgoing', 'uang terpakai', 'uang terpakai bulan ini',
      'uang yang terpakai', 'biaya', 'cost', 'costs', 'pengeluaran minggu ini',
      'pengeluaran tahun ini', 'pengeluaran terakhir'
    ],
    INTENT_PEMASUKAN: [
      'pemasukan', 'masuk', 'uang masuk', 'pendapatan', 'income', 'revenue',
      'uang masuk bulan ini', 'pendapatan bulan ini', 'uang yang masuk',
      'penghasilan', 'earnings', 'pemasukan bulan ini', 'pemasukan minggu ini',
      'pemasukan tahun ini', 'pemasukan terakhir'
    ],
    INTENT_TRANSAKSI_TERAKHIR: [
      'transaksi terakhir', 'transaksi terbaru', 'aktivitas terakhir', 'aktivitas terbaru',
      'recent transaction', 'last transaction', 'latest activity', 'recent activity',
      'transaksi yang baru', 'aktivitas yang baru', 'transaksi terkini', 'aktivitas terkini'
    ],
    INTENT_TABUNGAN: [
      'tabungan', 'savings', 'simpanan', 'rencana tabungan', 'tujuan tabungan',
      'savings goal', 'tabungan saya', 'rencana saya', 'tujuan keuangan',
      'rencana keuangan', 'target tabungan', 'tujuan simpanan', 'rencana simpanan'
    ],
    INTENT_TAGIHAN: [
      'tagihan', 'bill', 'pengingat tagihan', 'tagihan terdekat', 'bill reminder',
      'tagihan jatuh tempo', 'tagihan yang harus dibayar', 'due bills', 'bills due',
      'pengingat pembayaran', 'payment reminder', 'tagihan terlambat', 'tagihan lewat tempo'
    ],
    INTENT_REKOMENDASI: [
      'rekomendasi', 'saran', 'tips', 'tips keuangan', 'saran keuangan',
      'recommendation', 'financial tips', 'financial advice', 'advis',
      'apa yang harus saya lakukan', 'apa yang sebaiknya saya lakukan',
      'apa saranmu', 'apa pendapatmu', 'apa yang kamu sarankan'
    ],
    INTENT_BANTUAN: [
      'bantuan', 'help', 'bantu', 'tolong', 'cara', 'bagaimana',
      'how to', 'command', 'perintah', 'menu', 'fitur', 'apa saja yang bisa kamu lakukan',
      'apa saja yang bisa kamu bantu', 'apa saja fitur', 'cara pakai',
      'cara menggunakan', 'cara menggunakannya'
    ],
    INTENT_SAMBUNG: [
      'hai', 'halo', 'hello', 'assalamualaikum', 'pagi', 'siang', 'malam',
      'good morning', 'good afternoon', 'good evening', 'good night',
      'selamat pagi', 'selamat siang', 'selamat sore', 'selamat malam',
      'hey', 'hai bot', 'halo bot', 'hello bot'
    ],
    INTENT_KATEGORI: [
      'kategori', 'category', 'jenis pengeluaran', 'jenis pemasukan',
      'kategori transaksi', 'jenis transaksi', 'macam pengeluaran',
      'macam pemasukan', 'kategori keuangan', 'jenis keuangan'
    ],
    INTENT_LAPORAN: [
      'laporan', 'report', 'ringkasan', 'summary', 'laporan keuangan',
      'report keuangan', 'ringkasan keuangan', 'summary keuangan',
      'lihat laporan', 'tampilkan laporan', 'cetak laporan',
      'buatkan laporan', 'hasilkan laporan'
    ],
    INTENT_ANGGARAN: [
      'anggaran', 'budget', 'anggaran bulan ini', 'budget bulan ini',
      'rencana anggaran', 'rencana pengeluaran', 'planning',
      'perencanaan keuangan', 'anggaran saya', 'budget saya',
      'rencana keuangan bulan ini', 'planning keuangan'
    ],
    INTENT_PERINGATAN: [
      'peringatan', 'peringatan keuangan', 'peringatan pembayaran',
      'peringatan tagihan', 'peringatan jatuh tempo',
      'peringatan penting', 'peringatan keuangan penting',
      'peringatan yang akan datang', 'peringatan mendatang'
    ],
    INTENT_TIPS: [
      'tips', 'tips keuangan', 'tips hemat', 'tips menabung',
      'tips menghemat', 'tips mengatur keuangan', 'tips keuangan sehari-hari',
      'tips pengelolaan keuangan', 'tips keuangan bulanan',
      'cara mengatur keuangan', 'cara hemat uang', 'cara hemat'
    ],
    INTENT_ANALISIS: [
      'analisis', 'analisis keuangan', 'analisis pengeluaran',
      'analisis pemasukan', 'analisis keuangan bulan ini',
      'analisis keuangan minggu ini', 'analisis keuangan tahun ini',
      'analisis keuangan saya', 'analisis kondisi keuangan',
      'bagaimana kondisi keuangan saya', 'bagaimana analisis keuangan saya'
    ],
    INTENT_STATISTIK: [
      'statistik', 'statistik keuangan', 'statistik pengeluaran',
      'statistik pemasukan', 'statistik transaksi',
      'data statistik', 'informasi statistik',
      'berapa banyak transaksi', 'berapa banyak pengeluaran',
      'berapa banyak pemasukan', 'jumlah transaksi'
    ],
    INTENT_TRANSAKSI_BULAN_DEPAN: [
      'transaksi bulan depan', 'tunjukkan transaksi bulan depan', 'uang bulan depan',
      'rencana pengeluaran bulan depan', 'rencana pemasukan bulan depan',
      'apa yang akan terjadi bulan depan', 'transaksi yang akan datang',
      'transaksi di masa depan', 'rencana keuangan bulan depan'
    ],
    INTENT_TAHUNAN: [
      'tahun ini', 'tahun depan', 'tahun lalu', 'tahun 2024', 'tahun 2025', 'tahun 2026', 'tahun 2027', 'tahun 2028', 'tahun 2029', 'tahun 2030',
      'pengeluaran tahun', 'pemasukan tahun', 'uang tahun', 'keuangan tahun',
      'total tahun', 'jumlah tahun', 'anggaran tahun', 'rencana keuangan tahun'
    ]
  };

  // Fungsi untuk mendeteksi intent dari pesan pengguna
  static String detectIntent(String message) {
    final lowerMessage = message.toLowerCase();

    for (final entry in keywordPatterns.entries) {
      for (final keyword in entry.value) {
        if (lowerMessage.contains(keyword)) {
          return entry.key;
        }
      }
    }

    // Jika tidak ada intent yang cocok, kembalikan null
    return 'unknown';
  }

  // Fungsi untuk mengekstrak tahun dari pesan pengguna
  static int? extractYear(String message) {
    final yearRegex = RegExp(r'\b(19|20)\d{2}\b');
    final matches = yearRegex.allMatches(message);

    if (matches.isNotEmpty) {
      // Ambil tahun terakhir yang ditemukan dalam pesan
      final lastMatch = matches.last;
      final year = int.tryParse(lastMatch.group(0)!);

      // Validasi bahwa tahun berada dalam rentang wajar
      if (year != null && year >= 1900 && year <= 2100) {
        return year;
      }
    }

    return null;
  }

  // Fungsi untuk menghasilkan respon berdasarkan intent dan data finansial
  static Future<String> generateResponse(
    String intent,
    String userMessage, // Tambahkan parameter pesan pengguna
    TransactionProvider transactionProvider,
    SavingsGoalProvider savingsGoalProvider,
    BillReminderProvider billReminderProvider,
  ) async {
    switch (intent) {
      case INTENT_SALDO:
        final balance = transactionProvider.balance;
        return "Saat ini saldo Anda adalah Rp ${_formatCurrency(balance)}. Saldo ini merupakan selisih antara pemasukan dan pengeluaran Anda.";

      case INTENT_PENGELUARAN:
        final expense = transactionProvider.expense;
        return "Total pengeluaran Anda saat ini adalah Rp ${_formatCurrency(expense)}. Ini adalah jumlah semua transaksi pengeluaran yang telah Anda catat.";

      case INTENT_PEMASUKAN:
        final income = transactionProvider.income;
        return "Total pemasukan Anda saat ini adalah Rp ${_formatCurrency(income)}. Ini adalah jumlah semua transaksi pemasukan yang telah Anda catat.";

      case INTENT_TRANSAKSI_TERAKHIR:
        if (transactionProvider.transactions.isEmpty) {
          return "Anda belum memiliki transaksi apapun. Silakan tambahkan transaksi pertama Anda untuk mulai melacak keuangan.";
        }

        final latestTransaction = transactionProvider.transactions.first;
        final typeText = latestTransaction.type == 'income' ? 'Pemasukan' : 'Pengeluaran';
        double amountValue = double.tryParse(latestTransaction.amount.toString()) ?? 0.0;
        final amountText = latestTransaction.type == 'income'
          ? '+Rp ${_formatCurrency(amountValue)}'
          : '-Rp ${_formatCurrency(amountValue)}';

        return "Transaksi terakhir Anda adalah $typeText sebesar $amountText untuk ${latestTransaction.description ?? 'transaksi tanpa keterangan'} pada tanggal ${_formatDate(latestTransaction.date)}.";

      case INTENT_TABUNGAN:
        final activeSavings = savingsGoalProvider.activeSavingsGoals;
        if (activeSavings.isEmpty) {
          return "Anda belum memiliki rencana tabungan aktif. Anda bisa membuat rencana tabungan baru untuk mencapai tujuan keuangan Anda.";
        }

        final StringBuilder = StringBuffer("Berikut rencana tabungan aktif Anda:\n");
        for (final goal in activeSavings.take(3)) { // Ambil 3 teratas
          final targetAmount = double.tryParse(goal.targetAmount.toString()) ?? 0;
          final currentAmount = double.tryParse(goal.currentAmount.toString()) ?? 0;

          final progress = targetAmount > 0
            ? ((currentAmount / targetAmount) * 100).round()
            : 0;
          StringBuilder.write("- ${goal.name}: Rp ${_formatCurrency(currentAmount)}/Rp ${_formatCurrency(targetAmount)} (${progress}% selesai)\n");
        }

        if (activeSavings.length > 3) {
          StringBuilder.write("dan ${activeSavings.length - 3} rencana lainnya...");
        }

        return StringBuilder.toString().trim();

      case INTENT_TAGIHAN:
        final activeBills = billReminderProvider.activeBills;
        if (activeBills.isEmpty) {
          return "Saat ini Anda tidak memiliki pengingat tagihan aktif. Anda bisa menambahkan pengingat tagihan untuk membantu mengelola kewajiban keuangan Anda.";
        }

        final StringBuilder = StringBuffer("Berikut pengingat tagihan yang akan datang:\n");
        for (final bill in activeBills.take(3)) { // Ambil 3 teratas
          DateTime? dueDate = bill.dueDate != null ? DateTime.tryParse(bill.dueDate!) : null;
          StringBuilder.write("- ${bill.name}: Jatuh tempo ${dueDate != null ? _formatDate(dueDate) : 'tanggal tidak valid'}\n");
        }

        if (activeBills.length > 3) {
          StringBuilder.write("dan ${activeBills.length - 3} tagihan lainnya...");
        }

        return StringBuilder.toString().trim();

      case INTENT_REKOMENDASI:
        final balance = transactionProvider.balance;
        final expense = transactionProvider.expense;
        final income = transactionProvider.income;

        if (income == 0) {
          return "Untuk mulai mengelola keuangan dengan baik, cobalah untuk mencatat pemasukan pertama Anda. Ini akan membantu Anda memahami kondisi keuangan saat ini.";
        }

        if (expense > income) {
          return "Pengeluaran Anda saat ini lebih besar daripada pemasukan. Disarankan untuk meninjau kembali pengeluaran Anda dan mencari cara untuk mengurangi pengeluaran yang tidak perlu atau meningkatkan pemasukan.";
        }

        final expensePercentage = (expense / income) * 100;
        if (expensePercentage > 70) {
          return "Pengeluaran Anda mencapai lebih dari 70% dari pemasukan. Ini mungkin terlalu tinggi. Pertimbangkan untuk mengalokasikan lebih banyak dana untuk tabungan atau investasi.";
        }

        return "Kondisi keuangan Anda saat ini cukup sehat. Anda memiliki saldo positif dan pengeluaran yang terkendali. Pertahankan kebiasaan baik ini dan pertimbangkan untuk membuat rencana tabungan untuk tujuan keuangan jangka panjang.";

      case INTENT_BANTUAN:
        return "Saya adalah asisten keuangan digital Anda. Saya bisa membantu Anda dengan:\n"
            "- Menampilkan saldo keuangan Anda\n"
            "- Memberi tahu total pemasukan dan pengeluaran\n"
            "- Menampilkan transaksi terakhir\n"
            "- Menampilkan rencana tabungan Anda\n"
            "- Menampilkan pengingat tagihan yang akan datang\n"
            "- Memberikan rekomendasi keuangan\n"
            "- Menjelaskan kategori transaksi\n"
            "- Menampilkan laporan keuangan\n"
            "- Memberikan tips keuangan\n"
            "- Menganalisis kondisi keuangan Anda\n\n"
            "Anda bisa bertanya seperti 'berapa saldo saya?', 'berapa pengeluaran bulan ini?', 'rencana tabungan saya', dll.";

      case INTENT_SAMBUNG:
        final hour = DateTime.now().hour;
        String greeting = '';
        if (hour >= 5 && hour < 12) {
          greeting = 'Selamat pagi';
        } else if (hour >= 12 && hour < 15) {
          greeting = 'Selamat siang';
        } else if (hour >= 15 && hour < 18) {
          greeting = 'Selamat sore';
        } else {
          greeting = 'Selamat malam';
        }
        return "$greeting! Saya adalah asisten keuangan digital Anda. Bagaimana saya bisa membantu Anda hari ini?";

      case INTENT_KATEGORI:
        final categories = transactionProvider.categories;
        if (categories.isEmpty) {
          return "Anda belum memiliki kategori transaksi apapun. Kategori membantu Anda mengelompokkan pengeluaran dan pemasukan Anda.";
        }

        final StringBuilder = StringBuffer("Berikut kategori transaksi Anda:\n");
        for (final category in categories.take(5)) { // Ambil 5 teratas
          StringBuilder.write("- ${category.name}\n");
        }

        if (categories.length > 5) {
          StringBuilder.write("dan ${categories.length - 5} kategori lainnya...");
        }

        return StringBuilder.toString().trim();

      case INTENT_LAPORAN:
        final income = transactionProvider.income;
        final expense = transactionProvider.expense;
        final balance = transactionProvider.balance;

        return "Berikut ringkasan laporan keuangan Anda:\n"
            "- Total Pemasukan: Rp ${_formatCurrency(income)}\n"
            "- Total Pengeluaran: Rp ${_formatCurrency(expense)}\n"
            "- Saldo: Rp ${_formatCurrency(balance)}\n\n"
            "Anda juga bisa melihat laporan detail di menu Laporan.";

      case INTENT_ANGGARAN:
        return "Fitur anggaran saat ini sedang dalam pengembangan. Kami akan segera menambahkan fitur ini untuk membantu Anda mengatur anggaran bulanan Anda.";

      case INTENT_PERINGATAN:
        final activeBills = billReminderProvider.activeBills;
        if (activeBills.isEmpty) {
          return "Saat ini Anda tidak memiliki pengingat tagihan aktif. Anda bisa menambahkan pengingat tagihan untuk membantu mengelola kewajiban keuangan Anda.";
        }

        final upcomingBills = activeBills.where((bill) =>
            bill.dueDate != null &&
            bill.dueDate!.isNotEmpty
        ).where((bill) {
          DateTime? dueDate = DateTime.tryParse(bill.dueDate!);
          if (dueDate != null) {
            Duration difference = dueDate.difference(DateTime.now());
            return difference.inDays >= 0 && difference.inDays <= 7;
          }
          return false;
        }).toList();

        if (upcomingBills.isEmpty) {
          return "Tidak ada pengingat tagihan yang akan jatuh tempo dalam 7 hari ke depan.";
        }

        final StringBuilder = StringBuffer("Berikut pengingat tagihan yang akan jatuh tempo dalam 7 hari:\n");
        for (final bill in upcomingBills) {
          DateTime? dueDate = DateTime.tryParse(bill.dueDate!);
          if (dueDate != null) {
            final daysLeft = dueDate.difference(DateTime.now()).inDays;
            StringBuilder.write("- ${bill.name}: Jatuh tempo dalam $daysLeft hari (${_formatDate(dueDate)})\n");
          } else {
            StringBuilder.write("- ${bill.name}: Jatuh tempo (tanggal tidak valid)\n");
          }
        }

        return StringBuilder.toString().trim();

      case INTENT_TIPS:
        final tips = [
          "Catat semua pemasukan dan pengeluaran Anda untuk mendapatkan gambaran yang jelas tentang kondisi keuangan Anda.",
          "Pertimbangkan untuk menerapkan metode 50-30-20: 50% untuk kebutuhan, 30% untuk keinginan, dan 20% untuk tabungan/investasi.",
          "Buat rencana tabungan untuk tujuan jangka pendek dan jangka panjang agar lebih disiplin dalam menabung.",
          "Review pengeluaran Anda setiap minggu atau bulan untuk mengidentifikasi area yang bisa dihemat.",
          "Pertimbangkan untuk membuat dana darurat sebesar 3-6 bulan pengeluaran untuk menghadapi situasi tak terduga."
        ];

        final random = DateTime.now().millisecond % tips.length;
        return "Berikut adalah tips keuangan untuk Anda:\n\n${tips[random]}";

      case INTENT_ANALISIS:
        final income = transactionProvider.income;
        final expense = transactionProvider.expense;
        final balance = transactionProvider.balance;

        if (income == 0) {
          return "Anda belum memiliki pemasukan tercatat. Untuk analisis keuangan yang lebih lengkap, silakan tambahkan pemasukan Anda terlebih dahulu.";
        }

        final expensePercentage = (expense / income) * 100;
        String analysis = "Analisis kondisi keuangan Anda:\n\n";

        if (expense > income) {
          analysis += "• Pengeluaran Anda lebih besar dari pemasukan. Ini adalah kondisi yang tidak sehat secara finansial.\n";
          analysis += "• Anda mengalami defisit sebesar Rp ${_formatCurrency(expense - income)}.\n";
          analysis += "• Disarankan untuk segera mengurangi pengeluaran atau meningkatkan pemasukan.\n";
        } else if (expensePercentage > 70) {
          analysis += "• Pengeluaran Anda mencapai ${expensePercentage.toStringAsFixed(1)}% dari pemasukan.\n";
          analysis += "• Ini termasuk tinggi dan mungkin mengganggu kemampuan Anda untuk menabung.\n";
          analysis += "• Pertimbangkan untuk mengurangi pengeluaran yang tidak penting.\n";
        } else {
          analysis += "• Kondisi keuangan Anda cukup sehat.\n";
          analysis += "• Pengeluaran Anda sebesar ${expensePercentage.toStringAsFixed(1)}% dari pemasukan.\n";
          analysis += "• Anda memiliki saldo positif sebesar Rp ${_formatCurrency(balance)}.\n";
        }

        if (balance > 0) {
          analysis += "• Anda memiliki saldo positif yang bisa digunakan untuk tabungan atau investasi.\n";
        } else if (balance < 0) {
          analysis += "• Anda mengalami defisit sebesar Rp ${_formatCurrency(balance.abs())}.\n";
        }

        return analysis;

      case INTENT_STATISTIK:
        final transactions = transactionProvider.transactions;
        final incomeTransactions = transactions.where((t) => t.type == 'income').length;
        final expenseTransactions = transactions.where((t) => t.type == 'expense').length;

        return "Statistik transaksi Anda:\n"
            "- Total transaksi: ${transactions.length}\n"
            "- Jumlah pemasukan: $incomeTransactions transaksi\n"
            "- Jumlah pengeluaran: $expenseTransactions transaksi\n"
            "- Saldo saat ini: Rp ${_formatCurrency(transactionProvider.balance)}\n\n"
            "Statistik ini membantu Anda memahami pola keuangan Anda.";

      case INTENT_TRANSAKSI_BULAN_DEPAN:
        // Untuk sementara, karena data transaksi hanya sampai Januari 2026,
        // maka permintaan tentang Februari 2026 akan menunjukkan tidak ada transaksi
        return "Maaf, bulan depan tidak ada transaksi yang tercatat. Transaksi hanya akan muncul setelah Anda menambahkannya.";

      case INTENT_TAHUNAN:
        // Ekstrak tahun dari pesan pengguna
        final year = extractYear(userMessage);

        if (year != null) {
          // Cek apakah tahun yang diminta adalah tahun saat ini
          final currentYear = DateTime.now().year;

          if (year == currentYear) {
            // Untuk tahun ini, tampilkan data aktual jika ada
            final income = transactionProvider.income;
            final expense = transactionProvider.expense;

            if (income == 0 && expense == 0) {
              return "Untuk tahun ini ({$year}), Anda belum memiliki transaksi keuangan yang tercatat. Silakan tambahkan transaksi untuk melihat ringkasan tahunan.";
            }

            return "Berikut ringkasan keuangan Anda untuk tahun {$year}:\n"
                "- Total Pemasukan: Rp ${_formatCurrency(income)}\n"
                "- Total Pengeluaran: Rp ${_formatCurrency(expense)}\n"
                "- Saldo: Rp ${_formatCurrency(income - expense)}";
          } else if (year > currentYear) {
            // Untuk tahun di masa depan, beri tahu bahwa belum ada datanya
            return "Maaf, untuk tahun {$year} belum ada data transaksi yang tercatat. Data hanya akan muncul setelah Anda menambahkan transaksi untuk tahun tersebut.";
          } else {
            // Untuk tahun sebelumnya, cek apakah ada data
            return "Untuk tahun {$year}, saat ini belum tersedia data transaksi spesifik. Sistem kami hanya menyimpan data secara umum. Anda bisa mengecek arsip atau laporan tahunan Anda.";
          }
        } else {
          // Jika tidak bisa mengekstrak tahun, beri respon umum tentang tahun
          return "Anda menanyakan tentang data tahunan. Untuk tahun tertentu, sistem kami hanya menampilkan data jika sudah tercatat. Silakan coba dengan menyebutkan tahun spesifik seperti 'pengeluaran tahun 2026'.";
        }

      default:
        return "Maaf, saya belum bisa memahami permintaan tersebut. Anda bisa bertanya tentang saldo, pengeluaran, pemasukan, transaksi terakhir, rencana tabungan, pengingat tagihan, atau meminta rekomendasi keuangan.";
    }
  }

  // Fungsi helper untuk format mata uang
  static String _formatCurrency(double amount) {
    String formatted = amount.abs().toStringAsFixed(0);
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    formatted = formatted.replaceAllMapped(reg, (Match m) => '${m[1]}.');
    return amount < 0 ? '-$formatted' : formatted;
  }

  // Fungsi helper untuk format tanggal
  static String _formatDate(DateTime? date) {
    if (date == null) return 'Tanggal tidak valid';
    return "${date.day}/${date.month}/${date.year}";
  }
}