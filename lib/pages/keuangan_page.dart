// lib/pages/keuangan_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:syabrina_laundry_ppsi/pages/pemasukan_page.dart';
import 'package:syabrina_laundry_ppsi/pages/pengeluaran_page.dart';
import 'package:syabrina_laundry_ppsi/pages/form_pengeluaran_page.dart';
import 'package:syabrina_laundry_ppsi/pages/ekspor_pdf.dart'; // Pastikan path ini benar

class KeuanganPage extends StatefulWidget {
  const KeuanganPage({super.key});

  @override
  State<KeuanganPage> createState() => _KeuanganPageState();
}

class _KeuanganPageState extends State<KeuanganPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _calculateTotal(QuerySnapshot snapshot, String collectionName) {
    return snapshot.docs.fold<int>(0, (sum, doc) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return sum;
      dynamic value =
          collectionName == 'pesanan' ? data['total_harga'] : data['jumlah'];
      final int jumlah = (value is num) ? value.toInt() : 0;
      return sum + jumlah;
    });
  }

  Future<void> _pickDateAndExportPDF() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(now.year, now.month + 1),
      initialDateRange: DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: DateTime(now.year, now.month + 1, 0),
      ),
    );
    if (picked != null) {
      await exportLaporanKeuanganPDF(context, picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMasuk = _selectedIndex == 0;
    final appBarColor = isMasuk ? Colors.blue[700] : Colors.red[700];
    final accentColor = isMasuk ? Colors.blue[700] : Colors.red[700];
    final lightAccentColor =
        isMasuk ? Colors.blue.shade100 : Colors.red.shade100;
    final totalTextColor =
        isMasuk ? Colors.green.shade800 : Colors.red.shade800;

    Query overallQuery = FirebaseFirestore.instance
        .collection(isMasuk ? 'pesanan' : 'pengeluaran');
    if (isMasuk) {
      overallQuery = overallQuery.where('statusPembayaran', isEqualTo: 'Lunas');
    }
    final Stream<QuerySnapshot> overallStream = overallQuery.snapshots();

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    Query monthQuery = FirebaseFirestore.instance
        .collection(isMasuk ? 'pesanan' : 'pengeluaran')
        .where('tanggal',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth));
    if (isMasuk) {
      monthQuery = monthQuery.where('statusPembayaran', isEqualTo: 'Lunas');
    }
    final Stream<QuerySnapshot> monthStream = monthQuery.snapshots();

    return Scaffold(
      backgroundColor: appBarColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("KEUANGAN",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            onPressed: _pickDateAndExportPDF,
          )
        ],
      ),
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: overallStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final total = _calculateTotal(
                  snapshot.data!, isMasuk ? 'pesanan' : 'pengeluaran');
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMasuk ? "TOTAL PEMASUKAN" : "TOTAL PENGELUARAN",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatter.format(total),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: accentColor,
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: "Masuk"),
                Tab(text: "Keluar"),
              ],
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: monthStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final total = _calculateTotal(
                  snapshot.data!, isMasuk ? 'pesanan' : 'pengeluaran');
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: lightAccentColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isMasuk ? "pemasukan bulan ini" : "pengeluaran bulan ini",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      formatter.format(total),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: totalTextColor,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            isMasuk ? "Riwayat Pemasukan" : "Riwayat Pengeluaran",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              color: Colors.white,
              child: TabBarView(
                controller: _tabController,
                children: const [
                  PemasukanPage(),
                  PengeluaranPage(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: isMasuk
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.red[700],
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const FormPengeluaranPage()),
                );
              },
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }
}
