import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'form_layanan_page.dart';
import 'form_pesanan_page.dart';

class KatalogPage extends StatelessWidget {
  const KatalogPage({super.key});

  void _hapusLayanan(String id) {
    FirebaseFirestore.instance.collection('katalog').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Katalog Layanan")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormLayananPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('katalog').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data!.docs;

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final layanan = items[index];
              final id = layanan.id;
              final nama = layanan['nama'];
              final harga = layanan['harga'];

              return ListTile(
                title: Text(nama),
                subtitle: Text('Rp $harga /kg'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FormLayananPage(
                              id: id,
                              namaAwal: nama,
                              hargaAwal: harga,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _hapusLayanan(id),
                    ),
                  ],
                ),
                onTap: () {
                  // Arahkan ke halaman FormPesanan
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