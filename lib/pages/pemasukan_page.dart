import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PemasukanPage extends StatelessWidget {
  const PemasukanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Riwayat Pemasukan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('pesanan')
                .orderBy('tanggal', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('Belum ada data pemasukan.'));
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  try {
                    final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    final tanggal = (data['tanggal'] as Timestamp).toDate();
                    final namaPelanggan = data['nama_pelanggan'] ?? 'Pelanggan';

                    double totalHarga = 0.0;
                    final harga = data['total_harga'];

                    if (harga is int) {
                      totalHarga = harga.toDouble();
                    } else if (harga is double) {
                      totalHarga = harga;
                    } else if (harga is String) {
                      totalHarga = double.tryParse(harga) ?? 0;
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(namaPelanggan),
                        subtitle: Text(DateFormat('dd MMMM yyyy').format(tanggal)),
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
                    return SizedBox(); // Skip jika ada error parsing
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
