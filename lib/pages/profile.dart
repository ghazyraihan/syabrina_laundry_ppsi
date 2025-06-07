import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ← ❶ Hapus baris ini jika belum pakai Firestore
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Controller untuk field
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _passwordCtrl;

  bool _isLoading = false; 
  final _auth = FirebaseAuth.instance;

  @override
  void initState() { 
    super.initState();
    final user = _auth.currentUser;

    _nameCtrl = TextEditingController(text: user?.displayName ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _phoneCtrl = TextEditingController();
    _passwordCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return; 

    setState(() => _isLoading = true);
    final user = _auth.currentUser;

    try {
      // ❷ Update Display Name
      if (_nameCtrl.text.trim() != user?.displayName) {
        await user?.updateDisplayName(_nameCtrl.text.trim());
      }

      // ❸ Update Email
      if (_emailCtrl.text.trim() != user?.email) {
        await user?.updateEmail(_emailCtrl.text.trim());
      }

      // ❹ Update Password (jika diisi)
      if (_passwordCtrl.text.trim().isNotEmpty) {
        await user?.updatePassword(_passwordCtrl.text.trim());
      }

      // ❺ Simpan phone number di Firestore (opsional)
      if (_phoneCtrl.text.trim().isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .set({'phone': _phoneCtrl.text.trim()}, SetOptions(merge: true));
      } 

      await user?.reload(); // segarkan data user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal update: ${e.message}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ——— App bar manual
            Container(
              color: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // ——— Form content
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          child: const Icon(Icons.person,
                              size: 50, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        const Text('Change Picture',
                            style: TextStyle(color: Colors.black54)),
                        const SizedBox(height: 24),

                        // Username
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 16),

                        // Email
                        TextFormField(
                          controller: _emailCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v != null && v.contains('@')
                              ? null
                              : 'Email tidak valid',
                        ),
                        const SizedBox(height: 16),

                        // Phone number
                        TextFormField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password (opsional)
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password (baru, opsional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Update button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: _isLoading ? null : _updateProfile,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Update',
                                    style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Logout button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.black12),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: _logout,
                            child: const Text('Logout',
                                style: TextStyle(color: Colors.black)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
