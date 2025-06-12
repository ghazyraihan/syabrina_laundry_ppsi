import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PesananPage extends StatefulWidget {
  const PesananPage({Key? key}) : super(key: key);

  @override
  State<PesananPage> createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  // Fungsi untuk memperbarui status pembayaran di Firebase
  Future<void> _updatePaymentStatus(String docId, bool isPaid) async {
    try {
      await FirebaseFirestore.instance.collection('pesanan').doc(docId).update({
        'statusPembayaran': isPaid ? 'Lunas' : 'Belum Lunas',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isPaid
                ? 'Status pembayaran berhasil diubah menjadi Lunas!'
                : 'Status pembayaran berhasil diubah menjadi Belum Lunas!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui status pembayaran: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pesanan'),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white, // Agar ikon dan teks di appbar terlihat
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pesanan')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final pesananList = snapshot.data?.docs ?? [];

          if (pesananList.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada pesanan yang masuk.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: pesananList.length,
            itemBuilder: (context, index) {
              final doc = pesananList[index];
              final data = doc.data() as Map<String, dynamic>;
              final docId = doc.id; // Dapatkan ID dokumen

              String tanggalFormatted = '-';
              if (data['timestamp'] != null && data['timestamp'] is Timestamp) {
                final tanggal = (data['timestamp'] as Timestamp).toDate();

                tanggalFormatted =
                    DateFormat('dd MMM yyyy HH:mm').format(tanggal);
              }
              final isLunas = data['statusPembayaran'] == 'Lunas';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(

                    color: isLunas
                        ? Colors.green.shade200
                        : Colors.orange.shade200,
                    width: 1.5,
                  ),
                ),
                elevation: 4,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    // Tampilkan dialog konfirmasi untuk mengubah status pembayaran
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          title: Text(
                            isLunas
                                ? 'Ubah menjadi Belum Lunas?'
                                : 'Ubah menjadi Lunas?',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          content: Text(
                            'Anda yakin ingin mengubah status pembayaran pesanan ${data['nama_pelanggan'] ?? 'ini'} menjadi ${isLunas ? 'Belum Lunas' : 'Lunas'}?',
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Tutup dialog
                              },
                              child: const Text(
                                'Batal',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _updatePaymentStatus(docId, !isLunas);
                                Navigator.of(context).pop(); // Tutup dialog
                              },
                              style: ElevatedButton.styleFrom(

                                backgroundColor:
                                    isLunas ? Colors.orange : Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(isLunas ? 'Belum Lunas' : 'Lunas'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                data['nama_pelanggan'] ?? 'Tanpa Nama',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3B82F6),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isLunas ? Colors.green : Colors.orange,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isLunas ? 'Lunas' : 'Belum Lunas',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Divider(color: Colors.grey.shade300),
                        _buildInfoRow('Layanan', data['jenisLayanan'] ?? '-'),
                        _buildInfoRow('Berat', '${data['berat'] ?? '-'} kg'),
                        _buildInfoRow('Total Harga',
                            'Rp${NumberFormat('#,##0', 'id_ID').format(data['total_harga'] ?? 0)}'),
                        _buildInfoRow('Tanggal Masuk', tanggalFormatted),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100, // Lebar tetap untuk label
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

}
