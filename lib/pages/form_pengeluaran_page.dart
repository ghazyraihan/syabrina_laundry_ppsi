// form_pengeluaran_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormPengeluaranPage extends StatefulWidget {
  final String? id;
  final String? initialNama;
  final int? initialJumlah;

  const FormPengeluaranPage({
    super.key,
    this.id,
    this.initialNama,
    this.initialJumlah,
  });

  @override
  State<FormPengeluaranPage> createState() => _FormPengeluaranPageState();
}

class _FormPengeluaranPageState extends State<FormPengeluaranPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _jumlahController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _namaController.text = widget.initialNama ?? '';
    _jumlahController.text = widget.initialJumlah?.toString() ?? '';
  }

  Future<void> _simpanData() async {
    if (_formKey.currentState!.validate()) {
      final nama = _namaController.text;
      final jumlah = int.tryParse(_jumlahController.text) ?? 0;

      final ref = FirebaseFirestore.instance.collection('pengeluaran');

      if (widget.id == null) {
        // Tambah data baru
        await ref.add({'nama': nama, 'jumlah': jumlah});
      } else {
        // Edit data
        await ref.doc(widget.id).update({'nama': nama, 'jumlah': jumlah});
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.id != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Pengeluaran' : 'Tambah Pengeluaran'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                decoration:
                    const InputDecoration(labelText: 'Nama Pengeluaran'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _jumlahController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Jumlah (Rp)'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _simpanData,
                child: Text(isEdit ? 'Update' : 'Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}