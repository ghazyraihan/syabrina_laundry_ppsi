import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PesananPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Pesanan'),
        backgroundColor: Color(0xFF3B82F6),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pesanan')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final pesananList = snapshot.data?.docs ?? [];

          if (pesananList.isEmpty) {
            return Center(child: Text('Belum ada pesanan.'));
          }

          return ListView.builder(
            itemCount: pesananList.length,
            itemBuilder: (context, index) {
              final data = pesananList[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  title: Text(data['nama'] ?? 'Tanpa Nama'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Layanan: ${data['jenisLayanan']}'),
                      Text('Berat: ${data['berat']} kg'),
                      Text('Total: Rp${data['total']}'),
                      Text('Tanggal Masuk: ${data['tanggalMasuk']}'),
                      Text('Status: ${data['statusPembayaran']}'),
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
