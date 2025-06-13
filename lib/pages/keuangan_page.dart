// lib/pages/keuangan_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Penting: Pastikan ini sudah diimport
import 'pemasukan_page.dart'; // Pastikan path ini benar
import 'pengeluaran_page.dart'; // Pastikan path ini benar
import 'form_pengeluaran_page.dart'; // Pastikan path ini benar

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
      // Ambil data dokumen sebagai Map<String, dynamic> atau null jika tidak ada
      final data = doc.data() as Map<String, dynamic>?;

      // Jika data null, lewati dokumen ini dan kembalikan sum saat ini
      if (data == null) {
        return sum;
      }

      dynamic value;
      if (collectionName == 'pesanan') {
        value = data['total_harga'];
      } else {
        value = data['jumlah'];
      }

      // Pastikan nilai adalah numerik sebelum konversi ke int.
      // Jika value null atau bukan num, maka jumlah dianggap 0.
      final int jumlah = (value is num) ? value.toInt() : 0;
      return sum + jumlah;
    });
  }

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

    // --- Stream untuk total keseluruhan (hanya yang Lunas jika Pemasukan) ---
    // Definisikan Query dasar
    Query overallQuery = FirebaseFirestore.instance
        .collection(isMasuk ? 'pesanan' : 'pengeluaran');
    // Tambahkan filter statusPembayaran hanya jika ini adalah tab Pemasukan
    if (isMasuk) {
      overallQuery = overallQuery.where('statusPembayaran', isEqualTo: 'Lunas');
    }
    final Stream<QuerySnapshot> overallStream = overallQuery.snapshots();

    // --- Stream untuk total bulan ini (hanya yang Lunas jika Pemasukan) ---
    final now = DateTime.now(); // Menggunakan waktu saat ini

    // *** PERBAIKAN PENTING DI SINI ***
    // Pastikan startOfMonth tepat di awal hari pertama bulan
    final startOfMonth = DateTime(now.year, now.month, 1, 0, 0, 0); // Jam 00:00:00

    // Pastikan endOfMonth tepat di akhir hari terakhir bulan
    // Menggunakan DateTime(year, month + 1, 0) akan memberikan tanggal terakhir bulan sebelumnya.
    // Kemudian set jam, menit, detik, milidetik, mikrodik detik ke nilai maksimum.
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999, 999);

    // Definisikan Query dasar
    Query monthQuery = FirebaseFirestore.instance
        .collection(isMasuk ? 'pesanan' : 'pengeluaran');
    // Tambahkan filter tanggal
    monthQuery = monthQuery
        .where('tanggal',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth));
    // Tambahkan filter statusPembayaran hanya jika ini adalah tab Pemasukan
    if (isMasuk) {
      monthQuery = monthQuery.where('statusPembayaran', isEqualTo: 'Lunas');
    }
    final Stream<QuerySnapshot> monthStream = monthQuery.snapshots();

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
          StreamBuilder<QuerySnapshot>(
            stream: overallStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final totalOverall = _calculateTotal(
                  snapshot.data!, isMasuk ? 'pesanan' : 'pengeluaran');

              return Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      formatter.format(totalOverall),
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
          StreamBuilder<QuerySnapshot>(
            stream: monthStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isMasuk ? "pemasukan bulan ini" : "pengeluaran bulan ini",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      formatter.format(totalMonth),
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
                  MaterialPageRoute(builder: (_) => const FormPengeluaranPage()),
                );
              },
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }
}
