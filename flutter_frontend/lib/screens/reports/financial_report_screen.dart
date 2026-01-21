import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_frontend/providers/financial_report_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:printing/printing.dart';
import 'package:flutter_frontend/services/pdf_service.dart';
import 'package:flutter_frontend/widgets/monthly_trend_chart.dart';
import 'package:intl/intl.dart';

class FinancialReportScreen extends StatefulWidget {
  const FinancialReportScreen({Key? key}) : super(key: key);

  @override
  State<FinancialReportScreen> createState() => _FinancialReportScreenState();
}

class _FinancialReportScreenState extends State<FinancialReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FinancialReportProvider>(context, listen: false).fetchReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = Provider.of<FinancialReportProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardTheme.color,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        elevation: 0,
        title: const Text('Laporan Keuangan'),
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.titleLarge?.color,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              _showDownloadConfirmationDialog(context, 'PDF');
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => reportProvider.fetchReportForSpecificMonth(
              period: 'monthly',
              monthYear: reportProvider.selectedMonth,
            ),
          ),
        ],
      ),
      body: reportProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => reportProvider.fetchReport(period: reportProvider.selectedPeriod),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Month Selection - Similar to MonthlyFinanceScreen
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              reportProvider.selectedMonth.isNotEmpty
                                ? reportProvider.selectedMonth
                                : 'Pilih Bulan',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _selectMonth(reportProvider),
                            child: const Text('Pilih Bulan'),
                          ),
                        ],
                      ),
                    ),
                    // PDF Download Button
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 20), // Menambahkan margin top
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('Download PDF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: reportProvider.reportData != null ? Colors.red : Colors.grey,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: reportProvider.reportData != null && reportProvider.selectedMonth.isNotEmpty
                              ? () async {
                                  // Tampilkan dialog konfirmasi sebelum download
                                  _showDownloadConfirmationDialog(context, 'PDF');
                                }
                              : null, // Nonaktifkan tombol jika data belum siap
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    // Tampilkan pesan jika tidak ada data sama sekali
                    if (reportProvider.reportData == null ||
                        (reportProvider.reportData['summary'] == null &&
                         reportProvider.reportData['expense_breakdown'] == null &&
                         reportProvider.reportData['savings_progress'] == null &&
                         reportProvider.reportData['upcoming_bills'] == null))
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Ikon laporan di tengah
                            Icon(
                              Icons.analytics_outlined,
                              size: 60,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            // Teks utama: "Belum Ada Laporan"
                            Text(
                              'Belum Ada Laporan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.titleLarge?.color,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            // Teks deskripsi lebih kecil di bawahnya
                            Text(
                              'Laporan akan muncul di sini setelah Anda memiliki data keuangan',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tidak ada komponen apapun karena semua diminta dihapus
                        ],
                      ),
                  ],
                ),
              ),
            ),
    );
  }








  void _showDownloadConfirmationDialog(BuildContext context, String format) {
    // Ambil provider untuk memeriksa kesiapan data
    final reportProvider = Provider.of<FinancialReportProvider>(context, listen: false);

    // Tampilkan snackbar jika data belum siap
    if (reportProvider.reportData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data laporan belum siap. Silakan tunggu sebentar dan coba lagi.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Download PDF"),
          content: Text("Apakah Anda yakin ingin mengunduh laporan dalam format PDF untuk bulan ${reportProvider.selectedMonth}?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                // Panggil fungsi download dengan provider
                _downloadPdf(reportProvider);
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text("Ya"),
            ),
          ],
        );
      },
    );
  }


  Future<void> _downloadPdf(FinancialReportProvider reportProvider) async {
    try {
      // Tambahkan pengecekan tambahan sebelum membuat PDF
      if (reportProvider.reportData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data laporan belum siap. Silakan tunggu sebentar dan coba lagi.'),
          ),
        );
        return;
      }

      print('DEBUG: Selected month: ${reportProvider.selectedMonth}');
      print('DEBUG: Report data: ${reportProvider.reportData}');

      if (reportProvider.reportData != null) {
        final summary = reportProvider.reportData['summary'];
        print('DEBUG: Summary data: $summary');

        if (summary != null) {
          final income = summary['income'];
          final expenses = summary['expenses'];
          print('DEBUG: Income: $income, Expenses: $expenses');
        }
      }

      final pdfBytes = await PdfService.generateFinancialReportPdf(
        month: reportProvider.selectedMonth,
        reportData: reportProvider.reportData,
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
      );
    } catch (e) {
      print('Error generating PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat PDF: $e'),
        ),
      );
    }
  }

  Future<void> _selectMonth(FinancialReportProvider reportProvider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      locale: const Locale('id', 'ID'),
    );

    print('DEBUG: Date picker result: $picked');

    if (picked != null) {
      // Format the selected month as "Month Year" (e.g., "Januari 2023")
      String monthYear = "${_getMonthName(picked.month)} ${picked.year}";
      print('DEBUG: Selected monthYear: $monthYear');

      // Update the selected month in the provider
      reportProvider.setSelectedMonth(monthYear);

      // Fetch report for the selected month - always use monthly period
      print('DEBUG: Calling fetchReportForSpecificMonth with period: monthly, monthYear: $monthYear');
      await reportProvider.fetchReportForSpecificMonth(
        period: 'monthly',  // Selalu gunakan monthly sebagai periode
        monthYear: monthYear,
      );
      print('DEBUG: fetchReportForSpecificMonth completed');
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1: return 'Januari';
      case 2: return 'Februari';
      case 3: return 'Maret';
      case 4: return 'April';
      case 5: return 'Mei';
      case 6: return 'Juni';
      case 7: return 'Juli';
      case 8: return 'Agustus';
      case 9: return 'September';
      case 10: return 'Oktober';
      case 11: return 'November';
      case 12: return 'Desember';
      default: return 'Bulan Tidak Valid';
    }
  }
}