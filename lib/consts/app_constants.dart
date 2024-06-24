import 'package:flutter/material.dart';

class AppConstants {
  static List<String> categoriesList = [
    'Dogs',
    'Cats',
    'Others',
  ];
  static List<String> lostnfoundList = [
    'Found',
    'Lost',
    'Adopt',
  ];

  static List<DropdownMenuItem<String>>? get categoriesDropDownList {
    List<DropdownMenuItem<String>>? menuItems =
        List<DropdownMenuItem<String>>.generate(
      categoriesList.length,
      (index) => DropdownMenuItem(
        value: categoriesList[index],
        child: Text(
          categoriesList[index],
        ),
      ),
    );
    return menuItems;
  }

  static List<DropdownMenuItem<String>>? get lostnfoundDropDownList {
    List<DropdownMenuItem<String>>? menuItems =
        List<DropdownMenuItem<String>>.generate(
      lostnfoundList.length,
      (index) => DropdownMenuItem(
        value: lostnfoundList[index],
        child: Text(
          lostnfoundList[index],
        ),
      ),
    );
    return menuItems;
  }
}
