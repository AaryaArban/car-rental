import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'buy_car_screen.dart';
import 'package:intl/intl.dart';

class ExploreScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Explore Cars"),
        backgroundColor: Colors.indigo.shade700,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('cars').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var cars = snapshot.data!.docs;

          return GridView.builder(
            padding: EdgeInsets.all(12),
            itemCount: cars.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.68,
            ),
            itemBuilder: (context, index) {
              var car = cars[index];

              final image = car['image'];
              final name = car['name'];
              final price = car['price'];

              final rentedByName = car['rentedByName'] ?? "Unknown";

              DateTime? rentedUntil;
              final rawDate = car['rentedUntil'];
              if (rawDate is Timestamp) {
                rentedUntil = rawDate.toDate();
              } else if (rawDate is String) {
                try {
                  rentedUntil = DateTime.parse(rawDate);
                } catch (e) {
                  rentedUntil = null;
                }
              }

              bool isRented = false;
              if (rentedUntil != null) {
                isRented = rentedUntil.isAfter(DateTime.now());
              }

              return Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Center(child: Icon(Icons.broken_image, size: 50)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 6),
                            Text(
                              "₹$price / day",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 6),
                            if (isRented)
                              Text(
                                "Rented by $rentedByName\nuntil ${DateFormat('dd MMM yyyy').format(rentedUntil!)}",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.red.shade700,
                                  fontStyle: FontStyle.italic,
                                ),
                              )
                            else
                              Text(
                                "Available for rent",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            Spacer(),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isRented
                                      ? Colors.grey
                                      : Colors.indigo,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: isRented
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => BuyCarScreen(car: car),
                                          ),
                                        );
                                      },
                                child: Text("Rent Now"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// 👇 Optional: Function to clear expired bookings (if needed in future)
Future<void> clearExpiredBookings() async {
  final now = DateTime.now();
  final snapshot = await FirebaseFirestore.instance.collection('cars').get();

  for (var doc in snapshot.docs) {
    final rentedUntil = (doc['rentedUntil'] is Timestamp)
        ? (doc['rentedUntil'] as Timestamp).toDate()
        : null;

    if (rentedUntil != null && rentedUntil.isBefore(now)) {
      await doc.reference.update({
        'bookedBy': null,
        'rentedUntil': null,
        'rentedByName': null,
      });
    }
  }
}
