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
        backgroundColor: Colors.red, // Ubah warna AppBar menjadi merah
        foregroundColor: Colors.white, // Warna teks AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(20), // Tambah padding keseluruhan
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Agar elemen mengisi lebar
            children: [
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  labelText: 'Nama Pengeluaran',
                  border: OutlineInputBorder(
                    // Border pada input field
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.description), // Ikon deskripsi
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Nama pengeluaran wajib diisi'
                    : null,
              ),
              const SizedBox(height: 15), // Spasi antar field
              TextFormField(
                controller: _jumlahController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Jumlah (Rp)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.attach_money), // Ikon uang
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah wajib diisi';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15), // Spasi antar field
              TextFormField(
                controller: _tanggalController,
                readOnly: true, // Membuat field tidak bisa diketik langsung
                onTap: () =>
                    _selectDate(context), // Panggil date picker saat ditekan
                decoration: InputDecoration(
                  labelText: 'Tanggal Pengeluaran',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: const Icon(Icons.calendar_today), // Ikon kalender
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Tanggal wajib diisi'
                    : null,
              ),
              const SizedBox(height: 30), // Spasi sebelum tombol
              ElevatedButton(
                onPressed: _simpanData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Ubah warna tombol menjadi merah
                  foregroundColor: Colors.white, // Warna teks tombol
                  padding:
                      const EdgeInsets.symmetric(vertical: 15), // Padding tombol
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10), // Sudut melengkung pada tombol
                  ),
                  elevation: 5, // Efek bayangan pada tombol
                ),
                child: Text(
                  isEdit ? 'Update Pengeluaran' : 'Simpan Pengeluaran',
                  style: const TextStyle(fontSize: 18), // Ukuran teks tombol
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}