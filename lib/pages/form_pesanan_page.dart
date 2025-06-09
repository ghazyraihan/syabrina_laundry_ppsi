import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syabrina_laundry_ppsi/pages/home_page.dart';



class FormPesananPage extends StatefulWidget {
  final String jenisLayanan;
  final int hargaPerKg;

  const FormPesananPage({super.key, required this.jenisLayanan, required this.hargaPerKg});

  @override
  _FormPesananPageState createState() => _FormPesananPageState();
}

class _FormPesananPageState extends State<FormPesananPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _telpController = TextEditingController();
  final _tanggalController = TextEditingController();
  final _beratController = TextEditingController();
  final _totalController = TextEditingController();

  String? _selectedStatusPembayaran;

  @override
  void initState() {
    super.initState();
    _beratController.addListener(_hitungTotal);
  }

  void _hitungTotal() {
    final berat = int.tryParse(_beratController.text) ?? 0;
    final total = berat * widget.hargaPerKg;
    _totalController.text = total.toString();
  }

  Future<void> _pilihTanggal(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      _tanggalController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

//   Future<void> _simpanPesanan() async {
//     if (_formKey.currentState!.validate()) {
//       DocumentReference docRef = FirebaseFirestore.instance.collection('pesanan').doc();

//       // await docRef.set({
//       //   'idPelanggan': docRef.id,
//       //   'nama': _namaController.text,
//       //   'noTelp': _telpController.text,
//       //   'tanggalMasuk': _tanggalController.text,
//       //   'jenisLayanan': widget.jenisLayanan,
//       //   'berat': _beratController.text,
//       //   'total': _totalController.text,
//       //   'statusPembayaran': _selectedStatusPembayaran,
//       //   'timestamp': Timestamp.now(),
//       // });

//       await docRef.set({
//   'idPelanggan': docRef.id,
//   'nama': _namaController.text,
//   'noTelp': _telpController.text,
//   'tanggalMasuk': _tanggalController.text,
//   'jenisLayanan': widget.jenisLayanan,
//   'berat': int.tryParse(_beratController.text) ?? 0, // jadi int
//   'total': int.tryParse(_totalController.text) ?? 0, // jadi int
//   'statusPembayaran': _selectedStatusPembayaran,
//   'timestamp': Timestamp.now(),
// });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Pesanan berhasil dikirim')),
//       );

//       // Kembali ke home page
// Navigator.of(context).pushAndRemoveUntil(
//   MaterialPageRoute(builder: (context) => HomePage()),
//   (Route<dynamic> route) => false,
// );

//       _namaController.clear();
//       _telpController.clear();
//       _tanggalController.clear();
//       _beratController.clear();
//       _totalController.clear();
//       setState(() {
//         _selectedStatusPembayaran = null;
//       });
//     }
//   }

Future<void> _simpanPesanan() async {
    if (_formKey.currentState!.validate()) {
      try {
        DocumentReference docRef = FirebaseFirestore.instance.collection('pesanan').doc();
        
        // Convert string tanggal ke DateTime
        DateTime tanggalMasuk = DateTime.parse(_tanggalController.text);
        
        await docRef.set({
          'idPelanggan': docRef.id,
          'nama_pelanggan': _namaController.text, // disesuaikan dengan field di halaman keuangan
          'noTelp': _telpController.text,
          'tanggal': Timestamp.fromDate(tanggalMasuk), // field untuk query di halaman keuangan
          'tanggalMasuk': _tanggalController.text, // untuk display
          'jenisLayanan': widget.jenisLayanan,
          'berat': int.tryParse(_beratController.text) ?? 0,
          'total_harga': int.tryParse(_totalController.text) ?? 0, // disesuaikan dengan field di halaman keuangan
          'statusPembayaran': _selectedStatusPembayaran,
          'timestamp': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pesanan berhasil disimpan')),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomePage()),
          (Route<dynamic> route) => false,
        );

        // Reset form
        _namaController.clear();
        _telpController.clear();
        _tanggalController.clear();
        _beratController.clear();
        _totalController.clear();
        setState(() {
          _selectedStatusPembayaran = null;
        });
      } catch (e) {
        print('Error saat menyimpan pesanan: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan pesanan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF3B82F6),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            width: double.infinity,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                const Text('Pesanan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(_namaController, 'Nama Pelanggan'),
                        _buildTextField(
                          _telpController,
                          'No. Telp',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Harap isi No. Telp';
                            if (!RegExp(r'^\d+$').hasMatch(value)) return 'No. Telp hanya boleh angka';
                            return null;
                          },
                        ),
                        GestureDetector(
                          onTap: () => _pilihTanggal(context),
                          child: AbsorbPointer(
                            child: _buildTextField(_tanggalController, 'Tanggal Masuk'),
                          ),
                        ),
                        _buildReadOnlyField(widget.jenisLayanan, 'Jenis Layanan'),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(_beratController, 'Berat (kg)', keyboardType: TextInputType.number)),
                            const SizedBox(width: 10),
                            Expanded(child: _buildTextField(_totalController, 'Total (Rp)', keyboardType: TextInputType.number, readOnly: true)),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: DropdownButtonFormField<String>(
                            value: _selectedStatusPembayaran,
                            decoration: InputDecoration(
                              labelText: 'Status Pembayaran',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            items: ['Lunas', 'Belum Lunas']
                                .map((status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(status),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedStatusPembayaran = value;
                              });
                            },
                            validator: (value) => value == null ? 'Harap pilih status pembayaran' : null,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: const Color(0xFF3B82F6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _simpanPesanan,
                            child: const Text(
                              'Simpan Order',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: validator ?? (value) => value == null || value.isEmpty ? 'Harap isi $label' : null,
      ),
    );
  }

  Widget _buildReadOnlyField(String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
