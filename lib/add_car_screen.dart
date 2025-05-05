import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddCarScreen extends StatefulWidget {
  @override
  _AddCarScreenState createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  bool isLoading = false;

  Future<void> addCar() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⚠️ User not logged in")),
        );
        return;
      }

      final ownerEmail = user.email ?? 'unknown@email.com';

      await FirebaseFirestore.instance.collection('cars').add({
        'name': nameController.text,
        'price': double.parse(priceController.text),
        'image': imageController.text,
        'ownerId': user.uid,
        'ownerName': ownerNameController.text,
        'ownerEmail': ownerEmail,
        'isRented': false,
        'rentedBy': null,
        'rentedByName': null,
        'rentedUntil': null,
      });

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Car Added Successfully!")),
      );

      nameController.clear();
      priceController.clear();
      imageController.clear();
      ownerNameController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Car"),
        backgroundColor: Colors.indigo.shade700,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade50, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  "Enter Car Details",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade800,
                  ),
                ),
                SizedBox(height: 20),

                // Car Name
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Car Name",
                    prefixIcon: Icon(Icons.directions_car),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter car name' : null,
                ),
                SizedBox(height: 15),

                // Price
                TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Price (per day ₹)",
                    prefixIcon: Icon(Icons.currency_rupee),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter rental price' : null,
                ),
                SizedBox(height: 15),

                // Image URL
                TextFormField(
                  controller: imageController,
                  decoration: InputDecoration(
                    labelText: "Car Image URL",
                    prefixIcon: Icon(Icons.image),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter image URL' : null,
                  onChanged: (_) => setState(() {}),
                ),
                SizedBox(height: 15),

                // Owner Name
                TextFormField(
                  controller: ownerNameController,
                  decoration: InputDecoration(
                    labelText: "Owner Name",
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter owner name' : null,
                ),
                SizedBox(height: 25),

                // Image preview
                if (imageController.text.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageController.text,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(),
                    ),
                  ),

                SizedBox(height: 30),

                isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton.icon(
                        icon: Icon(Icons.add_circle_outline),
                        label: Text("Add Car"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                          textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: addCar,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
