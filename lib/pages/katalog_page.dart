import 'package:flutter/material.dart';
import 'form_pesanan_page.dart';

class KatalogPage extends StatefulWidget {
  const KatalogPage({super.key});

  @override
  State<KatalogPage> createState() => _KatalogPageState();
}

class _KatalogPageState extends State<KatalogPage> {
  List<Map<String, dynamic>> layanan = [
    {'nama': 'Cuci Kering', 'harga': 5000},
    {'nama': 'Cuci Setrika', 'harga': 7000},
    {'nama': 'Setrika Saja', 'harga': 4000},
  ];

  void tambahLayanan() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController namaController = TextEditingController();
        final TextEditingController hargaController = TextEditingController();

        return AlertDialog(
          title: const Text('Tambah Layanan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaController,
                decoration: const InputDecoration(labelText: 'Nama Layanan'),
              ),
              TextField(
                controller: hargaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Harga per Kg'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  layanan.add({
                    'nama': namaController.text,
                    'harga': int.tryParse(hargaController.text) ?? 0,
                  });
                });
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void hapusLayanan(int index) {
    setState(() {
      layanan.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Layanan'),
        backgroundColor: Colors.blue[700],
      ),
      body: ListView.builder(
        itemCount: layanan.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.local_laundry_service),
              title: Text(layanan[index]['nama']),
              subtitle: Text('Rp ${layanan[index]['harga']} / kg'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => hapusLayanan(index),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormPesananPage(
                      namaLayanan: layanan[index]['nama'],
                      harga: layanan[index]['harga'],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[700],
        onPressed: tambahLayanan,
        child: const Icon(Icons.add),
      ),
    );
  }
}
