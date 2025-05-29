// file: katalog_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'form_pesanan_page.dart';

class KatalogPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Katalog")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Tambah layanan baru (bisa diarahkan ke form lain jika perlu)
        },
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('katalog').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final items = snapshot.data!.docs;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final layanan = items[index];
              final nama = layanan['nama'];
              final harga = layanan['harga'];
              return ListTile(
                title: Text(nama),
                subtitle: Text('Rp $harga /kg'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FormPesananPage(
                        jenisLayanan: nama,
                        hargaPerKg: harga,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
