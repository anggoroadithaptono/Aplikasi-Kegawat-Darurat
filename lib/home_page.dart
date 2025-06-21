import 'package:flutter/material.dart';
import 'database_helper.dart';

class HomePage extends StatelessWidget {
  final db = DatabaseHelper();

  void _addSampleUser() async {
    await db.insertUser({
      'name': 'Anggo',
      'email': 'anggo@email.com',
    });
  }

  void _printUsers() async {
    final users = await db.getUsers();
    print(users);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Local DB (Sqflite)")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: _addSampleUser, child: Text("Add User")),
            ElevatedButton(onPressed: _printUsers, child: Text("Show Users")),
          ],
        ),
      ),
    );
  }
}
