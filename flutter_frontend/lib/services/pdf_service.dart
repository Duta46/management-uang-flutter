import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

class PdfService {
  static Future<Uint8List> generateFinancialReportPdf({
    required String month,
    required Map<String, dynamic>? reportData,
  }) async {
    final pdf = pw.Document();

    // Extract data from reportData
    final summary = reportData?['summary'];
    final breakdown = reportData?['expense_breakdown'];
    final monthlyData = reportData?['monthly_data'] as List<dynamic>?;
    final transactions = reportData?['transactions'] as List<dynamic>? ?? [];
    final savingsProgress = reportData?['savings_progress'] as List<dynamic>? ?? [];

    final income = double.tryParse(summary?['income'].toString() ?? '0') ?? 0;
    final expenses = double.tryParse(summary?['expenses'].toString() ?? '0') ?? 0;
    final netIncome = double.tryParse(summary?['net_income'].toString() ?? '0') ?? 0;

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.blueGrey900,
                ),
                child: pw.Center(
                  child: pw.Text(
                    'Laporan Keuangan Bulanan',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),

              pw.SizedBox(height: 20),

              // Month and date
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Bulan: $month',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      'Tanggal Dibuat: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                      style: pw.TextStyle(
                        fontSize: 12,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // Financial Summary
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Ringkasan Keuangan',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Pendapatan:',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.Text(
                          'Rp ${NumberFormat('#,###').format(income)}',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.green,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Pengeluaran:',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.Text(
                          'Rp ${NumberFormat('#,###').format(expenses)}',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.red,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Divider(),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Net:',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Rp ${NumberFormat('#,###').format(netIncome)}',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: netIncome >= 0 ? PdfColors.green : PdfColors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Transactions Detail
              if (transactions.isNotEmpty)
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Detail Transaksi',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Table(
                        border: pw.TableBorder.all(),
                        children: [
                          // Header row
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.all(5),
                                child: pw.Text(
                                  'Tanggal',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(5),
                                child: pw.Text(
                                  'Deskripsi',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(5),
                                child: pw.Text(
                                  'Kategori',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(5),
                                child: pw.Text(
                                  'Jenis',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(5),
                                child: pw.Text(
                                  'Jumlah',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          // Data rows
                          ...transactions.take(20).map((item) { // Take only first 20 transactions to avoid too many pages
                            final date = item['date'] ?? '';
                            final description = item['description'] ?? item['note'] ?? 'N/A';
                            final category = item['category'] != null && item['category']['name'] != null
                                ? item['category']['name']
                                : (item['category_id'] != null ? 'Kategori ${item['category_id']}' : 'Umum');
                            final type = item['type'] == 'income' ? 'Pemasukan' : 'Pengeluaran';
                            final amount = double.tryParse(item['amount'].toString() ?? '0') ?? 0;

                            return pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: pw.EdgeInsets.all(5),
                                  child: pw.Text(
                                    date.toString(),
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.all(5),
                                  child: pw.Flexible(
                                    child: pw.Text(
                                      description.toString(),
                                      style: pw.TextStyle(fontSize: 9),
                                      softWrap: true,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.all(5),
                                  child: pw.Text(
                                    category.toString(),
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.all(5),
                                  child: pw.Text(
                                    type,
                                    style: pw.TextStyle(
                                      fontSize: 9,
                                      color: type == 'Pemasukan' ? PdfColors.green : PdfColors.red,
                                    ),
                                    textAlign: pw.TextAlign.right,
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.all(5),
                                  child: pw.Text(
                                    'Rp ${NumberFormat('#,###').format(amount)}',
                                    style: pw.TextStyle(
                                      fontSize: 9,
                                      color: type == 'Pemasukan' ? PdfColors.green : PdfColors.red,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                    textAlign: pw.TextAlign.right,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                      if (transactions.length > 20)
                        pw.Padding(
                          padding: pw.EdgeInsets.only(top: 10),
                          child: pw.Text(
                            '... dan ${transactions.length - 20} transaksi lainnya',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontStyle: pw.FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

              pw.SizedBox(height: 20),

              // Monthly Trend Data (if available)
              if (monthlyData != null && monthlyData.isNotEmpty)
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Tren Bulanan',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Table(
                        border: pw.TableBorder.all(),
                        children: [
                          // Header row
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.all(5),
                                child: pw.Text(
                                  'Bulan',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(5),
                                child: pw.Text(
                                  'Pendapatan',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(5),
                                child: pw.Text(
                                  'Pengeluaran',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          // Data rows
                          ...monthlyData.map((item) {
                            final monthName = item['month'] ?? '';
                            final income = double.tryParse(item['income'].toString() ?? '0') ?? 0;
                            final expense = double.tryParse(item['expense'].toString() ?? '0') ?? 0;

                            return pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: pw.EdgeInsets.all(5),
                                  child: pw.Text(
                                    monthName.toString(),
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.all(5),
                                  child: pw.Text(
                                    'Rp ${NumberFormat('#,###').format(income)}',
                                    style: pw.TextStyle(
                                      fontSize: 9,
                                      color: PdfColors.green,
                                    ),
                                    textAlign: pw.TextAlign.right,
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.all(5),
                                  child: pw.Text(
                                    'Rp ${NumberFormat('#,###').format(expense)}',
                                    style: pw.TextStyle(
                                      fontSize: 9,
                                      color: PdfColors.red,
                                    ),
                                    textAlign: pw.TextAlign.right,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ],
                  ),
                ),


              pw.SizedBox(height: 20),

              // Savings Progress
              if (savingsProgress.isNotEmpty)
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Progres Tabungan',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Table(
                        border: pw.TableBorder.all(),
                        children: [
                          // Header row
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.all(5),
                                child: pw.Text(
                                  'Target',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(5),
                                child: pw.Text(
                                  'Terkumpul',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(5),
                                child: pw.Text(
                                  'Target',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(5),
                                child: pw.Text(
                                  '% Progres',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          // Data rows
                          ...savingsProgress.map((item) {
                            final name = item['name'] ?? '';
                            final current = double.tryParse(item['current_amount'].toString() ?? '0') ?? 0;
                            final target = double.tryParse(item['target_amount'].toString() ?? '0') ?? 0;
                            final percentage = double.tryParse(item['progress_percentage'].toString() ?? '0') ?? 0;

                            return pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: pw.EdgeInsets.all(5),
                                  child: pw.Text(
                                    name.toString(),
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.all(5),
                                  child: pw.Text(
                                    'Rp ${NumberFormat('#,###').format(current)}',
                                    style: pw.TextStyle(fontSize: 9),
                                    textAlign: pw.TextAlign.right,
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.all(5),
                                  child: pw.Text(
                                    'Rp ${NumberFormat('#,###').format(target)}',
                                    style: pw.TextStyle(fontSize: 9),
                                    textAlign: pw.TextAlign.right,
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.all(5),
                                  child: pw.Text(
                                    '${percentage.toStringAsFixed(1)}%',
                                    style: pw.TextStyle(
                                      fontSize: 9,
                                      color: percentage >= 100 ? PdfColors.green : PdfColors.blue,
                                    ),
                                    textAlign: pw.TextAlign.right,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ],
                  ),
                ),

              pw.SizedBox(height: 20),

              // Expense Breakdown
              if (breakdown != null)
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Rincian Pengeluaran',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      ..._buildExpenseBreakdownRows(breakdown),
                    ],
                  ),
                ),

              pw.Spacer(),

              // Footer
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 20),
                child: pw.Text(
                  'Laporan ini dibuat secara otomatis oleh sistem',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static List<pw.Widget> _buildExpenseBreakdownRows(Map<String, dynamic> breakdown) {
    final breakdownData = breakdown['breakdown'] as Map<String, dynamic>? ?? {};
    final rows = <pw.Widget>[];

    if (breakdownData.isEmpty) {
      rows.add(
        pw.Text(
          'Tidak ada data pengeluaran',
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey700,
          ),
        ),
      );
    } else {
      for (final entry in breakdownData.entries) {
        final amount = double.tryParse(entry.value['amount'].toString() ?? '0') ?? 0;
        final percentage = double.tryParse(entry.value['percentage'].toString() ?? '0') ?? 0;

        rows.add(
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                flex: 2,
                child: pw.Text(
                  entry.key,
                  style: pw.TextStyle(
                    fontSize: 11,
                  ),
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  'Rp ${NumberFormat('#,###').format(amount)}',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.right,
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  '(${percentage.toStringAsFixed(1)}%)',
                  style: pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.grey700,
                  ),
                  textAlign: pw.TextAlign.right,
                ),
              ),
            ],
          ),
        );
        rows.add(pw.SizedBox(height: 5));
      }
    }

    return rows;
  }

}