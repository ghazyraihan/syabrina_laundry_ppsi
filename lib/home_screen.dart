import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final CollectionReference users = FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Simple CRUD'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: users.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final data = snapshot.requireData;

          return ListView.builder(
            itemCount: data.size,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(data.docs[index]['name']),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => deleteUser(data.docs[index].id),  // Memanggil deleteUser
                ),
                onTap: () {
                  nameController.text = data.docs[index]['name'];
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Update User'),
                      content: TextField(
                        controller: nameController,
                      ),
                      actions: [
                        TextButton(
                          child: Text('Update'),
                          onPressed: () {
                            updateUser(data.docs[index].id, nameController.text);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          nameController.clear();
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Add User'),
              content: TextField(
                controller: nameController,
              ),
              actions: [
                TextButton(
                  child: Text('Add'),
                  onPressed: () {
                    addUser(nameController.text);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Definisikan metode deleteUser, addUser, dan updateUser di dalam kelas HomeScreen
  Future<void> addUser(String name) {
    return users.add({'name': name});
  }

  Future<void> updateUser(String id, String name) {
    return users.doc(id).update({'name': name});
  }

  Future<void> deleteUser(String id) {
    return users.doc(id).delete();
  }
}