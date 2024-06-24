import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PetModel with ChangeNotifier {
  final String petId,
      petTitle,
      petFname,
      petCategory,
      petLostnfound,
      petDescription,
      petImage,
      petPhone;
  PetModel({
    required this.petId,
    required this.petTitle,
    required this.petFname,
    required this.petCategory,
    required this.petLostnfound,
    required this.petDescription,
    required this.petImage,
    required this.petPhone,
  });

  factory PetModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return PetModel(
      petId: data['petId'], //doc.get("petId"),
      petTitle: data['petTitle'],
      petFname: data['petFname'],
      petCategory: data['petCategory'],
      petLostnfound: data['petLostnfound'],

      petDescription: data['petDescription'],
      petImage: data['petImage'],
      petPhone: data['petPhone'],
    );
  }
}
