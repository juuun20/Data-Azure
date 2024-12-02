import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/owners_form.dart';

class PetFormScreen extends StatefulWidget {
  const PetFormScreen({super.key});

  @override
  _PetFormScreen createState() => _PetFormScreen();
}

class _PetFormScreen extends State<PetFormScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> owners = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchOwners();
  }

  Future<void> fetchOwners() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('users').get();
      setState(() {
        owners = snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList();
      });
    } catch (e) {
      print('Error fetching owners: $e');
    }
  }
  Future<List<Map<String, dynamic>>> fetchPets(String ownerId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('pets')
          .where('userId', isEqualTo: ownerId)
          .get();
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print('Error fetching pets: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/dashboard');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Pet Owners"),
          backgroundColor: Colors.brown,
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: const Icon(Icons.mic),
                  hintText: "Search by owner name...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // List of Owners
            Expanded(
              child: ListView.builder(
                itemCount: owners.length,
                itemBuilder: (context, index) {
                  final owner = owners[index];
                  if (searchQuery.isNotEmpty &&
                      !owner["username"]!.toLowerCase().contains(searchQuery)) {
                    return Container();
                  }
                  bool isCurrentUser = owner['id'] == _auth.currentUser?.uid;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Card(
                      elevation: 2,
                      child: ListTile(
                        title: Text(owner["username"] ?? ''),
                        subtitle: Text("Email: ${owner["email"] ?? ''}"),
                        trailing: isCurrentUser
                            ? const Text(
                                "Yours",
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold),
                              )
                            : null,
                        onTap: () async {
                          final pets = await fetchPets(owner['id']);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OwnerDetailScreen(
                                ownerData: owner,
                                pets: pets,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const PetOwnerProfileScreen()),
            );
          },
          backgroundColor: Colors.brown,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchPets(String ownerId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('pets')
          .where('userId', isEqualTo: ownerId)
          .get();
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print('Error fetching pets: $e');
      return [];
    }
  }
}

class OwnerDetailScreen extends StatelessWidget {
  final Map<String, dynamic> ownerData;
  final List<Map<String, dynamic>> pets;

  const OwnerDetailScreen({
    super.key,
    required this.ownerData,
    required this.pets,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Owner Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(ownerData["image"] ?? ''),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ownerData['username'] ?? '',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoField('Full Name', ownerData['username']),
              _buildInfoField('Email', ownerData['email']),
              _buildInfoField('Phone Number', ownerData['phoneNumber']),
              _buildInfoField('Street Address', ownerData['streetAddress']),
              _buildInfoField('City', ownerData['city']),
              _buildInfoField('ZIP Code', ownerData['zipCode']),
              const SizedBox(height: 16),
              const Text(
                "Owner's Pets",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...pets.map((pet) => GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PetDetailScreen(petData: pet),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: Colors.grey),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(pet["image"] ?? ''),
                        ),
                        title: Text(pet['name'] ?? ''),
                        subtitle: Text("Breed: ${pet['breed'] ?? ''}"),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextFormField(
        initialValue: value ?? '',
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
        ),
        readOnly: true,
      ),
    );
  }
}

class PetDetailScreen extends StatelessWidget {
  final Map<String, dynamic> petData;

  const PetDetailScreen({super.key, required this.petData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(petData['name'] ?? 'Pet Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              petData['name'] ?? '',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Breed: ${petData['breed'] ?? ''}"),
            const SizedBox(height: 8),
            Text("Age: ${petData['age'] ?? ''}"),
            const SizedBox(height: 8),
            Text("Type: ${petData['typeOfPet'] ?? ''}"),
            const SizedBox(height: 8),
            Text("Vaccination Status: ${petData['vaccinationStatus'] ?? ''}"),
            // Add more fields as needed
          ],
        ),
      ),
    );
  }
}
