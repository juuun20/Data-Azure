import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PetOwnerProfileScreen extends StatefulWidget {
  const PetOwnerProfileScreen({super.key});

  @override
  _PetOwnerProfileScreenState createState() => _PetOwnerProfileScreenState();
}

class _PetOwnerProfileScreenState extends State<PetOwnerProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  String _fullName = '';
  String _phoneNumber = '';
  String _streetAddress = '';
  String _city = '';
  String _zipCode = '';
  List<Map<String, dynamic>> _pets = [];
  String? _hoveredPetId;
  String _selectedPetType = 'All';
  String _ownerName = '';
  String _contactNumber = '';
  String _email = '';

  final List<String> _petTypes = [
    'All',
    'Dog',
    'Cat',
    'Bird',
    'Fish',
    'Reptile'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadUserPets();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _fullName = userDoc['username'] ?? '';
          _phoneNumber = userDoc['phoneNumber'] ?? '';
          _streetAddress = userDoc['streetAddress'] ?? '';
          _city = userDoc['city'] ?? '';
          _zipCode = userDoc['zipCode'] ?? '';
          _ownerName = userDoc['username'] ?? '';
          _contactNumber = userDoc['phoneNumber'] ?? '';
          _email = userDoc['email'] ?? '';
        });
      }
    }
  }

  Future<void> _loadUserPets() async {
    User? user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot petSnapshot = await _firestore
          .collection('pets')
          .where('userId', isEqualTo: user.uid)
          .get();
      setState(() {
        _pets = petSnapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    }
  }

  List<Map<String, dynamic>> _getFilteredPets() {
    if (_selectedPetType == 'All') {
      return _pets;
    }
    return _pets.where((pet) => pet['typeOfPet'] == _selectedPetType).toList();
  }

  Future<void> _updateUserData() async {
    await validateAndSubmitForm(
      formKey: _formKey,
      onSubmit: () async {
        User? user = _auth.currentUser;
        if (user != null) {
          await _firestore.collection('users').doc(user.uid).update({
            'username': _fullName,
            'phoneNumber': _phoneNumber,
            'streetAddress': _streetAddress,
            'city': _city,
            'zipCode': _zipCode,
          });
          showSnackbar(context, 'Profile updated successfully');
        }
      },
      context: context,
    );
  }

  void _addPet() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('pets').add({
        'userId': user.uid,
        'name': 'New Pet',
        'breed': 'Unknown',
        'species': 'Unknown',
        'age': 0,
        'birthday': 'Unknown',
        'vaccinationStatus': 'Unknown',
        'dietaryRequirements': 'None',
        'additionalNotes': '',
      });
      _loadUserPets(); // Refresh the pet list
    }
  }

  void _editPet(String petId, Map<String, dynamic> updatedData) async {
    await _firestore.collection('pets').doc(petId).update(updatedData);
    _loadUserPets(); // Refresh the pet list
  }

  void _deletePet(String petId) async {
    await _firestore.collection('pets').doc(petId).delete();
    _loadUserPets(); // Refresh the pet list
  }

  void _showPetDetails(BuildContext context, Map<String, dynamic> pet) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StreamBuilder<DocumentSnapshot>(
          stream: _firestore.collection('users').doc(_auth.currentUser?.uid).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            var userDoc = snapshot.data!;
            _ownerName = userDoc['username'] ?? '';
            _contactNumber = userDoc['phoneNumber'] ?? '';
            _email = userDoc['email'] ?? '';

            return AlertDialog(
              content: SizedBox(
                width: 900,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(
                            'assets/images/${(pet['name'] ?? 'default').toLowerCase()}.jpg'),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pet['name'] ?? 'Unknown',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text('@${(pet['name'] ?? 'unknown').toLowerCase()}'),
                      const SizedBox(height: 16),
                      _buildDetailRow('Breed', pet['breed'] ?? 'Unknown'),
                      _buildDetailRow('Age', '${pet['age'] ?? 'Unknown'} years'),
                      const SizedBox(height: 16),
                      const Text('Owner Information',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      _buildDetailRow('Owner Name', _ownerName),
                      _buildDetailRow('Contact Number', _contactNumber),
                      _buildDetailRow('Email', _email),
                      const SizedBox(height: 16),
                      const Text('Pet Details',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      _buildDetailRow('Medical History',
                          pet['medicalHistory'] ?? 'No known issues'),
                      _buildDetailRow('Vaccination Status',
                          pet['vaccinationStatus'] ?? 'Unknown'),
                      _buildDetailRow('Dietary Requirements',
                          pet['dietaryRequirements'] ?? 'None'),
                      _buildDetailRow(
                          'Additional Notes', pet['additionalNotes'] ?? 'None'),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Owner Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage('assets/images/owner.jpg'),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _fullName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  initialValue: _fullName,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => _fullName = value!,
                  validator: (value) =>
                      value!.isEmpty ? 'Enter a full name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _phoneNumber,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => _phoneNumber = value!,
                  validator: (value) =>
                      value!.isEmpty ? 'Enter a phone number' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _streetAddress,
                  decoration: const InputDecoration(
                    labelText: 'Street Address',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => _streetAddress = value!,
                  validator: (value) =>
                      value!.isEmpty ? 'Enter a street address' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _city,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => _city = value!,
                  validator: (value) => value!.isEmpty ? 'Enter a city' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _zipCode,
                  decoration: const InputDecoration(
                    labelText: 'ZIP Code',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => _zipCode = value!,
                  validator: (value) =>
                      value!.isEmpty ? 'Enter a ZIP code' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _updateUserData,
                  child: const Text('Update Profile'),
                ),
                const SizedBox(height: 24),
                // Pet Type Filter
                Wrap(
                  spacing: 8.0,
                  children: _petTypes.map((type) {
                    return ChoiceChip(
                      label: Text(type),
                      selected: _selectedPetType == type,
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedPetType = selected ? type : 'All';
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                // Pets Section
                const Text(
                  'My Pets',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // StreamBuilder for real-time updates
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('pets')
                      .where('userId', isEqualTo: _auth.currentUser?.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    final pets = snapshot.data!.docs.map((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      data['id'] = doc.id;
                      return data;
                    }).toList();

                    // Apply filtering based on the selected pet type
                    final filteredPets = _selectedPetType == 'All'
                        ? pets
                        : pets
                            .where(
                                (pet) => pet['typeOfPet'] == _selectedPetType)
                            .toList();

                    return Column(
                      children: filteredPets.map((pet) {
                        return SizedBox(
                          width: double.infinity,
                          child: Card(
                            elevation: 2,
                            child: MouseRegion(
                              onEnter: (_) =>
                                  setState(() => _hoveredPetId = pet['id']),
                              onExit: (_) =>
                                  setState(() => _hoveredPetId = null),
                              child: InkWell(
                                onTap: () => _showPetDetails(context, pet),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  decoration: BoxDecoration(
                                    gradient: _hoveredPetId == pet['id']
                                        ? LinearGradient(
                                            colors: [
                                              Colors.blue.shade100,
                                              Colors.blue.shade300
                                            ],
                                          )
                                        : null,
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      radius: 30,
                                      backgroundImage: AssetImage(
                                          'assets/images/${pet['name'].toLowerCase()}.jpg'),
                                    ),
                                    title: Text(
                                      pet['name'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(pet['breed']),
                                    trailing: _buildExpandableButton(
                                      onEdit: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditPetScreen(
                                              petId: pet['id'],
                                              petData: pet,
                                            ),
                                          ),
                                        );
                                      },
                                      onDelete: () => _deletePet(pet['id']),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPetScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showPetOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add Pet'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddPetScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Pet'),
              onTap: () {
                Navigator.pop(context);
                // Implement a way to select a pet and edit
                // Example: _editPet(petId, updatedData);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Pet'),
              onTap: () {
                Navigator.pop(context);
                // Implement a way to select a pet and delete
                // Example: _deletePet(petId);
              },
            ),
          ],
        );
      },
    );
  }

  // Function to build the expandable button
  Widget _buildExpandableButton({
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case 'Edit':
            onEdit();
            break;
          case 'Delete':
            onDelete();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'Edit', child: Text('Edit')),
        const PopupMenuItem(value: 'Delete', child: Text('Delete')),
      ],
    );
  }
}

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  _AddPetScreenState createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _name = '';
  String _breed = '';
  String _typeOfPet = 'Dog';
  String _age = '0';
  DateTime? _birthday;
  String _vaccinationStatus = '';
  String _dietaryRequirements = '';
  String _additionalNotes = '';
  String _medicalHistory = '';

  final List<String> _petTypes = ['Dog', 'Cat', 'Bird', 'Fish', 'Reptile'];
  final TextEditingController _birthdayController = TextEditingController();

  @override
  void dispose() {
    _birthdayController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _birthday) {
      setState(() {
        _birthday = picked;
        _birthdayController.text = DateFormat('MMMM dd, yyyy').format(picked);
        _age = _calculateAge(picked).toString();
      });
    }
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('pets').add({
          'userId': user.uid,
          'name': _name,
          'breed': _breed,
          'typeOfPet': _typeOfPet,
          'age': _age,
          'birthday': _birthday?.toIso8601String() ?? '',
          'vaccinationStatus': _vaccinationStatus,
          'dietaryRequirements': _dietaryRequirements,
          'additionalNotes': _additionalNotes,
          'medicalHistory': _medicalHistory,
        });
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Pet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                onSaved: (value) => _name = value!,
                validator: (value) => value!.isEmpty ? 'Enter a name' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Breed'),
                onSaved: (value) => _breed = value!,
                validator: (value) => value!.isEmpty ? 'Enter a breed' : null,
              ),
              DropdownButtonFormField<String>(
                value: _typeOfPet,
                decoration: const InputDecoration(labelText: 'Type of Pet'),
                items: _petTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _typeOfPet = value!;
                  });
                },
              ),
              ListTile(
                title: TextFormField(
                  controller: _birthdayController,
                  decoration: const InputDecoration(labelText: 'Birthday'),
                  readOnly: true,
                  onTap: () => _selectBirthday(context),
                ),
                trailing: const Icon(Icons.calendar_today),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Age'),
                controller: TextEditingController(text: _age),
                readOnly: true,
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Vaccination Status'),
                onSaved: (value) => _vaccinationStatus = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Enter vaccination status' : null,
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Dietary Requirements'),
                onSaved: (value) => _dietaryRequirements = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Enter dietary requirements' : null,
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Additional Notes'),
                onSaved: (value) => _additionalNotes = value!,
                maxLines: 3, // Make it a text area
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Medical History'),
                onSaved: (value) => _medicalHistory = value!,
                maxLines: 3, // Make it a text area
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Add Pet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditPetScreen extends StatefulWidget {
  final String petId;
  final Map<String, dynamic> petData;

  const EditPetScreen({super.key, required this.petId, required this.petData});

  @override
  _EditPetScreenState createState() => _EditPetScreenState();
}

class _EditPetScreenState extends State<EditPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String _name;
  late String _breed;
  late String _typeOfPet;
  late String _age;
  late String _vaccinationStatus;
  late String _dietaryRequirements;
  late String _additionalNotes;
  late String _medicalHistory;

  @override
  void initState() {
    super.initState();
    _name = widget.petData['name'] ?? '';
    _breed = widget.petData['breed'] ?? '';
    _typeOfPet = widget.petData['typeOfPet'] ?? 'Dog'; // Default to 'Dog'
    _age = widget.petData['age']?.toString() ?? '0';
    _vaccinationStatus = widget.petData['vaccinationStatus'] ?? '';
    _dietaryRequirements = widget.petData['dietaryRequirements'] ?? '';
    _additionalNotes = widget.petData['additionalNotes'] ?? '';
    _medicalHistory = widget.petData['medicalHistory'] ?? '';
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await _firestore.collection('pets').doc(widget.petId).update({
        'name': _name,
        'breed': _breed,
        'typeOfPet': _typeOfPet,
        'age': int.tryParse(_age) ?? 0, // Ensure age is an integer
        'vaccinationStatus': _vaccinationStatus,
        'dietaryRequirements': _dietaryRequirements,
        'additionalNotes': _additionalNotes,
        'medicalHistory': _medicalHistory,
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Pet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                readOnly: true, // Make non-editable
              ),
              TextFormField(
                initialValue: _breed,
                decoration: const InputDecoration(labelText: 'Breed'),
                readOnly: true, // Make non-editable
              ),
              DropdownButtonFormField<String>(
                value: _typeOfPet,
                decoration: const InputDecoration(labelText: 'Type of Pet'),
                items: ['Dog', 'Cat', 'Bird', 'Fish', 'Reptile']
                    .map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: null, // Disable dropdown
              ),
              TextFormField(
                initialValue: _age,
                decoration: const InputDecoration(labelText: 'Age'),
                readOnly: true, // Make non-editable
              ),
              TextFormField(
                initialValue: _vaccinationStatus,
                decoration:
                    const InputDecoration(labelText: 'Vaccination Status'),
                onSaved: (value) => _vaccinationStatus = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Enter vaccination status' : null,
              ),
              TextFormField(
                initialValue: _dietaryRequirements,
                decoration:
                    const InputDecoration(labelText: 'Dietary Requirements'),
                onSaved: (value) => _dietaryRequirements = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Enter dietary requirements' : null,
              ),
              TextFormField(
                initialValue: _additionalNotes,
                decoration:
                    const InputDecoration(labelText: 'Additional Notes'),
                onSaved: (value) => _additionalNotes = value!,
                maxLines: 3,
              ),
              TextFormField(
                initialValue: _medicalHistory,
                decoration: const InputDecoration(labelText: 'Medical History'),
                onSaved: (value) => _medicalHistory = value!,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> validateAndSubmitForm({
  required GlobalKey<FormState> formKey,
  required Future<void> Function() onSubmit,
  required BuildContext context,
}) async {
  if (formKey.currentState!.validate()) {
    formKey.currentState!.save();
    await onSubmit();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Operation successful')),
    );
  }
}

void showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
