import 'package:flutter/material.dart';

class PetDetailsScreen extends StatelessWidget {
  final String petName;
  final String species;
  final String breed;
  final String age;
  final String birthday;
  final String ownerName;
  final String streetAddress;
  final String city;
  final String zipCode;
  final String vaccinationStatus;
  final String dietaryRequirements;
  final String additionalNotes;

  const PetDetailsScreen({
    super.key,
    required this.petName,
    required this.species,
    required this.breed,
    required this.age,
    required this.birthday,
    required this.ownerName,
    required this.streetAddress,
    required this.city,
    required this.zipCode,
    required this.vaccinationStatus,
    required this.dietaryRequirements,
    required this.additionalNotes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Biodata'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(
                  'assets/pet_image.jpg'), // Add your image asset here
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                petName,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            _buildSection('Pet Details', [
              _buildDetailRow('Name', petName),
              _buildDetailRow('Species', species),
              _buildDetailRow('Breed', breed),
              _buildDetailRow('Birthday', birthday),
              _buildDetailRow('Age', age),
            ]),
            _buildSection('Owner Information', [
              _buildDetailRow('Owner Name', ownerName),
              _buildDetailRow('City', city),
              _buildDetailRow('Street Address', streetAddress),
              _buildDetailRow('Zip Code', zipCode),
            ]),
            _buildSection('Medical Details', [
              _buildDetailRow('Vaccination Status', vaccinationStatus),
              _buildDetailRow('Dietary Requirements', dietaryRequirements),
              _buildTextArea('Additional Notes', additionalNotes),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
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

  Widget _buildTextArea(String label, String value) {
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
            child: Text(
              value,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
