import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Function to show a snackbar
void showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

// Function to build a loading indicator
Widget buildLoadingIndicator() {
  return const Center(
    child: CircularProgressIndicator(),
  );
}

// Function to build a Firestore StreamBuilder
Widget buildFirestoreStreamBuilder({
  required Stream<QuerySnapshot> stream,
  required Widget Function(BuildContext, List<DocumentSnapshot>) builder,
}) {
  return StreamBuilder<QuerySnapshot>(
    stream: stream,
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return buildLoadingIndicator();
      }
      return builder(context, snapshot.data!.docs);
    },
  );
}

// Function to build a pet list tile
Widget buildPetListTile(Map<String, dynamic> data) {
  return Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
              data['image'] ?? 'https://via.placeholder.com/150'),
        ),
        title: Text(data['name'] ?? 'Unknown'),
        subtitle: Text("Breed: ${data['breed'] ?? 'Unknown'}"),
        isThreeLine: true,
      ),
    ),
  );
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