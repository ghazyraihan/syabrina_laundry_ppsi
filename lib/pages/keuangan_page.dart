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
    super.dispose();
  }

  Widget _buildHeader(String label, Color color, String nominal) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.white)),
        const SizedBox(height: 4),
        Text(nominal,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ],
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
                        children: const [
                          ListTile(
                            leading: Icon(Icons.money_off),
                            title: Text("Gaji Karyawan"),
                            trailing: Text("Rp 23.000,00"),
                          ),
                          ListTile(
                            leading: Icon(Icons.lightbulb),
                            title: Text("Listrik"),
                            trailing: Text("Rp 18.000,00"),
                          ),
                          ListTile(
                            leading: Icon(Icons.shopping_bag),
                            title: Text("Pewangi"),
                            trailing: Text("Rp 11.000,00"),
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
              onPressed: () {
                // TODO: Buka form pengeluaran
              },
              backgroundColor: Colors.red[700],
              child: const Icon(Icons.add),
            ),
    );
  }
}
