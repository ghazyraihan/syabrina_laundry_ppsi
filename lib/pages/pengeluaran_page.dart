// lib/pages/pengeluaran_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'form_pengeluaran_page.dart';

class PengeluaranPage extends StatefulWidget {
  const PengeluaranPage({super.key});

  @override
  State<PengeluaranPage> createState() => _PengeluaranPageState();
}

class _PengeluaranPageState extends State<PengeluaranPage> {
  DateTime? _selectedDate;

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2023),
      lastDate: DateTime(now.year + 1),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pengeluaranRef = FirebaseFirestore.instance.collection('pengeluaran');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.date_range),
                label: const Text("Pilih Tanggal"),
                onPressed: _pickDate,
              ),
              const SizedBox(width: 8),
              if (_selectedDate != null)
                Text(DateFormat('dd MMM yyyy').format(_selectedDate!)),
              if (_selectedDate != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _selectedDate = null),
                ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream:
                pengeluaranRef.orderBy('tanggal', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                    child: Text('Terjadi kesalahan: ${snapshot.error}'));
              }

              if (!snapshot.hasData ||
                  snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

              // Filter berdasarkan tanggal jika dipilih
              docs = docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final tanggal = (data['tanggal'] as Timestamp?)?.toDate();
                if (_selectedDate != null && tanggal != null) {
                  return tanggal.year == _selectedDate!.year &&
                      tanggal.month == _selectedDate!.month &&
                      tanggal.day == _selectedDate!.day;
                }
                return true;
              }).toList();

              docs.sort((a, b) {
                Timestamp? tanggalA =
                    (a.data() as Map<String, dynamic>)['tanggal'] as Timestamp?;
                Timestamp? tanggalB =
                    (b.data() as Map<String, dynamic>)['tanggal'] as Timestamp?;

                if (tanggalA == null && tanggalB == null) return 0;
                if (tanggalA == null) return 1;
                if (tanggalB == null) return -1;
                return tanggalB.compareTo(tanggalA);
              });

              if (docs.isEmpty) {
                return const Center(
                    child: Text('Tidak ada pengeluaran untuk tanggal ini.'));
              }

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final nama = data['nama'] ?? 'Pengeluaran Tidak Dikenal';
                  final jumlah = (data['jumlah'] as num?)?.toInt() ?? 0;
                  final id = docs[index].id;
                  final tanggal = (data['tanggal'] as Timestamp?)?.toDate();

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(nama),
                      subtitle: Text(
                        tanggal != null
                            ? DateFormat('dd MMMM yyyy').format(tanggal)
                            : 'Tanggal Tidak Tersedia',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FormPengeluaranPage(
                                    id: id,
                                    initialNama: nama,
                                    initialJumlah: jumlah,
                                    initialTanggal: tanggal,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
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
          ),
        ),
      ],
    );
  }
}
