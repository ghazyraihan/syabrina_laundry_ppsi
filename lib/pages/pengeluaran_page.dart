// pengeluaran_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'form_pengeluaran_page.dart';

class PengeluaranPage extends StatelessWidget {
  const PengeluaranPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pengeluaranRef = FirebaseFirestore.instance.collection('pengeluaran');

    return Scaffold(
      appBar: AppBar(title: const Text("Data Pengeluaran")),
      body: StreamBuilder<QuerySnapshot>(
        stream: pengeluaranRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index];
              final nama = data['nama'];
              final jumlah = data['jumlah'];
              final id = data.id;

              return ListTile(
                title: Text(nama),
                subtitle: Text("Rp $jumlah"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FormPengeluaranPage(
                              id: id,
                              initialNama: nama,
                              initialJumlah: jumlah,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await pengeluaranRef.doc(id).delete();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormPengeluaranPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}