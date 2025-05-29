import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormLayananPage extends StatefulWidget {
  final String? id;
  final String? namaAwal;
  final int? hargaAwal;

  const FormLayananPage({this.id, this.namaAwal, this.hargaAwal});

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
    final nama = _namaController.text.trim();
    final harga = int.tryParse(_hargaController.text.trim());

    if (nama.isEmpty || harga == null) return;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.id == null ? "Tambah Layanan" : "Edit Layanan")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(labelText: "Nama Layanan"),
              ),
              TextFormField(
                controller: _hargaController,
                decoration: InputDecoration(labelText: "Harga per Kg"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _simpanData,
                child: Text("Simpan"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
