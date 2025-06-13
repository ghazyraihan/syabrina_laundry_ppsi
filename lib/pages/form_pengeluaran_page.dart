// lib/pages/form_pengeluaran_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Tambahkan ini untuk format tanggal

class FormPengeluaranPage extends StatefulWidget {
  final String? id;
  final String? initialNama;
  final int? initialJumlah;
  // Tambahkan initialTanggal untuk mode edit
  final DateTime? initialTanggal;

  const FormPengeluaranPage({
    super.key,
    this.id,
    this.initialNama,
    this.initialJumlah,
    this.initialTanggal, // Inisialisasi tanggal di konstruktor
  });

  @override
  State<FormPengeluaranPage> createState() => _FormPengeluaranPageState();
}

class _FormPengeluaranPageState extends State<FormPengeluaranPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _tanggalController =
      TextEditingController(); // Controller untuk tampilan tanggal
  DateTime? _selectedDate; // Variabel untuk menyimpan tanggal yang dipilih

  @override
  void initState() {
    super.initState();
    _namaController.text = widget.initialNama ?? '';
    _jumlahController.text = widget.initialJumlah?.toString() ?? '';

    // Inisialisasi tanggal jika ada (mode edit)
    if (widget.initialTanggal != null) {
      _selectedDate = widget.initialTanggal;
      _tanggalController.text =
          DateFormat('dd MMMM yyyy').format(_selectedDate!);
    } else {
      // Jika tidak ada initialTanggal, set ke tanggal hari ini secara default untuk form baru
      _selectedDate = DateTime.now();
      _tanggalController.text =
          DateFormat('dd MMMM yyyy').format(_selectedDate!);
    }
  }

  // Fungsi untuk menampilkan DatePicker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ??
          DateTime.now(), // Gunakan tanggal yang sudah dipilih atau hari ini
      firstDate: DateTime(2000), // Batas tanggal awal
      lastDate: DateTime(2101), // Batas tanggal akhir
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _tanggalController.text =
            DateFormat('dd MMMM yyyy').format(_selectedDate!);
      });
    }
  }

  Future<void> _simpanData() async {
    if (_formKey.currentState!.validate()) {
      final nama = _namaController.text;
      final jumlah = int.tryParse(_jumlahController.text) ?? 0;

      // Pastikan tanggal sudah dipilih
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tanggal wajib diisi.')),
        );
        return;
      }

      final ref = FirebaseFirestore.instance.collection('pengeluaran');

      // Data yang akan disimpan/diupdate
      final Map<String, dynamic> dataToSave = {
        'nama': nama,
        'jumlah': jumlah,
        'tanggal': Timestamp.fromDate(
            _selectedDate!), // Menggunakan tanggal yang dipilih
      };

      if (widget.id == null) {
        // Tambah data baru
        await ref.add(dataToSave);
      } else {
        // Edit data
        await ref.doc(widget.id).update(dataToSave);
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
              // >>>>>> TAMBAH FIELD TANGGAL DI SINI <<<<<<
              TextFormField(
                controller: _tanggalController,
                readOnly: true, // Membuat field tidak bisa diketik langsung
                onTap: () =>
                    _selectDate(context), // Panggil date picker saat ditekan
                decoration: const InputDecoration(
                  labelText: 'Tanggal Pengeluaran',
                  suffixIcon: Icon(Icons.calendar_today), // Ikon kalender
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Tanggal wajib diisi'
                    : null,
              ),
              // >>>>>> AKHIR PENAMBAHAN FIELD TANGGAL <<<<<<
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