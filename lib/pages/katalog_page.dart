import 'package:flutter/material.dart';

class KatalogPage extends StatelessWidget {
  const KatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Katalog')),
      body: const Center(child: Text('Ini halaman Katalog')),
    );
  }
}
