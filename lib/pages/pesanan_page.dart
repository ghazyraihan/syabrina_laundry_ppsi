import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PesananPage extends StatefulWidget {
  const PesananPage({Key? key}) : super(key: key);

  @override
  State<PesananPage> createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  // Variabel untuk filter
  DateTimeRange? selectedDateRange;
  String layananFilter = 'Semua';
  String pembayaranFilter = 'Semua';
  String pengerjaanFilter = 'Semua';
  String searchQuery = '';

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

  // Fungsi untuk memperbarui status pengerjaan di Firebase
  Future<void> _updateWorkStatus(String docId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('pesanan').doc(docId).update({
        'statusPengerjaan': newStatus,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status pengerjaan berhasil diubah menjadi $newStatus!'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui status pengerjaan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fungsi baru untuk menghapus pesanan dari Firebase
  Future<void> _cancelOrder(String docId, String? customerName) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Batalkan Pesanan"),
        content: Text("Apakah Anda yakin ingin membatalkan pesanan ${customerName ?? 'ini'}? Pesanan akan dihapus permanen."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Tidak"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text("Ya, Batalkan"),
          ),
        ],
      ),
    );

    if (konfirmasi == true) {
      try {
        await FirebaseFirestore.instance.collection('pesanan').doc(docId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pesanan berhasil dibatalkan dan dihapus!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membatalkan pesanan: $e')),
        );
      }
    }
  }

  // Helper function untuk menampilkan dialog konfirmasi status pembayaran
  void _showPaymentStatusDialog(String docId, bool isLunas, String? customerName) {
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
            'Anda yakin ingin mengubah status pembayaran pesanan ${customerName ?? 'ini'} menjadi ${isLunas ? 'Belum Lunas' : 'Lunas'}?',
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
                backgroundColor: isLunas ? Colors.orange : Colors.green,
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
  }

  // Helper function untuk menampilkan dialog konfirmasi status pengerjaan
  void _showWorkStatusDialog(String docId, String currentStatus, String? customerName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Ubah Status Pengerjaan ${customerName ?? ''}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (currentStatus != 'Antrian')
                ListTile(
                  title: const Text('Antrian'),
                  onTap: () {
                    _updateWorkStatus(docId, 'Antrian');
                    Navigator.of(context).pop();
                  },
                ),
              if (currentStatus != 'Sedang Dikerjakan')
                ListTile(
                  title: const Text('Sedang Dikerjakan'),
                  onTap: () {
                    _updateWorkStatus(docId, 'Sedang Dikerjakan');
                    Navigator.of(context).pop();
                  },
                ),
              if (currentStatus != 'Selesai')
                ListTile(
                  title: const Text('Selesai'),
                  onTap: () {
                    _updateWorkStatus(docId, 'Selesai');
                    Navigator.of(context).pop();
                  },
                ),
              ListTile(
                title: const Text('Batalkan Pesanan', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.of(context).pop();
                  _cancelOrder(docId, customerName);
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk memilih rentang tanggal
  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
      initialDateRange: selectedDateRange,
    );
    if (picked != null) {
      setState(() => selectedDateRange = picked);
    }
  }

  // Helper untuk memeriksa apakah tanggal dalam rentang yang dipilih
  bool _isWithinRange(Timestamp? ts) {
    if (ts == null || selectedDateRange == null) return true;
    final d = ts.toDate();
    // Tambahkan 1 hari ke endDate agar mencakup seluruh hari terakhir
    return d.isAfter(selectedDateRange!.start.subtract(const Duration(days: 1))) &&
           d.isBefore(selectedDateRange!.end.add(const Duration(days: 1)));
  }

  // Helper untuk memeriksa apakah data cocok dengan filter yang diterapkan
  bool _matchesFilter(Map<String, dynamic> d) {
    final mSearch = d['nama_pelanggan']
            ?.toString()
            .toLowerCase()
            .contains(searchQuery.toLowerCase()) ??
        false;
    final mLayanan = layananFilter == 'Semua' ||
        d['jenisLayanan']?.toString() == layananFilter;
    final mBayar = pembayaranFilter == 'Semua' ||
        d['statusPembayaran']?.toString() == pembayaranFilter;
    final mKerja = pengerjaanFilter == 'Semua' ||
        d['statusPengerjaan']?.toString() == pengerjaanFilter;
    return mSearch && mLayanan && mBayar && mKerja;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pesanan'),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
            tooltip: 'Filter Tanggal',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Cari nama pelanggan',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (v) => setState(() => searchQuery = v),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: layananFilter,
                        decoration: const InputDecoration(
                          labelText: 'Filter Layanan',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        items: [
                          'Semua',
                          'Basic Laundry',
                          'Cuci Kering',
                          'Cuci Setrika',
                          'Setrika Saja'
                        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) => setState(() => layananFilter = v!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: pembayaranFilter,
                        decoration: const InputDecoration(
                          labelText: 'Filter Pembayaran',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        items: [
                          'Semua',
                          'Lunas',
                          'Belum Lunas',
                        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) => setState(() => pembayaranFilter = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: pengerjaanFilter,
                  decoration: const InputDecoration(
                    labelText: 'Filter Pengerjaan',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: [
                    'Semua',
                    'Antrian',
                    'Sedang Dikerjakan',
                    'Selesai',
                  ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() => pengerjaanFilter = v!),
                ),
                if (selectedDateRange != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter Tanggal: ${DateFormat('dd MMM yy').format(selectedDateRange!.start)} - ${DateFormat('dd MMM yy').format(selectedDateRange!.end)}',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () => setState(() => selectedDateRange = null),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pesanan')
                  .orderBy('tanggal', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // Filter data berdasarkan semua filter yang diterapkan
                final filteredPesananList = snapshot.data?.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _isWithinRange(data['tanggal'] as Timestamp?) && _matchesFilter(data);
                }).toList() ?? [];

                if (filteredPesananList.isEmpty) {
                  return const Center(
                    child: Text(
                      'Tidak ada pesanan yang cocok dengan filter.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                // Pisahkan pesanan menjadi dua kategori setelah filter
                final List<DocumentSnapshot> pendingPesananList = [];
                final List<DocumentSnapshot> completedPesananList = [];

                for (var doc in filteredPesananList) {
                  final data = doc.data() as Map<String, dynamic>;
                  final statusPengerjaan = data['statusPengerjaan'] ?? 'Antrian';
                  final statusPembayaran = data['statusPembayaran'] ?? 'Belum Lunas';

                  if (statusPengerjaan == 'Selesai' && statusPembayaran == 'Lunas') {
                    completedPesananList.add(doc);
                  } else {
                    pendingPesananList.add(doc);
                  }
                }

                return ListView(
                  padding: const EdgeInsets.all(8.0),
                  children: [
                    // Bagian Pesanan yang Belum Selesai dan/atau Belum Lunas
                    ...pendingPesananList.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final docId = doc.id;
                      final isLunas = data['statusPembayaran'] == 'Lunas';
                      final statusPengerjaan = data['statusPengerjaan'] ?? 'Antrian';

                      // Tentukan warna badge berdasarkan status pengerjaan
                      Color workStatusColor;
                      switch (statusPengerjaan) {
                        case 'Antrian':
                          workStatusColor = Colors.red.shade400;
                          break;
                        case 'Sedang Dikerjakan':
                          workStatusColor = Colors.blue.shade400;
                          break;
                        case 'Selesai':
                          workStatusColor = Colors.green.shade400;
                          break;
                        default:
                          workStatusColor = Colors.grey.shade400;
                      }

                      String tanggalFormatted = '-';
                      if (data['tanggal'] != null && data['tanggal'] is Timestamp) {
                        final tanggal = (data['tanggal'] as Timestamp).toDate();
                        tanggalFormatted = DateFormat('dd MMM HH:mm').format(tanggal);
                      }

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
                                  InkWell(
                                    onTap: () {
                                      _showPaymentStatusDialog(docId, isLunas, data['nama_pelanggan']);
                                    },
                                    child: Container(
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
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  onTap: () {
                                    _showWorkStatusDialog(docId, statusPengerjaan, data['nama_pelanggan']);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: workStatusColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      statusPengerjaan,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
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
                      );
                    }).toList(),

                    // Bagian Pesanan yang Sudah Selesai dan Lunas
                    if (completedPesananList.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                        child: Divider(color: Colors.grey, thickness: 2),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Text(
                          'Pesanan Selesai dan Lunas (Arsip)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      ...completedPesananList.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final docId = doc.id;
                        final isLunas = data['statusPembayaran'] == 'Lunas';
                        final statusPengerjaan = data['statusPengerjaan'] ?? 'Antrian';

                        Color workStatusColor;
                        switch (statusPengerjaan) {
                          case 'Antrian':
                            workStatusColor = Colors.red.shade400;
                            break;
                          case 'Sedang Dikerjakan':
                            workStatusColor = Colors.blue.shade400;
                            break;
                          case 'Selesai':
                            workStatusColor = Colors.green.shade400;
                            break;
                          default:
                            workStatusColor = Colors.grey.shade400;
                        }

                        String tanggalFormatted = '-';
                        if (data['tanggal'] != null && data['tanggal'] is Timestamp) {
                          final tanggal = (data['tanggal'] as Timestamp).toDate();
                          tanggalFormatted = DateFormat('dd MMM HH:mm').format(tanggal);
                        }

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.grey.shade400,
                              width: 1.5,
                            ),
                          ),
                          elevation: 2,
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
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        _showPaymentStatusDialog(docId, isLunas, data['nama_pelanggan']);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade500,
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
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: InkWell(
                                    onTap: () {
                                      _showWorkStatusDialog(docId, statusPengerjaan, data['nama_pelanggan']);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade500,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        statusPengerjaan,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Divider(color: Colors.grey.shade300),
                                _buildInfoRow('Layanan', data['jenisLayanan'] ?? '-', textColor: Colors.grey.shade700),
                                _buildInfoRow('Berat', '${data['berat'] ?? '-'} kg', textColor: Colors.grey.shade700),
                                _buildInfoRow('Total Harga',
                                    'Rp${NumberFormat('#,##0', 'id_ID').format(data['total_harga'] ?? 0)}', textColor: Colors.grey.shade700),
                                _buildInfoRow('Tanggal Masuk', tanggalFormatted, textColor: Colors.grey.shade700),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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
              style: TextStyle(fontSize: 15, color: textColor ?? Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}