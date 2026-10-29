import 'package:flutter/material.dart';

class CurrentHouseholdProvider extends ChangeNotifier {
  String? householdId;

  String? householdName;

  bool initialized = false;

  void setHousehold({required String id, required String name}) {
    householdId = id;
    householdName = name;
    initialized = true;

    notifyListeners();
  }
}
