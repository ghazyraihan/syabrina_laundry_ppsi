import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormLayananPage extends StatefulWidget {
  final String? id;
  final String? namaAwal;
  final int? hargaAwal;

  const FormLayananPage({super.key, this.id, this.namaAwal, this.hargaAwal});

  @override
  State<FormLayananPage> createState() => _FormLayananPageState();
}

class _FormLayananPageState extends State<FormLayananPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _hargaController;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.namaAwal);
    _hargaController =
        TextEditingController(text: widget.hargaAwal?.toString());
  }

  void _simpanData() {
    if (_formKey.currentState!.validate()) { // Pastikan form divalidasi
      final nama = _namaController.text.trim();
      final harga = int.tryParse(_hargaController.text.trim());

      final data = {'nama': nama, 'harga': harga};

      if (widget.id == null) {
        // Tambah baru
        FirebaseFirestore.instance.collection('katalog').add(data);
      } else {
        // Edit
        FirebaseFirestore.instance
            .collection('katalog')
            .doc(widget.id)
            .update(data);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.id != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Layanan" : "Tambah Layanan"),
        backgroundColor: Theme.of(context).primaryColor, // Warna AppBar
        foregroundColor: Colors.white, // Warna teks AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(20), // Tambah padding keseluruhan
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Agar elemen mengisi lebar
            children: [
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  labelText: "Nama Layanan",
                  border: OutlineInputBorder( // Border pada input field
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.cleaning_services), // Ikon layanan
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Nama layanan wajib diisi' : null,
              ),
              const SizedBox(height: 15), // Spasi antar field
              TextFormField(
                controller: _hargaController,
                decoration: InputDecoration(
                  labelText: "Harga per Kg",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.price_change), // Ikon harga
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga wajib diisi';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30), // Spasi sebelum tombol
              ElevatedButton(
                onPressed: _simpanData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor, // Warna tombol
                  foregroundColor: Colors.white, // Warna teks tombol
                  padding: const EdgeInsets.symmetric(vertical: 15), // Padding tombol
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Sudut melengkung pada tombol
                  ),
                  elevation: 5, // Efek bayangan pada tombol
                ),
                child: Text(
                  isEdit ? "Update Layanan" : "Simpan Layanan",
                  style: const TextStyle(fontSize: 18), // Ukuran teks tombol
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}