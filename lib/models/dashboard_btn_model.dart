import 'package:flutter/material.dart';
import 'package:petfinder_admin/screens/edit_upload_pet_form.dart';
import 'package:petfinder_admin/screens/search_screen.dart';

import '../services/assets_manager.dart';

class DashboardButtonsModel {
  final String text, imagePath;
  final Function onPressed;

  DashboardButtonsModel({
    required this.text,
    required this.imagePath,
    required this.onPressed,
  });

  static List<DashboardButtonsModel> dashboardBtnList(BuildContext context) => [
        DashboardButtonsModel(
          text: "Add Lost Pet",
          imagePath: AssetsManager.addpaw,
          onPressed: () {
            Navigator.pushNamed(
              context,
              EditOrUploadPetScreen.routeName,
            );
          },
        ),
        DashboardButtonsModel(
          text: "All Lost Pets",
          imagePath: AssetsManager.cloud,
          onPressed: () {
            Navigator.pushNamed(
              context,
              SearchScreen.routeName,
            );
          },
        ),
      ];
}
