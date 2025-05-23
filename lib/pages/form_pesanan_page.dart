// form_pesanan_page.dart
import 'package:flutter/material.dart';

class FormPesananPage extends StatelessWidget {
  final String namaLayanan;
  final int harga;

  const FormPesananPage(
      {super.key, required this.namaLayanan, required this.harga});

  @override
  Widget build(BuildContext context) {
    final TextEditingController namaPelanggan = TextEditingController();
    final TextEditingController noTelp = TextEditingController();
    final TextEditingController tanggalMasuk = TextEditingController();
    final TextEditingController berat = TextEditingController();
    final TextEditingController total =
        TextEditingController(text: harga.toString());
    final TextEditingController statusPembayaran = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan'),
        backgroundColor: Colors.blue[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: namaPelanggan,
              decoration: const InputDecoration(labelText: 'Nama Pelanggan'),
            ),
            TextField(
              controller: noTelp,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'No. Telp'),
            ),
            TextField(
              controller: tanggalMasuk,
              decoration: const InputDecoration(labelText: 'Tanggal Masuk'),
            ),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Jenis Layanan',
                hintText: namaLayanan,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: berat,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Berat (kg)'),
                    onChanged: (value) {
                      int b = int.tryParse(value) ?? 0;
                      total.text = (b * harga).toString();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: total,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Total (Rp)'),
                  ),
                ),
              ],
            ),
            TextField(
              controller: statusPembayaran,
              decoration: const InputDecoration(labelText: 'Status Pembayaran'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Simpan pesanan nanti
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Simpan Order'),
            )
          ],
        ),
      ),
    );
  }
}
