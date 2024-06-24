import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/pet_model.dart';

class PetProvider with ChangeNotifier {
  final List<PetModel> _pets = [];
  List<PetModel> get getPets {
    return _pets;
  }

  PetModel? findByProdId(String petId) {
    if (_pets.where((element) => element.petId == petId).isEmpty) {
      return null;
    }
    return _pets.firstWhere((element) => element.petId == petId);
  }

  List<PetModel> findByCategory({required String ctgName}) {
    List<PetModel> ctgList = _pets
        .where((element) =>
            element.petCategory.toLowerCase().contains(ctgName.toLowerCase()))
        .toList();
    return ctgList;
  }

  List<PetModel> searchQuery(
      {required String searchText, required List<PetModel> passedList}) {
    List<PetModel> searchList = passedList
        .where((element) =>
            element.petTitle.toLowerCase().contains(searchText.toLowerCase()))
        .toList();
    return searchList;
  }

  final petDB = FirebaseFirestore.instance.collection("pets");
  Future<List<PetModel>> fetchPets() async {
    try {
      await petDB.get().then((petsSnapshot) {
        _pets.clear();
        for (var element in petsSnapshot.docs) {
          _pets.insert(0, PetModel.fromFirestore(element));
        }
      });
      notifyListeners();
      return _pets;
    } catch (error) {
      rethrow;
    }
  }

  Stream<List<PetModel>> fetchPetsStream() {
    try {
      return petDB.snapshots().map((snapshot) {
        _pets.clear();
        // _pets = [];
        for (var element in snapshot.docs) {
          _pets.insert(0, PetModel.fromFirestore(element));
        }
        return _pets;
      });
    } catch (e) {
      rethrow;
    }
  }
}
