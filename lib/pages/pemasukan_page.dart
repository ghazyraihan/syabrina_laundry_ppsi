// lib/pages/pemasukan_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Penting: Pastikan ini sudah diimport

class PemasukanPage extends StatelessWidget {
  const PemasukanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('pesanan')
                // Filter hanya yang statusPembayaran-nya 'Lunas'
                .where('statusPembayaran', isEqualTo: 'Lunas')
                .orderBy('tanggal',
                    descending: true) // Tetap urutkan berdasarkan tanggal
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                // Untuk debugging lebih baik, log errornya
                print(
                    'Error di PemasukanPage StreamBuilder: ${snapshot.error}');
                return Center(
                    child: Text('Terjadi kesalahan: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

              // Sorting di sisi klien untuk robustness (jika ada dokumen tanpa tanggal)
              // Ini memastikan dokumen dengan tanggal null akan berada di bagian akhir daftar.
              docs.sort((a, b) {
                Timestamp? tanggalA =
                    (a.data() as Map<String, dynamic>)['tanggal'] as Timestamp?;
                Timestamp? tanggalB =
                    (b.data() as Map<String, dynamic>)['tanggal'] as Timestamp?;

                if (tanggalA == null && tanggalB == null) return 0;
                if (tanggalA == null) return 1; // Null dates at the end
                if (tanggalB == null) return -1; // Null dates at the end
                return tanggalB.compareTo(
                    tanggalA); // Urutkan secara descending (terbaru di atas)
              });

              // Debugging: Cetak data yang diterima PemasukanPage ke konsol
              print('--- Data PemasukanPage (Riwayat Lunas) ---');
              int tempSumForDebugging = 0;
              for (var doc in docs) {
                try {
                  final data = doc.data() as Map<String, dynamic>;
                  final dynamic value = data['total_harga'];
                  final int jumlah = (value is num) ? value.toInt() : 0;
                  tempSumForDebugging += jumlah;
                  final tanggalTimestamp = data['tanggal'] as Timestamp?;
                  final tanggal = tanggalTimestamp?.toDate();
                  print(
                      '  Dokumen ID: ${doc.id}, Pelanggan: ${data['nama_pelanggan']}, Harga: $jumlah, Status: ${data['statusPembayaran']}, Tanggal: $tanggal');
                } catch (e) {
                  print(
                      'Error processing document in PemasukanPage (ID: ${doc.id}): $e');
                }
              }
              print(
                  'Total Pemasukan Dihitung di PemasukanPage List (Debugging): $tempSumForDebugging');
              print('--------------------------');

              if (docs.isEmpty) {
                return const Center(
                    child: Text('Belum ada data pemasukan lunas.'));
              }

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  try {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final tanggalTimestamp = data['tanggal'] as Timestamp?;
                    final tanggal = tanggalTimestamp?.toDate();
                    final namaPelanggan = data['nama_pelanggan'] ?? 'Pelanggan';

                    double totalHarga = 0.0;
                    final harga = data['total_harga'];
                    // Konversi harga ke double (mendukung int atau string numerik)
                    if (harga is num) {
                      totalHarga = harga.toDouble();
                    } else if (harga is String) {
                      totalHarga = double.tryParse(harga) ?? 0;
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(namaPelanggan),
                        subtitle: Text(
                          tanggal != null
                              ? DateFormat('dd MMMM yyyy')
                                  .format(tanggal) // Format tanggal jika ada
                              : 'Tanggal Tidak Tersedia', // Pesan jika tanggal null
                        ),
                        trailing: Text(
                          NumberFormat.currency(
                            locale: 'id',
                            symbol: 'Rp ',
                            decimalDigits: 0,
                          ).format(totalHarga),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    );
                  } catch (e) {
                    // Tangani error jika ada masalah saat me-render satu item list
                    print(
                        'Error rendering list item at index $index in PemasukanPage: $e');
                    return const SizedBox(); // Lewati item yang bermasalah
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}