import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';
import 'dart:convert';
import 'package:universal_html/html.dart' as html;

Future<void> exportLaporanKeuanganPDF(
  BuildContext context,
  DateTime startDate,
  DateTime endDate,
) async {
  final pdf = pw.Document();
  final pemasukanRef = FirebaseFirestore.instance.collection('pesanan');
  final pengeluaranRef = FirebaseFirestore.instance.collection('pengeluaran');

  final pemasukanSnapshot = await pemasukanRef
      .where('tanggal', isGreaterThanOrEqualTo: startDate)
      .where('tanggal', isLessThanOrEqualTo: endDate)
      .where('statusPembayaran', isEqualTo: 'Lunas')
      .get();

  final pengeluaranSnapshot = await pengeluaranRef
      .where('tanggal', isGreaterThanOrEqualTo: startDate)
      .where('tanggal', isLessThanOrEqualTo: endDate)
      .get();

  double totalPemasukan = 0;
  double totalPengeluaran = 0;

  pdf.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Text(
          'Laporan Keuangan (${DateFormat('dd MMM yyyy', 'id_ID').format(startDate)} - ${DateFormat('dd MMM yyyy', 'id_ID').format(endDate)})',
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 20),
        pw.Text('📥 Pemasukan',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Table.fromTextArray(
          headers: ['Tanggal', 'Pelanggan', 'Total'],
          data: pemasukanSnapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final tanggal = (data['tanggal'] as Timestamp).toDate();
            final nama = data['nama_pelanggan'] ?? '-';
            final total = (data['total_harga'] as num?)?.toDouble() ?? 0.0;
            totalPemasukan += total;
            return [
              DateFormat('dd/MM/yyyy').format(tanggal),
              nama,
              'Rp ${NumberFormat('#,##0', 'id_ID').format(total)}'
            ];
          }).toList(),
        ),
        pw.SizedBox(height: 20),
        pw.Text('📤 Pengeluaran',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Table.fromTextArray(
          headers: ['Tanggal', 'Nama', 'Jumlah'],
          data: pengeluaranSnapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final tanggal = (data['tanggal'] as Timestamp).toDate();
            final nama = data['nama'] ?? '-';
            final jumlah = (data['jumlah'] as num?)?.toDouble() ?? 0.0;
            totalPengeluaran += jumlah;
            return [
              DateFormat('dd/MM/yyyy').format(tanggal),
              nama,
              'Rp ${NumberFormat('#,##0', 'id_ID').format(jumlah)}'
            ];
          }).toList(),
        ),
        pw.SizedBox(height: 20),
        pw.Divider(),
        pw.Text(
          '💰 Total Pemasukan: Rp ${NumberFormat('#,##0', 'id_ID').format(totalPemasukan)}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          '💸 Total Pengeluaran: Rp ${NumberFormat('#,##0', 'id_ID').format(totalPengeluaran)}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          '🧮 Sisa: Rp ${NumberFormat('#,##0', 'id_ID').format(totalPemasukan - totalPengeluaran)}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
      ],
    ),
  );

  // Web download logic
  final pdfBytes = await pdf.save();
  final blob = html.Blob([pdfBytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', 'laporan_keuangan.pdf')
    ..click();
  html.Url.revokeObjectUrl(url);
}
