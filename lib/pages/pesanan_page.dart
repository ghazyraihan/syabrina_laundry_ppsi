import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PesananPage extends StatefulWidget {
  const PesananPage({Key? key}) : super(key: key);

  @override
  State<PesananPage> createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  DateTimeRange? selectedDateRange;
  String layananFilter = 'Semua';
  String pembayaranFilter = 'Semua';
  String pengerjaanFilter = 'Semua';
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();

  void _showPaymentStatusDialog(String docId, bool isLunas, String nama) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Status Pembayaran'),
        content: Text('Ubah status pembayaran "$nama" menjadi:'),
        actions: [
          if (!isLunas)
            TextButton(
              onPressed: () async {
                await _updateStatusPembayaran(docId, 'Lunas');
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.green),
              child: const Text('Lunas'),
            ),
          if (isLunas)
            TextButton(
              onPressed: () async {
                await _updateStatusPembayaran(docId, 'Belum Lunas');
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.orange),
              child: const Text('Belum Lunas'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  void _showPengerjaanDialog(String docId, String currentStatus, String nama) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ubah status pengerjaan "$nama" menjadi:'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (currentStatus != 'Antrian')
                TextButton(
                  onPressed: () {
                    _updateWorkStatus(docId, 'Antrian');
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 233, 221, 0),
                    alignment: Alignment.centerLeft,
                  ),
                  child: const Text('Antrian'),
                ),
              if (currentStatus != 'Sedang Dikerjakan')
                TextButton(
                  onPressed: () {
                    _updateWorkStatus(docId, 'Sedang Dikerjakan');
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.lightBlue,
                    alignment: Alignment.centerLeft,
                  ),
                  child: const Text('Sedang Dikerjakan'),
                ),
              if (currentStatus != 'Selesai')
                TextButton(
                  onPressed: () {
                    _updateWorkStatus(docId, 'Selesai');
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                    alignment: Alignment.centerLeft,
                  ),
                  child: const Text('Selesai'),
                ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Konfirmasi'),
                      content: Text('Yakin ingin membatalkan pesanan "$nama"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Batal'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('pesanan')
                                .doc(docId)
                                .delete();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pesanan berhasil dibatalkan'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          },
                          child: const Text('Hapus Pesanan'),
                        ),
                      ],
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  alignment: Alignment.centerLeft,
                ),
                child: const Text('Batalkan Pesanan'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateStatusPembayaran(String docId, String newStatus) async {
    await FirebaseFirestore.instance.collection('pesanan').doc(docId).update({
      'statusPembayaran': newStatus,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status pembayaran diubah menjadi $newStatus'),
        backgroundColor: newStatus == 'Lunas'
            ? Colors.green.shade600
            : Colors.orange.shade600,
      ),
    );
  }

  void _updateWorkStatus(String docId, String status) async {
    await FirebaseFirestore.instance
        .collection('pesanan')
        .doc(docId)
        .update({'statusPengerjaan': status});
  }

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

  bool _isWithinRange(Timestamp? ts) {
    if (ts == null || selectedDateRange == null) return true;
    final d = ts.toDate();
    return d.isAfter(
            selectedDateRange!.start.subtract(const Duration(days: 1))) &&
        d.isBefore(selectedDateRange!.end.add(const Duration(days: 1)));
  }

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

  TableRow _buildInfoRowTable(String label, String value, {Color? textColor}) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child:
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 2),
          child: Text(':'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            value,
            style: TextStyle(color: textColor ?? Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildPesananCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final isLunas = data['statusPembayaran'] == 'Lunas';
    final pengerjaan = data['statusPengerjaan'] ?? 'Antrian';

    final borderColor = isLunas ? Colors.green : Colors.orange;
    final bgColor = pengerjaan == 'Antrian'
        ? Colors.orange.shade50
        : pengerjaan == 'Sedang Dikerjakan'
            ? Colors.blue.shade50
            : Colors.grey.shade100;

    return InkWell(
      onTap: () => _showPaymentStatusDialog(
          doc.id, isLunas, data['nama_pelanggan'] ?? ''),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        elevation: 5,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        color: bgColor,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.person, size: 36, color: Colors.black54),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['nama_pelanggan'] ?? '-',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Table(
                      columnWidths: const {
                        0: IntrinsicColumnWidth(),
                        1: FixedColumnWidth(10),
                        2: FlexColumnWidth(),
                      },
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: [
                        _buildInfoRowTable(
                          'Tanggal Masuk',
                          data['tanggal'] != null
                              ? DateFormat('dd MMM yyyy')
                                  .format(data['tanggal'].toDate())
                              : '-',
                        ),
                        _buildInfoRowTable(
                            'Jenis Layanan', data['jenisLayanan'] ?? '-'),
                        _buildInfoRowTable('Status Pengerjaan', pengerjaan),
                        _buildInfoRowTable(
                          'Status Pembayaran',
                          data['statusPembayaran'] ?? '-',
                          textColor: isLunas ? Colors.green : Colors.orange,
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 2),
                              child: Text('Total Harga',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600)),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 2),
                              child: Text(':'),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                data['total_harga'] != null
                                    ? NumberFormat.currency(
                                        locale: 'id_ID',
                                        symbol: 'Rp ',
                                        decimalDigits: 0, // hilangkan koma
                                      ).format(data['total_harga'])
                                    : '-',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold, // buat tebal
                                  fontSize: 16, // ukuran lebih besar
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: pengerjaan == 'Antrian'
                          ? Colors.orange
                          : pengerjaan == 'Sedang Dikerjakan'
                              ? Colors.lightBlue
                              : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _showPengerjaanDialog(
                        doc.id, pengerjaan, data['nama_pelanggan'] ?? ''),
                    child: Text(
                      pengerjaan,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pesanan'),
        backgroundColor: Colors.blue.shade600,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Filter',
            onPressed: () {
              setState(() {
                searchQuery = '';
                layananFilter = 'Semua';
                pembayaranFilter = 'Semua';
                pengerjaanFilter = 'Semua';
                selectedDateRange = null;
                searchController.clear(); // <- ini yang membuat TextField reset
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: 'Pilih Rentang Tanggal',
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: Column(
        children: [
          ExpansionTile(
            title: const Text('Filter Pencarian'),
            leading: const Icon(Icons.filter_list),
            initiallyExpanded: false,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: 'Cari nama pelanggan',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                      onChanged: (v) => setState(() => searchQuery = v),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('katalog')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const CircularProgressIndicator();
                              }

                              // Ambil daftar layanan dari Firestore + tambahkan 'Semua' di awal
                              final List<String> layananList = [
                                'Semua',
                                ...snapshot.data!.docs
                                    .map((doc) => doc['nama'].toString())
                              ];

                              return DropdownButtonFormField<String>(
                                value: layananFilter,
                                decoration: InputDecoration(
                                  labelText: 'Layanan',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                ),
                                items: layananList
                                    .map((e) => DropdownMenuItem(
                                        value: e, child: Text(e)))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => layananFilter = v!),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: pembayaranFilter,
                            decoration: InputDecoration(
                              labelText: 'Pembayaran',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                            ),
                            items: ['Semua', 'Lunas', 'Belum Lunas']
                                .map((e) =>
                                    DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => pembayaranFilter = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: pengerjaanFilter,
                      decoration: InputDecoration(
                        labelText: 'Status Pengerjaan',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                      items: [
                        'Semua',
                        'Antrian',
                        'Sedang Dikerjakan',
                        'Selesai',
                        'Dibatalkan'
                      ]
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => pengerjaanFilter = v!),
                    ),
                  ],
                ),
              )
            ],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pesanan')
                  .orderBy('tanggal', descending: true)
                  .snapshots(),
              builder: (c, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snap.data!.docs.where((doc) {
                  final d = doc.data() as Map<String, dynamic>;
                  return _isWithinRange(d['tanggal']) && _matchesFilter(d);
                }).toList();

                final pending = docs.where((doc) {
                  final d = doc.data() as Map<String, dynamic>;
                  return !(d['statusPembayaran'] == 'Lunas' &&
                      d['statusPengerjaan'] == 'Selesai');
                }).toList();

                final selesai = docs.where((doc) {
                  final d = doc.data() as Map<String, dynamic>;
                  return d['statusPembayaran'] == 'Lunas' &&
                      d['statusPengerjaan'] == 'Selesai';
                }).toList();

                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    if (pending.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.only(left: 12, top: 8),
                        child: Text('Pesanan Pending',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    for (var doc in pending) _buildPesananCard(doc),
                    if (selesai.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.only(left: 12, top: 16),
                        child: Text('Pesanan Selesai',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    for (var doc in selesai) _buildPesananCard(doc),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
