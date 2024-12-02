import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'reusable.dart'; // Import the reusable functions

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${user?.email ?? 'User'}!'),
        backgroundColor: Colors.brown,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/petform');
        },
        backgroundColor: Colors.brown,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search pets or owners...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildFirestoreStreamBuilder(
                        stream: _firestore.collection('pets').snapshots(),
                        builder: (context, pets) {
                          final petCount = pets.length;
                          return Column(
                            children: [
                              const Icon(Icons.pets, size: 40, color: Colors.brown),
                              const SizedBox(height: 8),
                              const Text(
                                'Total Pets',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '$petCount',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          );
                        },
                      ),
                      buildFirestoreStreamBuilder(
                        stream: _firestore.collection('users').snapshots(),
                        builder: (context, owners) {
                          final ownerCount = owners.length;
                          return Column(
                            children: [
                              const Icon(Icons.person, size: 40, color: Colors.brown),
                              const SizedBox(height: 8),
                              const Text(
                                'Total Owners',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '$ownerCount',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                buildFirestoreStreamBuilder(
                  stream: _firestore.collection('pets').snapshots(),
                  builder: (context, pets) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Registered Pets (${pets.length})',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...pets.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return buildPetListTile(data);
                        }),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                buildFirestoreStreamBuilder(
                  stream: _firestore.collection('users').snapshots(),
                  builder: (context, owners) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Registered Owners (${owners.length})',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...owners.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      data['image'] ?? 'https://via.placeholder.com/150'),
                                ),
                                title: Text(data['username'] ?? 'Unknown'),
                                subtitle: Text("Email: ${data['email'] ?? 'Unknown'}"),
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
