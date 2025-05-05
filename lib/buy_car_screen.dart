import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class BuyCarScreen extends StatefulWidget {
  final QueryDocumentSnapshot car;

  BuyCarScreen({required this.car});

  @override
  _BuyCarScreenState createState() => _BuyCarScreenState();
}

class _BuyCarScreenState extends State<BuyCarScreen> {
  String userName = "";
  DateTime? rentedUntil;
  int totalDays = 0;

  final _formKey = GlobalKey<FormState>();

  void confirmPurchase(BuildContext context) async {
    if (_formKey.currentState!.validate() && rentedUntil != null && totalDays > 0) {
      try {
        final totalPrice = widget.car.get('price') * totalDays;
        final user = FirebaseAuth.instance.currentUser!;
        final userId = user.uid;
        final userEmail = user.email ?? "Unavailable";

        // Add booking to purchases
        await FirebaseFirestore.instance.collection('purchases').add({
          'carName': widget.car.get('name'),
          'price': widget.car.get('price'),
          'image': widget.car.get('image'),
          'days': totalDays,
          'totalPrice': totalPrice,
          'timestamp': Timestamp.now(),
          'bookedBy': userId,
          'rentedByName': userName,
          'rentedByEmail': userEmail,
          'rentedUntil': rentedUntil,
        });

        // Update car as booked
        await FirebaseFirestore.instance.collection('cars').doc(widget.car.id).update({
          'isBooked': true,
          'bookedBy': userId,
          'rentedByName': userName,
          'rentedByEmail': userEmail,
          'rentedUntil': rentedUntil,
        });

        // Fetch updated car document to pass correct rentedByName
        final updatedCarDoc = await FirebaseFirestore.instance.collection('cars').doc(widget.car.id).get();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PurchaseConfirmationScreen(
              car: updatedCarDoc,
              totalPrice: totalPrice,
              days: totalDays,
              buyerName: userName,
              buyerEmail: userEmail,
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error confirming purchase: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter all details")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pricePerDay = widget.car.get('price');
    final totalPrice = totalDays > 0 ? pricePerDay * totalDays : 0;
    final ownerName = widget.car.get('ownerName') ?? 'Unknown';
    final ownerEmail = widget.car.get('ownerEmail') ?? 'Unavailable';

    return Scaffold(
      appBar: AppBar(
        title: Text("Car Details"),
        backgroundColor: Colors.indigo.shade700,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  widget.car.get('image'),
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 20),
              Text(
                widget.car.get('name'),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "₹$pricePerDay / day",
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
              SizedBox(height: 20),
              Text(
                "This car is equipped with top-notch features ensuring comfort, safety, and performance. Ideal for long trips or city rides.",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(height: 30),

              Text("Owner Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              SizedBox(height: 10),
              Text("Name: $ownerName", style: TextStyle(fontSize: 16)),
              Text("Email: $ownerEmail", style: TextStyle(fontSize: 16)),
              SizedBox(height: 30),

              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => userName = value,
                validator: (value) => value == null || value.isEmpty ? 'Name required' : null,
              ),
              SizedBox(height: 20),
              Text("Select rental end date:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      DateTime today = DateTime.now();
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: today.add(Duration(days: 1)),
                        firstDate: today,
                        lastDate: today.add(Duration(days: 365)),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          rentedUntil = pickedDate;
                          totalDays = pickedDate.difference(today).inDays + 1;
                        });
                      }
                    },
                    child: Text("Select Date"),
                  ),
                  SizedBox(width: 10),
                  Text(
                    rentedUntil == null
                        ? "No date selected"
                        : DateFormat('yyyy-MM-dd').format(rentedUntil!),
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text("Total Days: $totalDays", style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              Text("Total: ₹$totalPrice", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 30),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => confirmPurchase(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text("Confirm Booking", style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PurchaseConfirmationScreen extends StatelessWidget {
  final DocumentSnapshot car;
  final int totalPrice;
  final int days;
  final String buyerName;
  final String buyerEmail;

  PurchaseConfirmationScreen({
    required this.car,
    required this.totalPrice,
    required this.days,
    required this.buyerName,
    required this.buyerEmail,
  });

  @override
  Widget build(BuildContext context) {
    final ownerName = car.get('ownerName') ?? 'Unknown';
    final ownerEmail = car.get('ownerEmail') ?? 'Unavailable';
    final rentedByName = car.get('rentedByName') ?? 'Anonymous';
    final rentedByEmail = car.get('rentedByEmail') ?? 'Unavailable';

    return Scaffold(
      appBar: AppBar(
        title: Text("Booking Confirmed"),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 80),
            SizedBox(height: 20),
            Text(
              "Your car has been successfully booked!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                car.get('image'),
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),
            Text(car.get('name'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text("$days day${days > 1 ? 's' : ''} • ₹$totalPrice total",
                style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            SizedBox(height: 30),
            Divider(),
            Text("Owner Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text("Name: $ownerName"),
            Text("Email: $ownerEmail"),
            SizedBox(height: 20),
            Text("Renter Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text("Name: $rentedByName"),
            Text("Email: $rentedByEmail"),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: Text("Back to Home"),
            ),
          ],
        ),
      ),
    );
  }
}
