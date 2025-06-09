// lib/pages/keuangan_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'pemasukan_page.dart';
import 'pengeluaran_page.dart';
import 'form_pengeluaran_page.dart'; // Diperlukan untuk FAB di tab Keluar

// Custom Painter for a simple "graph" (can be replaced with a proper chart library)
// Letakkan class ini di luar class _KeuanganPageState, tapi masih dalam file yang sama
class _LineGraphPainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;

  _LineGraphPainter(this.data, this.lineColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (data.isNotEmpty) {
      // Find min and max for scaling
      final double minY = data.reduce((a, b) => a < b ? a : b);
      final double maxY = data.reduce((a, b) => a > b ? a : b);

      // Handle case where min and max are the same (flat line)
      if (minY == maxY) {
        path.moveTo(0, size.height / 2);
        path.lineTo(size.width, size.height / 2);
      } else {
        // Normalize data to fit the height
        double normalize(double value) {
          return size.height - ((value - minY) / (maxY - minY)) * size.height;
        }

        path.moveTo(0, normalize(data[0]));

        for (int i = 1; i < data.length; i++) {
          final x = i * (size.width / (data.length - 1));
          final y = normalize(data[i]);
          path.lineTo(x, y);
        }
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // For simplicity, assume data doesn't change frequently
  }
}

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

  // Fungsi untuk menghitung total pemasukan/pengeluaran bulan ini
  Future<int> _getTotalByMonth(String collectionName) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    // Akhir bulan ini (hari terakhir jam 23:59:59)
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final snapshot = await FirebaseFirestore.instance
        .collection(collectionName)
        .where('tanggal',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .get();

    return snapshot.docs.fold<int>(0, (sum, doc) {
      final dynamic jumlahDynamic = doc['jumlah'];
      final int jumlah = (jumlahDynamic is num) ? jumlahDynamic.toInt() : 0;
      return sum + jumlah;
    });
  }

  // Fungsi untuk menghitung total keseluruhan pemasukan/pengeluaran
  Future<int> _getTotalOverall(String collectionName) async {
    final snapshot =
        await FirebaseFirestore.instance.collection(collectionName).get();

    return snapshot.docs.fold<int>(0, (sum, doc) {
      final dynamic jumlahDynamic = doc['jumlah'];
      final int jumlah = (jumlahDynamic is num) ? jumlahDynamic.toInt() : 0;
      return sum + jumlah;
    });
  }

  // Fungsi dummy untuk menghasilkan data grafik yang sederhana
  List<double> _generateGraphData(int total, {int points = 5}) {
    if (total == 0)
      return List.generate(
          points, (index) => 0.0); // Jika total 0, data grafik juga 0

    // Simulasikan sedikit variasi di sekitar total
    return List.generate(points, (index) {
      // Lebih alami, variasikan sedikit nilai di setiap titik
      double base = total.toDouble();
      double variation =
          (index / (points - 1)) * 0.2 - 0.1; // Variasi antara -0.1 dan 0.1
      return base * (1 + variation);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMasuk = _selectedIndex == 0;
    final appBarColor = isMasuk ? Colors.blue[700] : Colors.red[700];
    final accentColor = isMasuk ? Colors.blue[700] : Colors.red[700];
    final lightAccentColor =
        isMasuk ? Colors.blue.shade100 : Colors.red.shade100;
    final totalTextColor = isMasuk
        ? Colors.green.shade800
        : Colors.red.shade800; // Warna teks untuk grafik

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
            // Ini akan kembali ke halaman sebelumnya
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          // Total Pemasukan/Pengeluaran Card
          FutureBuilder<int>(
            future: isMasuk
                ? _getTotalOverall('pemasukan')
                : _getTotalOverall('pengeluaran'),
            builder: (context, snapshot) {
              final totalOverall = snapshot.data ?? 0;
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
          // Tab Bar
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
          // "Pemasukan/Pengeluaran bulan ini" Card with graph
          FutureBuilder<int>(
            future: _getTotalByMonth(isMasuk ? 'pemasukan' : 'pengeluaran'),
            builder: (context, snapshot) {
              final totalMonth = snapshot.data ?? 0;
              final List<double> graphData = _generateGraphData(totalMonth);
              final graphLineColor = isMasuk ? Colors.green : Colors.red;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: lightAccentColor, // Warna latar belakang card
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMasuk ? "pemasukan bulan ini" : "pengeluaran bulan ini",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatter.format(totalMonth),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: totalTextColor, // Warna teks sesuai desain
                          ),
                        ),
                        // Small graph area
                        SizedBox(
                          width: 100, // Lebar grafik
                          height: 50, // Tinggi grafik
                          child: CustomPaint(
                            painter:
                                _LineGraphPainter(graphData, graphLineColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Label "Pemasukan" / "Pengeluaran"
          Text(
            isMasuk ? "Pemasukan" : "Pengeluaran",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          // Expanded TabBarView (contains PemasukanPage and PengeluaranPage)
          Expanded(
            child: Container(
              color: Colors.white, // Background putih untuk area daftar
              child: TabBarView(
                controller: _tabController,
                children: const [
                  PemasukanPage(), // Widget PemasukanPage Anda
                  PengeluaranPage(), // Widget PengeluaranPage Anda
                ],
              ),
            ),
          ),
        ],
      ),
      // Floating Action Button hanya di tab Keluar sesuai desain
      floatingActionButton: isMasuk
          ? null // Jika di tab Masuk, tidak ada FAB
          : FloatingActionButton(
              backgroundColor: Colors.red[700], // Warna FAB sesuai tab Keluar
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
