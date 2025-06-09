// form_pengeluaran_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // Import for DateFormat

class FormPengeluaranPage extends StatefulWidget {
  final String? id;
  final String? initialNama;
  final int? initialJumlah;
  final DateTime? initialTanggal; // New: Tanggal

  const FormPengeluaranPage({
    super.key,
    this.id,
    this.initialNama,
    this.initialJumlah,
    this.initialTanggal, // New
  });

  @override
  State<FormPengeluaranPage> createState() => _FormPengeluaranPageState();
}

class _FormPengeluaranPageState extends State<FormPengeluaranPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaBarangController = TextEditingController(); // Changed
  final _nominalController = TextEditingController(); // Changed
  TextEditingController _tanggalController = TextEditingController(); // New

  DateTime? _selectedDate; // New

  @override
  void initState() {
    super.initState();
    _namaBarangController.text = widget.initialNama ?? '';
    _nominalController.text = widget.initialJumlah?.toString() ?? '';

    _selectedDate = widget.initialTanggal ?? DateTime.now(); // New
    _tanggalController.text =
        DateFormat('dd MMMM yyyy').format(_selectedDate!); // New
  }

  @override
  void dispose() {
    _namaBarangController.dispose();
    _nominalController.dispose();
    _tanggalController.dispose(); // New
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _tanggalController.text = DateFormat('dd MMMM yyyy').format(picked);
      });
    }
  }

  Future<void> _simpanData() async {
    if (_formKey.currentState!.validate()) {
      final nama = _namaBarangController.text;
      final jumlah = int.tryParse(_nominalController.text) ?? 0;
      final tanggal = _selectedDate ?? DateTime.now(); // New

      final ref = FirebaseFirestore.instance.collection('pengeluaran');

      if (widget.id == null) {
        // Tambah data baru
        await ref.add({
          'nama': nama,
          'jumlah': jumlah,
          'tanggal': Timestamp.fromDate(tanggal)
        }); // New
      } else {
        // Edit data
        await ref.doc(widget.id).update({
          'nama': nama,
          'jumlah': jumlah,
          'tanggal': Timestamp.fromDate(tanggal)
        }); // New
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
        backgroundColor:
            Colors.blue[700], // Ubah warna AppBar sesuai desain umum aplikasi
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tanggal
              TextFormField(
                controller: _tanggalController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  labelText: 'Tanggal',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Tanggal wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),
              // Nama Barang
              TextFormField(
                controller: _namaBarangController,
                decoration: InputDecoration(
                  labelText: 'Nama Barang',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Nama barang wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),
              // Nominal
              TextFormField(
                controller: _nominalController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Nominal',
                  prefixText: 'Rp ', // Menambahkan prefix Rp
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nominal wajib diisi';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Tombol Simpan
              ElevatedButton(
                onPressed: _simpanData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700], // Warna tombol simpan
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Simpan',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
