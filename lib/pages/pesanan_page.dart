import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PesananPage extends StatelessWidget {
  const PesananPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pesanan'),
        backgroundColor: const Color(0xFF3B82F6),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pesanan')
            .orderBy('timestamp', descending: true) // pastikan field ini ada
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final pesananList = snapshot.data?.docs ?? [];

          if (pesananList.isEmpty) {
            return const Center(child: Text('Belum ada pesanan.'));
          }

          return ListView.builder(
            itemCount: pesananList.length,
            itemBuilder: (context, index) {
              final data = pesananList[index].data() as Map<String, dynamic>;

              // parsing tanggalMasuk
              String tanggalFormatted = '-';
              if (data['tanggalMasuk'] != null && data['tanggalMasuk'] is Timestamp) {
                final tanggal = (data['tanggalMasuk'] as Timestamp).toDate();
                tanggalFormatted = DateFormat('dd MMM yyyy').format(tanggal);
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  title: Text(data['nama'] ?? 'Tanpa Nama'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Layanan: ${data['jenisLayanan'] ?? '-'}'),
                      Text('Berat: ${data['berat'] ?? '-'} kg'),
                      Text('Total: Rp${data['total'] ?? '-'}'),
                      Text('Tanggal Masuk: $tanggalFormatted'),
                      Text('Status: ${data['statusPembayaran'] ?? '-'}'),
                    ],
                  ),
                  trailing: Icon(
                    data['statusPembayaran'] == 'Lunas' ? Icons.check_circle : Icons.pending,
                    color: data['statusPembayaran'] == 'Lunas' ? Colors.green : Colors.orange,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
