// lib/pages/keuangan_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Penting: Pastikan ini sudah diimport
import 'pemasukan_page.dart'; // Pastikan path ini benar
import 'pengeluaran_page.dart'; // Pastikan path ini benar
import 'form_pengeluaran_page.dart'; // Pastikan path ini benar

// Kelas _LineGraphPainter (yang digunakan untuk grafik) sudah dihapus karena tidak digunakan lagi.

class KeuanganPage extends StatefulWidget {
  const KeuanganPage({super.key});

  @override
  State<KeuanganPage> createState() => _KeuanganPageState();
}

class _KeuanganPageState extends State<KeuanganPage>
    with SingleTickerProviderStateMixin {
  late TabController
      _tabController; // Kontroler untuk TabBar "Masuk" dan "Keluar"
  int _selectedIndex = 0; // Indeks tab yang sedang dipilih

  // Formatter untuk menampilkan mata uang Rupiah
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    // Inisialisasi TabController dengan 2 tab
    _tabController = TabController(length: 2, vsync: this);
    // Tambahkan listener untuk memperbarui UI saat tab berubah
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose(); // Pastikan TabController di-dispose
    super.dispose();
  }

  // Fungsi untuk menghitung total dari QuerySnapshot
  // Digunakan untuk menghitung total pemasukan atau pengeluaran
  int _calculateTotal(QuerySnapshot snapshot, String collectionName) {
    return snapshot.docs.fold<int>(0, (sum, doc) {
      // Ambil nilai dari field, jika field tidak ada, defaultkan ke null
      final dynamic value = collectionName == 'pesanan'
          ? doc.data() is Map<String, dynamic>
              ? (doc.data() as Map<String, dynamic>)['total_harga']
              : null
          : doc.data() is Map<String, dynamic>
              ? (doc.data() as Map<String, dynamic>)['jumlah']
              : null;

      // Pastikan nilai adalah numerik sebelum konversi ke int.
      // Jika value null atau bukan num, maka jumlah dianggap 0.
      final int jumlah = (value is num) ? value.toInt() : 0;
      return sum + jumlah;
    });
  }

  // Fungsi _generateGraphData (yang digunakan untuk grafik) sudah dihapus karena tidak digunakan lagi.

  @override
  Widget build(BuildContext context) {
    // Tentukan apakah tab yang dipilih adalah "Masuk" atau "Keluar"
    final isMasuk = _selectedIndex == 0;
    // Sesuaikan warna UI berdasarkan tab yang dipilih
    final appBarColor = isMasuk ? Colors.blue[700] : Colors.red[700];
    final accentColor = isMasuk ? Colors.blue[700] : Colors.red[700];
    final lightAccentColor =
        isMasuk ? Colors.blue.shade100 : Colors.red.shade100;
    final totalTextColor =
        isMasuk ? Colors.green.shade800 : Colors.red.shade800;

    // Stream untuk total keseluruhan (tanpa filter tanggal)
    final Stream<QuerySnapshot> overallStream = FirebaseFirestore.instance
        .collection(isMasuk
            ? 'pesanan'
            : 'pengeluaran') // Pilih koleksi berdasarkan tab
        .snapshots(); // Gunakan snapshots() untuk update real-time

    // Stream untuk total bulan ini (dengan filter tanggal)
    // Gunakan waktu saat ini untuk filter bulan
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final Stream<QuerySnapshot> monthStream = FirebaseFirestore.instance
        .collection(isMasuk ? 'pesanan' : 'pengeluaran')
        .where('tanggal',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .snapshots(); // Gunakan snapshots() untuk update real-time

    return Scaffold(
      backgroundColor: appBarColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "KEUANGAN",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          // Bagian untuk menampilkan TOTAL KESELURUHAN (atas)
          // Menggunakan StreamBuilder agar otomatis update
          StreamBuilder<QuerySnapshot>(
            stream: overallStream, // Stream data keseluruhan
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              // Hitung total dari snapshot data yang diterima
              final totalOverall = _calculateTotal(
                  snapshot.data!, isMasuk ? 'pesanan' : 'pengeluaran');

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
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
                      formatter
                          .format(totalOverall), // Tampilkan total keseluruhan
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
          // TabBar "Masuk" dan "Keluar"
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isMasuk ? Colors.blue[700] : Colors.red[700],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: "Masuk"),
                Tab(text: "Keluar"),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Bagian untuk menampilkan TOTAL BULAN INI (bawah)
          // Menggunakan StreamBuilder agar otomatis update dan tampilan ringkas
          StreamBuilder<QuerySnapshot>(
            stream: monthStream, // Stream data bulan ini
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              // Hitung total dari snapshot data yang diterima
              final totalMonth = _calculateTotal(
                  snapshot.data!, isMasuk ? 'pesanan' : 'pengeluaran');

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: lightAccentColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  // Perubahan: Menggunakan Row untuk mensejajarkan elemen
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween, // Untuk meratakan judul dan total ke ujung
                  children: [
                    Text(
                      isMasuk ? "pemasukan bulan ini" : "Pengeluaran Bulan Ini",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      formatter.format(totalMonth), // Tampilkan total bulanan
                      style: TextStyle(
                        fontSize:
                            24, // Anda bisa ubah ukuran font ini jika ingin lebih kecil
                        fontWeight: FontWeight.bold,
                        color: totalTextColor,
                      ),
                    ),
                    // Garis grafik yang sebelumnya ada di sini telah dihapus.
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Judul untuk daftar riwayat
          Text(
            isMasuk ? "Riwayat Pemasukan" : "Riwayat Pengeluaran",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          // Area untuk menampilkan daftar riwayat pemasukan/pengeluaran
          Expanded(
            child: Container(
              color: Colors.white,
              child: TabBarView(
                controller: _tabController,
                children: const [
                  PemasukanPage(), // Halaman riwayat pemasukan
                  PengeluaranPage(), // Halaman riwayat pengeluaran
                ],
              ),
            ),
          ),
        ],
      ),
      // Floating Action Button untuk menambah pengeluaran (hanya muncul di tab "Keluar")
      floatingActionButton: isMasuk
          ? null // Tidak ada FAB di tab pemasukan
          : FloatingActionButton(
              backgroundColor: Colors.red[700],
              onPressed: () {
                // Navigasi ke FormPengeluaranPage saat FAB ditekan
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
