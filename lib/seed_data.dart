import 'package:cloud_firestore/cloud_firestore.dart';

class SeedData {
  static Future<void> seedCars() async {
    CollectionReference cars = FirebaseFirestore.instance.collection('cars');

    final List<Map<String, dynamic>> carData = [
      {
        "name": "Toyota Fortuner",
        "price": 25000,
        "image": "https://images.unsplash.com/photo-1611175694988-cd1b88e15d7b"
      },
      {
        "name": "Tesla Model S",
        "price": 80000,
        "image": "https://images.unsplash.com/photo-1549924231-f129b911e442"
      },
      {
        "name": "BMW X5",
        "price": 65000,
        "image": "https://images.unsplash.com/photo-1616594039964-2ab4585a9c48"
      },
      {
        "name": "Mercedes-Benz C-Class",
        "price": 60000,
        "image": "https://images.unsplash.com/photo-1583267742921-3298f6d79de6"
      },
      {
        "name": "Audi Q7",
        "price": 70000,
        "image": "https://images.unsplash.com/photo-1588943211346-3807d3e6a4d8"
      },
    ];

    for (var car in carData) {
      await cars.add(car);
    }

    print("✅ Car data seeded successfully.");
  }
}
