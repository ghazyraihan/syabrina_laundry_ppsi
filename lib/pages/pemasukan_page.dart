// pemasukan_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:syabrina_laundry_ppsi/pages/form_pengeluaran_page.dart';
// Jika Anda ingin form terpisah untuk pemasukan:
// import 'form_pemasukan_page.dart'; // Akan dibuat jika diperlukan

class PemasukanPage extends StatelessWidget {
  const PemasukanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pemasukanRef = FirebaseFirestore.instance.collection('pemasukan');
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return StreamBuilder<QuerySnapshot>(
      stream: pemasukanRef
          .orderBy('tanggal', descending: true)
          .snapshots(), // Urutkan berdasarkan tanggal
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Belum ada data pemasukan.'));
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index];
            final nama = data['nama'] as String;
            final jumlah = data['jumlah'] as int;
            final tanggalTimestamp = data['tanggal'] as Timestamp?;
            final tanggal = tanggalTimestamp?.toDate();
            final id = data.id;

            // Ikon hardcode untuk demonstrasi, ganti dengan ikon dinamis jika perlu
            IconData iconData;
            switch (nama.toLowerCase()) {
              case 'cuci kering':
                iconData = Icons.local_laundry_service;
                break;
              case 'setrika':
                iconData = Icons.iron;
                break;
              case 'cuci & setrika':
                iconData = Icons.dry_cleaning;
                break;
              default:
                iconData = Icons.attach_money;
            }

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 2,
              child: ListTile(
                leading: Icon(iconData,
                    color: Colors.blue[700]), // Warna ikon pemasukan
                title: Text(
                  nama,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: tanggal != null
                    ? Text(DateFormat('dd MMM yyyy').format(tanggal))
                    : null,
                trailing: Text(
                  formatter.format(jumlah),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                      fontSize: 16),
                ),
                onTap: () {
                  // Untuk demo, kita bisa panggil form pengeluaran untuk edit juga
                  // Atau buat form_pemasukan_page.dart terpisah
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FormPengeluaranPage(
                        // Bisa diganti FormPemasukanPage jika ada
                        id: id,
                        initialNama: nama,
                        initialJumlah: jumlah,
                        initialTanggal: tanggal,
                      ),
                    ),
                  );
                },
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Hapus Pemasukan'),
                      content:
                          Text('Apakah Anda yakin ingin menghapus "$nama"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Batal'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await pemasukanRef.doc(id).delete();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: const Text('Hapus',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
