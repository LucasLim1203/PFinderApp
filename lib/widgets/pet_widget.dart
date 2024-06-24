import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:petfinder_admin/screens/edit_upload_pet_form.dart';
import '../providers/pet_provider.dart';
import 'subtitle_text.dart';
import 'title_text.dart';

class PetWidget extends StatefulWidget {
  const PetWidget({
    super.key,
    required this.petId,
  });

  final String petId;
  @override
  State<PetWidget> createState() => _PetWidgetState();
}

class _PetWidgetState extends State<PetWidget> {
  @override
  Widget build(BuildContext context) {
    // final petModelProvider = Provider.of<PetModel>(context);
    final petProvider = Provider.of<PetProvider>(context);
    final getCurrPet = petProvider.findByProdId(widget.petId);
    Size size = MediaQuery.of(context).size;
    return getCurrPet == null
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.all(3.0),
            child: GestureDetector(
              onTap: () async {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditOrUploadPetScreen(
                              petModel: getCurrPet,
                            )));
              },
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30.0),
                    child: FancyShimmerImage(
                      imageUrl: getCurrPet.petImage,
                      width: double.infinity,
                      height: size.height * 0.22,
                    ),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  TitlesTextWidget(
                    label: getCurrPet.petTitle,
                    maxLines: 2,
                    fontSize: 18,
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: SubtitleTextWidget(
                        label: "${getCurrPet.petLostnfound}"),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          );
  }
}
