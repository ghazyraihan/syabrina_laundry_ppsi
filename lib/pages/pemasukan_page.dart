// lib/pages/pemasukan_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PemasukanPage extends StatelessWidget {
  const PemasukanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('pesanan')
                .orderBy('tanggal', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print('Error di PemasukanPage StreamBuilder: ${snapshot.error}');
                return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

              // Filter hanya data yang statusPembayaran-nya "Lunas"
              docs = docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['statusPembayaran'] == 'Lunas';
              }).toList();

              // Sort ulang jika perlu
              docs.sort((a, b) {
                final tanggalA = (a.data() as Map<String, dynamic>)['tanggal'] as Timestamp?;
                final tanggalB = (b.data() as Map<String, dynamic>)['tanggal'] as Timestamp?;
                if (tanggalA == null && tanggalB == null) return 0;
                if (tanggalA == null) return 1;
                if (tanggalB == null) return -1;
                return tanggalB.compareTo(tanggalA);
              });

              if (docs.isEmpty) {
                return const Center(child: Text('Belum ada data pemasukan lunas.'));
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
                    if (harga is num) {
                      totalHarga = harga.toDouble();
                    } else if (harga is String) {
                      totalHarga = double.tryParse(harga) ?? 0;
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(namaPelanggan),
                        subtitle: Text(
                          tanggal != null
                              ? DateFormat('dd MMMM yyyy').format(tanggal)
                              : 'Tanggal Tidak Tersedia',
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
                    print('Error rendering item at index $index: $e');
                    return const SizedBox();
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
