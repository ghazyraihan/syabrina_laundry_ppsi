import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormPesananPage extends StatefulWidget {
  final String jenisLayanan;
  final int hargaPerKg;

  FormPesananPage({required this.jenisLayanan, required this.hargaPerKg});

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
  final _statusPembayaranController = TextEditingController();

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

  Future<void> _simpanPesanan() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('pesanan').add({
        'nama': _namaController.text,
        'noTelp': _telpController.text,
        'tanggalMasuk': _tanggalController.text,
        'jenisLayanan': widget.jenisLayanan,
        'berat': _beratController.text,
        'total': _totalController.text,
        'statusPembayaran': _statusPembayaranController.text,
        'timestamp': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pesanan berhasil dikirim')),
      );

      _namaController.clear();
      _telpController.clear();
      _tanggalController.clear();
      _beratController.clear();
      _totalController.clear();
      _statusPembayaranController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F4F6),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
            decoration: BoxDecoration(
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
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(width: 8),
                Text('Pesanan',
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
                    boxShadow: [
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
                        _buildTextField(_telpController, 'No. Telp', keyboardType: TextInputType.phone),
                        _buildTextField(_tanggalController, 'Tanggal Masuk'),
                        _buildReadOnlyField(widget.jenisLayanan, 'Jenis Layanan'),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(_beratController, 'Berat (kg)', keyboardType: TextInputType.number)),
                            SizedBox(width: 10),
                            Expanded(child: _buildTextField(_totalController, 'Total (Rp)', keyboardType: TextInputType.number, readOnly: true)),
                          ],
                        ),
                        _buildTextField(_statusPembayaranController, 'Status Pembayaran'),
                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Color(0xFF3B82F6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _simpanPesanan,
                            child: Text(
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

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text, bool readOnly = false}) {
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
        validator: (value) => value == null || value.isEmpty ? 'Harap isi $label' : null,
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
