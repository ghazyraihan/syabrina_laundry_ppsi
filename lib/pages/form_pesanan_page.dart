import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormPesananPage extends StatefulWidget {
  @override
  _FormPesananPageState createState() => _FormPesananPageState();
}

class _FormPesananPageState extends State<FormPesananPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaPelangganController = TextEditingController();
  final _noTelpController = TextEditingController();
  final _tanggalMasukController = TextEditingController();
  final _beratController = TextEditingController();
  final _totalController = TextEditingController();
  final _statusPembayaranController = TextEditingController();

  Future<void> _simpanPesanan() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('pesanan').add({
        'nama': _namaPelangganController.text,
        'noTelp': _noTelpController.text,
        'Tanggal_Masuk': _tanggalMasukController.text,
        'berat': _beratController.text,
        'total': _totalController.text,
        'timestamp': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pesanan berhasil dikirim')),
      );

      _namaPelangganController.clear();
      _noTelpController.clear();
      _tanggalMasukController.clear();
      _beratController.clear();
      _totalController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Form Pesanan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaPelangganController,
                decoration: InputDecoration(labelText: 'Nama'),
                validator: (value) => value!.isEmpty ? 'Isi nama' : null,
              ),
              TextFormField(
                controller: _noTelpController,
                decoration: InputDecoration(labelText: 'Alamat'),
                validator: (value) => value!.isEmpty ? 'Isi alamat' : null,
              ),
              TextFormField(
                controller: _tanggalMasukController,
                decoration: InputDecoration(labelText: 'Pesanan'),
                validator: (value) => value!.isEmpty ? 'Isi pesanan' : null,
              ),
              TextFormField(
                controller: _beratController,
                decoration: InputDecoration(labelText: 'Pesanan'),
                validator: (value) => value!.isEmpty ? 'Isi pesanan' : null,
              ),
              TextFormField(
                controller: _totalController,
                decoration: InputDecoration(labelText: 'Pesanan'),
                validator: (value) => value!.isEmpty ? 'Isi pesanan' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _simpanPesanan,
                child: Text('Kirim'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
