import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CarListScreen extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;

  void deleteCar(BuildContext context, String carId) async {
    await FirebaseFirestore.instance.collection('cars').doc(carId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Car deleted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Cars"),
        backgroundColor: Colors.indigo.shade700,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cars')
            .where('ownerId', isEqualTo: user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No cars added yet."));
          }

          final cars = snapshot.data!.docs;

          return ListView.builder(
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final car = cars[index];
              final data = car.data() as Map<String, dynamic>;

              final imageUrl = data['image'] ?? '';
              final rentedByName = data['rentedByName'];
              final rentedByEmail = data['rentedByEmail'];

              DateTime? rentedUntil;

              if (data.containsKey('rentedUntil')) {
                final rawDate = data['rentedUntil'];
                if (rawDate is Timestamp) {
                  rentedUntil = rawDate.toDate();
                } else if (rawDate is String) {
                  try {
                    rentedUntil = DateTime.parse(rawDate);
                  } catch (e) {
                    rentedUntil = null;
                  }
                }
              }

              return ListTile(
                contentPadding: EdgeInsets.all(10),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.broken_image, size: 60);
                          },
                        )
                      : Icon(Icons.directions_car, size: 60),
                ),
                title: Text(data['name'] ?? 'Unnamed Car'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Price: ₹${data['price']} per day'),
                    if (rentedByName != null && rentedByEmail != null) ...[
                      Text('Rented by: $rentedByName'),
                      Text('Email: $rentedByEmail'),
                      if (rentedUntil != null)
                        Text('Rented till: ${rentedUntil.toLocal().toString().split(' ')[0]}'),
                    ] else
                      Text('Currently not rented'),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => deleteCar(context, car.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
