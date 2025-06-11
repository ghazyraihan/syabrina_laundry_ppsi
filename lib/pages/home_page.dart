import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'katalog_page.dart';
import 'pesanan_page.dart';
import 'keuangan_page.dart';
import 'profile.dart'; // Pastikan path ini benar

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userName = 'Pengguna'; // Default value

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  // Fungsi untuk mendapatkan nama pengguna dari Firebase Auth
  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        // Prioritaskan displayName jika ada
        if (user.displayName != null && user.displayName!.isNotEmpty) {
          _userName = user.displayName!;
        } else if (user.email != null && user.email!.isNotEmpty) {
          // Jika displayName kosong, ambil bagian sebelum '@' dari email
          _userName = user.email!.split('@')[0];
        } else {
          _userName = 'Pengguna'; // Fallback jika tidak ada displayName atau email
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Halo!', style: TextStyle(fontSize: 16, color: Colors.white70)), // Tambahkan warna teks
            Text(
              _userName, // Menggunakan nama pengguna dari Firebase
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white70, // Tambahkan warna teks
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, size: 30, color: Colors.white), // Tambahkan warna ikon
            onPressed: () async { // <--- Tambahkan 'async' di sini
              final result = await Navigator.push( // <--- Tambahkan 'await' di sini
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
              // Jika ada hasil dari ProfilePage (yang berarti pembaruan sukses)
              if (result == true) {
                _loadUserName(); // Muat ulang nama pengguna
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Kartu untuk Katalog
            buildMenuCard(context, 'KATALOG', Icons.menu_book, KatalogPage()),
            const SizedBox(height: 16),
            // Kartu untuk Pesanan
            buildMenuCard(
                context, 'PESANAN', Icons.receipt_long, PesananPage()),
            const SizedBox(height: 16),
            // Kartu untuk Keuangan
            buildMenuCard(
                context, 'KEUANGAN', Icons.attach_money, KeuanganPage()),
          ],
        ),
      ),
    );
  }

  Widget buildMenuCard(BuildContext context, String title, IconData icon,
      Widget destinationPage) {
    return 
    //Expanded( // <--- Tambahkan Expanded di sini agar kartu mengisi ruang
      //child: 
      GestureDetector(
        onTap: () async { // <--- Tambahkan async di sini jika mau menangani hasil balik
          // Jika Anda ingin _loadUserName() dipanggil setelah kembali dari halaman tujuan,
          // Anda bisa melakukan hal serupa seperti navigasi ke ProfilePage
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destinationPage),
          );
          // Jika halaman tujuan bisa mengubah data yang relevan dengan Home (misal: order baru),
          // Anda bisa panggil _loadUserName() atau fungsi refresh lainnya di sini.
          // Untuk saat ini, kita hanya memanggil _loadUserName() jika kembali dari ProfilePage.
        },
        child: Container(
          height: 100, // <--- Hapus atau sesuaikan, karena Expanded akan mengatur tinggi
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.blue[400],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 36, color: Colors.black),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                )
              ],
            ),
          ),
        ),
      //),
    );
  }
}