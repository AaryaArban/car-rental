import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  String formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  Future<Map<String, String>> fetchOwnerDetails(String carName) async {
    try {
      QuerySnapshot carQuerySnapshot = await FirebaseFirestore.instance
          .collection('cars')
          .where('name', isEqualTo: carName)
          .limit(1) // Assuming car names are unique
          .get();

      if (carQuerySnapshot.docs.isNotEmpty) {
        final carData = carQuerySnapshot.docs.first.data() as Map<String, dynamic>;
        final ownerName = carData['ownerName'] ?? 'Unknown Owner';
        final ownerEmail = carData['ownerEmail'] ?? 'Unknown Email';
        return {'ownerName': ownerName, 'ownerEmail': ownerEmail};
      }
      return {'ownerName': 'Unknown Owner', 'ownerEmail': 'Unknown Email'};
    } catch (e) {
      return {'ownerName': 'Unknown Owner', 'ownerEmail': 'Unknown Email'};
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Booking History"),
          backgroundColor: Colors.indigo.shade700,
        ),
        body: Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Booking History"),
        backgroundColor: Colors.indigo.shade700,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('purchases')
            .where('bookedBy', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error.toString()}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final purchases = snapshot.data?.docs ?? [];

          if (purchases.isEmpty) {
            return Center(child: Text("No bookings yet."));
          }

          return ListView.builder(
            itemCount: purchases.length,
            itemBuilder: (context, index) {
              final data = purchases[index].data() as Map<String, dynamic>;

              final carName = data['carName'] ?? 'Unknown Car';
              final image = data['image'] ?? ''; // <-- changed here
              final pricePerDay = data['price'] ?? 0;
              final days = data['days'] ?? 1;
              final totalPrice = data['totalPrice'] ?? 0;
              final timestamp = data['timestamp'] as Timestamp?;
              final formattedDate = timestamp != null
                  ? formatTimestamp(timestamp)
                  : "Date not available";

              // Fetch owner details based on carName
              return FutureBuilder<Map<String, String>>(
                future: fetchOwnerDetails(carName),
                builder: (context, ownerSnapshot) {
                  if (ownerSnapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: image.isNotEmpty
                                ? Image.network(
                                    image,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.broken_image, size: 70);
                                    },
                                  )
                                : Icon(Icons.directions_car, size: 70),
                          ),
                          title: Text(
                            carName,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Price: ₹$pricePerDay / day"),
                                Text("Days Booked: $days"),
                                Text("Total Price: ₹$totalPrice"),
                                SizedBox(height: 4),
                                Text(
                                  "Date: $formattedDate",
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                SizedBox(height: 8),
                                Text("Loading owner details..."),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  if (ownerSnapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: image.isNotEmpty
                                ? Image.network(
                                    image,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.broken_image, size: 70);
                                    },
                                  )
                                : Icon(Icons.directions_car, size: 70),
                          ),
                          title: Text(
                            carName,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Price: ₹$pricePerDay / day"),
                                Text("Days Booked: $days"),
                                Text("Total Price: ₹$totalPrice"),
                                SizedBox(height: 4),
                                Text(
                                  "Date: $formattedDate",
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                SizedBox(height: 8),
                                Text("Error loading owner details"),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  final ownerData = ownerSnapshot.data;
                  final ownerName = ownerData?['ownerName'] ?? 'Unknown Owner';
                  final ownerEmail = ownerData?['ownerEmail'] ?? 'Unknown Email';

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: image.isNotEmpty
                              ? Image.network(
                                  image,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.broken_image, size: 70);
                                  },
                                )
                              : Icon(Icons.directions_car, size: 70),
                        ),
                        title: Text(
                          carName,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Price: ₹$pricePerDay / day"),
                              Text("Days Booked: $days"),
                              Text("Total Price: ₹$totalPrice"),
                              SizedBox(height: 4),
                              Text(
                                "Date: $formattedDate",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Owner: $ownerName",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text("Email: $ownerEmail"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
