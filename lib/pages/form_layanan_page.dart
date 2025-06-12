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
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();

  bool get isEdit => widget.id != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _namaController.text = widget.namaAwal ?? '';
      _hargaController.text = widget.hargaAwal?.toString() ?? '';
    }
  }

  void _simpanLayanan() async {
    if (_formKey.currentState!.validate()) {
      final nama = _namaController.text.trim();
      final harga = int.tryParse(_hargaController.text.trim()) ?? 0;

      final layanan = {'nama': nama, 'harga': harga};

      final ref = FirebaseFirestore.instance.collection('katalog');
      if (isEdit) {
        await ref.doc(widget.id).update(layanan);
      } else {
        await ref.add(layanan);
      }

      Navigator.pop(context);
    }
  }

  void _hapusLayanan() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Apakah Anda yakin ingin menghapus layanan ini?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Batal")),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Hapus")),
        ],
      ),
    );

    if (konfirmasi == true && widget.id != null) {
      await FirebaseFirestore.instance
          .collection('katalog')
          .doc(widget.id)
          .delete();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Layanan' : 'Tambah Layanan'),
        backgroundColor: Colors.blueAccent,
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _hapusLayanan,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  labelText: "Nama Layanan",
                  prefixIcon: const Icon(Icons.local_laundry_service),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hargaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Harga per Kg",
                  prefixIcon: const Icon(Icons.price_change),
                  suffixText: "Rp",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  final num = int.tryParse(value ?? '');
                  if (num == null || num <= 0)
                    return 'Masukkan harga yang valid';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _simpanLayanan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(isEdit ? 'Simpan Perubahan' : 'Tambahkan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
