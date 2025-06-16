import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'katalog_page.dart';
import 'pesanan_page.dart';
import 'keuangan_page.dart';
import 'profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userName = 'Pengguna';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        if (user.displayName != null && user.displayName!.isNotEmpty) {
          _userName = user.displayName!;
        } else if (user.email != null && user.email!.isNotEmpty) {
          _userName = user.email!.split('@')[0];
        } else {
          _userName = 'Pengguna';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      _MenuItem(
          title: 'KATALOG', icon: Icons.menu_book, page: const KatalogPage()),
      _MenuItem(
          title: 'PESANAN',
          icon: Icons.receipt_long,
          page: const PesananPage()),
      _MenuItem(
          title: 'KEUANGAN',
          icon: Icons.attach_money,
          page: const KeuanganPage()),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Halo!',
                style: TextStyle(fontSize: 16, color: Colors.white70)),
            Text(
              _userName,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, size: 30, color: Colors.white),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
              if (result == true) {
                _loadUserName();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: menuItems
              .map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _MenuItemCard(item: item),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final Widget page;

  _MenuItem({required this.title, required this.icon, required this.page});
}

class _MenuItemCard extends StatelessWidget {
  final _MenuItem item;

  const _MenuItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => item.page),
        );
      },
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(16),
              child: Icon(item.icon, size: 32, color: Colors.blue.shade800),
            ),
            const SizedBox(width: 20),
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
