// lib/pages/pengeluaran_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Penting: Pastikan ini sudah diimport
import 'form_pengeluaran_page.dart'; // Pastikan path ini benar

class PengeluaranPage extends StatelessWidget {
  const PengeluaranPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Referensi ke koleksi 'pengeluaran' di Firestore
    final pengeluaranRef = FirebaseFirestore.instance.collection('pengeluaran');

    return StreamBuilder<QuerySnapshot>(
      // Mengambil data dari koleksi 'pengeluaran' dan mengurutkannya berdasarkan 'tanggal'
      // Jika ada dokumen tanpa field 'tanggal', mereka mungkin akan diabaikan oleh orderBy Firestore
      // atau ditempatkan di posisi yang tidak terduga. Penanganan di sisi klien (_sortDocs)
      // akan membantu menempatkan dokumen tanpa tanggal di akhir.
      stream: pengeluaranRef
          .orderBy('tanggal',
              descending: true) // Urutkan dari tanggal terbaru ke terlama
          .snapshots(), // Mendengarkan perubahan data secara real-time
      builder: (context, snapshot) {
        // Tampilkan indikator loading jika belum ada data
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // Tampilkan pesan error jika terjadi kesalahan
        if (snapshot.hasError) {
          return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
        }

        // Ambil dokumen-dokumen dari snapshot
        List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

        // Sorting di sisi klien untuk robustness, terutama jika ada dokumen tanpa 'tanggal'
        // Dokumen tanpa 'tanggal' akan ditempatkan di bagian akhir daftar.
        docs.sort((a, b) {
          Timestamp? tanggalA =
              (a.data() as Map<String, dynamic>)['tanggal'] as Timestamp?;
          Timestamp? tanggalB =
              (b.data() as Map<String, dynamic>)['tanggal'] as Timestamp?;

          // Jika kedua tanggal null, urutan tidak berubah
          if (tanggalA == null && tanggalB == null) return 0;
          // Jika tanggal A null, tempatkan A setelah B
          if (tanggalA == null) return 1;
          // Jika tanggal B null, tempatkan B setelah A
          if (tanggalB == null) return -1;
          // Urutkan secara descending (terbaru di atas)
          return tanggalB.compareTo(tanggalA);
        });

        // Debugging: Cetak jumlah dokumen dan total sementara untuk verifikasi
        print('--- Data PengeluaranPage (Riwayat) ---');
        int tempTotalPengeluaranInList = 0;
        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final dynamic jumlahValue = data['jumlah'];
          final int jumlah = (jumlahValue is num) ? jumlahValue.toInt() : 0;
          tempTotalPengeluaranInList += jumlah;
          final tanggalTimestamp = data['tanggal'] as Timestamp?;
          print(
              '  ID: ${doc.id}, Nama: ${data['nama']}, Jumlah: $jumlah, Tanggal: ${tanggalTimestamp?.toDate()}');
        }
        print(
            'Total Pengeluaran Dihitung di PengeluaranPage List: $tempTotalPengeluaranInList');
        print('--------------------------');

        // Tampilkan pesan jika tidak ada data pengeluaran
        if (docs.isEmpty) {
          return const Center(child: Text('Belum ada data pengeluaran.'));
        }

        // Bangun daftar riwayat pengeluaran menggunakan ListView.builder
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final nama = data['nama'] ??
                'Pengeluaran Tidak Dikenal'; // Default jika nama tidak ada
            final dynamic jumlahValue = data['jumlah'];
            final int jumlah = (jumlahValue is num) ? jumlahValue.toInt() : 0;
            final id = docs[index].id;
            final tanggalTimestamp = data['tanggal'] as Timestamp?;
            final tanggal =
                tanggalTimestamp?.toDate(); // Konversi Timestamp ke DateTime

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(nama),
                subtitle: Text(
                  tanggal != null
                      ? DateFormat('dd MMMM yyyy')
                          .format(tanggal) // Format tanggal jika ada
                      : 'Tanggal Tidak Tersedia', // Tampilkan ini jika tanggal null
                ),
                trailing: Row(
                  mainAxisSize:
                      MainAxisSize.min, // Agar Row tidak mengambil lebar penuh
                  children: [
                    Text(
                      NumberFormat.currency(
                        locale: 'id',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(jumlah),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Navigasi ke FormPengeluaranPage untuk edit
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FormPengeluaranPage(
                              id: id, // ID dokumen untuk mode edit
                              initialNama: nama,
                              initialJumlah: jumlah,
                              initialTanggal:
                                  tanggal, // KIRIM TANGGAL KE FORM EDIT
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        // Hapus dokumen dari Firestore saat tombol delete ditekan
                        await pengeluaranRef.doc(id).delete();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}