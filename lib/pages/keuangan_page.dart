import 'package:flutter/material.dart';

class KeuanganPage extends StatefulWidget {
  const KeuanganPage({super.key});

  @override
  State<KeuanganPage> createState() => _KeuanganPageState();
}

class _KeuanganPageState extends State<KeuanganPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> pengeluaranList = [];

  final TextEditingController namaController = TextEditingController();
  final TextEditingController jumlahController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    namaController.dispose();
    jumlahController.dispose();
    super.dispose();
  }

  void _showForm({int? index}) {
    // Jika index tidak null, isi data untuk edit
    if (index != null) {
      namaController.text = pengeluaranList[index]['nama'];
      jumlahController.text = pengeluaranList[index]['jumlah'];
    } else {
      namaController.clear();
      jumlahController.clear();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(index == null ? 'Tambah Pengeluaran' : 'Edit Pengeluaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: jumlahController,
              decoration: const InputDecoration(labelText: 'Jumlah (Rp)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          if (index != null)
            TextButton(
              onPressed: () {
                setState(() {
                  pengeluaranList.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              namaController.clear();
              jumlahController.clear();
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (namaController.text.isNotEmpty &&
                  jumlahController.text.isNotEmpty) {
                setState(() {
                  if (index == null) {
                    // Tambah
                    pengeluaranList.add({
                      'nama': namaController.text,
                      'jumlah': jumlahController.text,
                    });
                  } else {
                    // Edit
                    pengeluaranList[index] = {
                      'nama': namaController.text,
                      'jumlah': jumlahController.text,
                    };
                  }
                });
                Navigator.pop(context);
              }
            },
            child: Text(index == null ? 'Simpan' : 'Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMasuk = _selectedIndex == 0;

    return Scaffold(
      backgroundColor: isMasuk ? Colors.blue[700] : Colors.red[700],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("KEUANGAN"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: "Masuk"),
              Tab(text: "Keluar"),
            ],
          ),
          Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height * 0.8,
            child: TabBarView(
              controller: _tabController,
              children: [
                // ================= Tab Masuk =================
                Column(
                  children: [
                    const SizedBox(height: 16),
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: const ListTile(
                        title: Text("Pemasukan bulan ini"),
                        subtitle: Text("Rp 7.000,00"),
                        trailing: Text("Rp 90.000,00"),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Pemasukan",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: const [
                          ListTile(
                            leading: Icon(Icons.local_laundry_service),
                            title: Text("CUCI KERING"),
                            trailing: Text("Rp 12.000,00"),
                          ),
                          ListTile(
                            leading: Icon(Icons.local_laundry_service),
                            title: Text("SETRIKA"),
                            trailing: Text("Rp 14.000,00"),
                          ),
                          ListTile(
                            leading: Icon(Icons.local_laundry_service),
                            title: Text("CUCI & SETRIKA"),
                            trailing: Text("Rp 21.000,00"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // ================= Tab Keluar =================
                Column(
                  children: [
                    const SizedBox(height: 16),
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: const ListTile(
                        title: Text("Pengeluaran bulan ini"),
                        subtitle: Text("Rp 7.000,00"),
                        trailing: Text("Rp 90.000,00"),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Pengeluaran",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          const ListTile(
                            leading: Icon(Icons.money_off),
                            title: Text("Gaji Karyawan"),
                            trailing: Text("Rp 23.000,00"),
                          ),
                          const ListTile(
                            leading: Icon(Icons.lightbulb),
                            title: Text("Listrik"),
                            trailing: Text("Rp 18.000,00"),
                          ),
                          const ListTile(
                            leading: Icon(Icons.shopping_bag),
                            title: Text("Pewangi"),
                            trailing: Text("Rp 11.000,00"),
                          ),
                          for (int i = 0; i < pengeluaranList.length; i++)
                            ListTile(
                              leading: const Icon(Icons.money_off),
                              title: Text(pengeluaranList[i]['nama']),
                              trailing:
                                  Text("Rp ${pengeluaranList[i]['jumlah']}"),
                              onTap: () => _showForm(index: i),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: isMasuk
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.red[700],
              child: const Icon(Icons.add),
              onPressed: () => _showForm(),
            ),
    );
  }
}
