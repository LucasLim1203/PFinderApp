// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petfinder_admin/consts/app_constants.dart';
import 'package:petfinder_admin/models/pet_model.dart';
import 'package:petfinder_admin/services/my_app_method.dart';

import 'package:uuid/uuid.dart';

import '../consts/my_validators.dart';
import '../widgets/title_text.dart';
import 'loading_manager.dart';

class EditOrUploadPetScreen extends StatefulWidget {
  static const routeName = '/EditOrUploadPetScreen';

  const EditOrUploadPetScreen({
    super.key,
    this.petModel,
  });
  final PetModel? petModel;
  @override
  State<EditOrUploadPetScreen> createState() => _EditOrUploadPetScreenState();
}

class _EditOrUploadPetScreenState extends State<EditOrUploadPetScreen> {
  final _formKey = GlobalKey<FormState>();
  XFile? _pickedImage;
  bool isEditing = false;
  String? petNetworkImage;

  late TextEditingController _titleController,
      _fnameController,
      _descriptionController,
      _phoneController;
  String? _categoryValue;
  String? _lostnfoundValue;

  bool _isLoading = false;
  String? petImageUrl;
  @override
  void initState() {
    if (widget.petModel != null) {
      isEditing = true;
      petNetworkImage = widget.petModel!.petImage;
      _categoryValue = widget.petModel!.petCategory;
      _lostnfoundValue = widget.petModel!.petLostnfound;
    }
    _titleController = TextEditingController(text: widget.petModel?.petTitle);
    _fnameController = TextEditingController(text: widget.petModel?.petFname);
    _descriptionController =
        TextEditingController(text: widget.petModel?.petDescription);
    _phoneController = TextEditingController(text: widget.petModel?.petPhone);

    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _fnameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void clearForm() {
    _titleController.clear();
    _fnameController.clear();
    _descriptionController.clear();
    _phoneController.clear();
    removePickedImage();
  }

  void removePickedImage() {
    setState(() {
      _pickedImage = null;
      petNetworkImage = null;
    });
  }

  Future<void> _uploadPet() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (_pickedImage == null) {
      MyAppMethods.showErrorORWarningDialog(
        context: context,
        subtitle: "Make sure to pick up an image",
        fct: () {},
      );
      return;
    }
    if (_lostnfoundValue == null) {
      MyAppMethods.showErrorORWarningDialog(
        context: context,
        subtitle: "Lost/Found is empty",
        fct: () {},
      );

      return;
    }
    if (_categoryValue == null) {
      MyAppMethods.showErrorORWarningDialog(
        context: context,
        subtitle: "Category is empty",
        fct: () {},
      );

      return;
    }
    if (isValid) {
      _formKey.currentState!.save();
      try {
        setState(() {
          _isLoading = true;
        });
        final petID = const Uuid().v4();
        if (_pickedImage != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child("petsImages")
              .child('$petID.jpg');
          await ref.putFile(File(_pickedImage!.path));
          petImageUrl = await ref.getDownloadURL();
        }

        await FirebaseFirestore.instance.collection("pets").doc(petID).set({
          'petId': petID,
          'petTitle': _titleController.text,
          'petFname': _fnameController.text,
          'petImage': petImageUrl,
          'petCategory': _categoryValue,
          'petLostnfound': _lostnfoundValue,
          'petDescription': _descriptionController.text,
          'petPhone': _phoneController.text,
          'createdAt': Timestamp.now(),
        });
        Fluttertoast.showToast(
          msg: "Pet has been added",
          toastLength: Toast.LENGTH_SHORT,
          textColor: Colors.white,
        );
        if (!mounted) return;
        await MyAppMethods.showErrorORWarningDialog(
          isError: false,
          context: context,
          subtitle: "Clear form?",
          fct: () {
            clearForm();
          },
        );
      } on FirebaseException catch (error) {
        await MyAppMethods.showErrorORWarningDialog(
          context: context,
          subtitle: "An error has been occured ${error.message}",
          fct: () {},
        );
      } catch (error) {
        await MyAppMethods.showErrorORWarningDialog(
          context: context,
          subtitle: "An error has been occured $error",
          fct: () {},
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _editPet() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (_pickedImage == null && petNetworkImage == null) {
      MyAppMethods.showErrorORWarningDialog(
        context: context,
        subtitle: "Please pick up an image",
        fct: () {},
      );
      return;
    }
    if (_lostnfoundValue == null) {
      MyAppMethods.showErrorORWarningDialog(
        context: context,
        subtitle: "Lost/Found/Adopt is empty",
        fct: () {},
      );

      return;
    }
    if (_categoryValue == null) {
      MyAppMethods.showErrorORWarningDialog(
        context: context,
        subtitle: "Category is empty",
        fct: () {},
      );

      return;
    }
    if (isValid) {
      _formKey.currentState!.save();
      try {
        setState(() {
          _isLoading = true;
        });
        if (_pickedImage != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child("petsImages")
              .child('${widget.petModel!.petId}.jpg');
          await ref.putFile(File(_pickedImage!.path));
          petImageUrl = await ref.getDownloadURL();
        }

        await FirebaseFirestore.instance
            .collection("pets")
            .doc(widget.petModel!.petId)
            .update({
          'petId': widget.petModel!.petId,
          'petTitle': _titleController.text,
          'petFname': _fnameController.text,
          'petImage': petImageUrl ?? petNetworkImage,
          'petCategory': _categoryValue,
          'lostnfoundCategory': _lostnfoundValue,
          'petDescription': _descriptionController.text,
          'petPhone': _phoneController.text,
        });
        Fluttertoast.showToast(
          msg: "Pet has been edited",
          toastLength: Toast.LENGTH_SHORT,
          textColor: Colors.white,
        );
      } on FirebaseException catch (error) {
        await MyAppMethods.showErrorORWarningDialog(
          context: context,
          subtitle: "An error has been occured ${error.message}",
          fct: () {},
        );
      } catch (error) {
        await MyAppMethods.showErrorORWarningDialog(
          context: context,
          subtitle: "An error has been occured $error",
          fct: () {},
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> localImagePicker() async {
    final ImagePicker picker = ImagePicker();
    await MyAppMethods.imagePickerDialog(
      context: context,
      cameraFCT: () async {
        _pickedImage = await picker.pickImage(source: ImageSource.camera);
        setState(() {
          petNetworkImage = null;
        });
      },
      galleryFCT: () async {
        _pickedImage = await picker.pickImage(source: ImageSource.gallery);
        setState(() {
          petNetworkImage = null;
        });
      },
      removeFCT: () {
        setState(() {
          _pickedImage = null;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return LoadingManager(
      isLoading: _isLoading,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          bottomSheet: SizedBox(
            height: kBottomNavigationBarHeight + 10,
            child: Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.upload),
                    label: Text(
                      isEditing ? "Edit Pet" : "Upload Pet",
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    onPressed: () {
                      if (isEditing) {
                        _editPet();
                      } else {
                        _uploadPet();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          appBar: AppBar(
            centerTitle: true,
            title: const TitlesTextWidget(
              label: "Upload a new pet",
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  if (isEditing && petNetworkImage != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        petNetworkImage!,
                        height: size.width * 0.5,
                        alignment: Alignment.center,
                      ),
                    ),
                  ] else if (_pickedImage == null) ...[
                    SizedBox(
                      width: size.width * 0.4 + 10,
                      height: size.width * 0.4,
                      child: DottedBorder(
                          color: Colors.blue,
                          radius: const Radius.circular(12),
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.image_outlined,
                                  size: 80,
                                  color: Colors.blue,
                                ),
                                TextButton(
                                  onPressed: () {
                                    localImagePicker();
                                  },
                                  child: const Text("Pick Pet image"),
                                ),
                              ],
                            ),
                          )),
                    )
                  ] else ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(
                          _pickedImage!.path,
                        ),
                        // width: size.width * 0.7,
                        height: size.width * 0.5,
                        alignment: Alignment.center,
                      ),
                    ),
                  ],
                  if (_pickedImage != null || petNetworkImage != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            localImagePicker();
                          },
                          child: const Text("Pick another image"),
                        ),
                        TextButton(
                          onPressed: () {
                            removePickedImage();
                          },
                          child: const Text(
                            "Remove image",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    )
                  ],
                  const SizedBox(
                    height: 25,
                  ),
                  DropdownButton<String>(
                    hint: Text(_lostnfoundValue ?? "Select Type"),
                    value: _lostnfoundValue,
                    items: AppConstants.lostnfoundDropDownList,
                    onChanged: (String? value) {
                      setState(() {
                        _lostnfoundValue = value;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  DropdownButton<String>(
                    hint: Text(_categoryValue ?? "Select Category"),
                    value: _categoryValue,
                    items: AppConstants.categoriesDropDownList,
                    onChanged: (String? value) {
                      setState(() {
                        _categoryValue = value;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _titleController,
                            key: const ValueKey('Title'),
                            maxLength: 80,
                            minLines: 1,
                            maxLines: 2,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            decoration: const InputDecoration(
                              hintText:
                                  'Pet Title (Gender, Colour, Location,...)',
                            ),
                            validator: (value) {
                              return MyValidators.uploadProdTexts(
                                value: value,
                                toBeReturnedString:
                                    "Please enter a valid title",
                              );
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  controller: _fnameController,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  decoration: const InputDecoration(
                                    hintText: 'Username',
                                  ),
                                  validator: (value) {
                                    return MyValidators.uploadProdTexts(
                                      value: value,
                                      toBeReturnedString:
                                          "Founder Name is missed",
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  controller: _phoneController,
                                  keyboardType: TextInputType.number,
                                  key: const ValueKey('Phone'),
                                  decoration: const InputDecoration(
                                    hintText: 'Phone Number',
                                  ),
                                  validator: (value) {
                                    return MyValidators.uploadProdTexts(
                                      value: value,
                                      toBeReturnedString: "Phone is missed",
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            key: const ValueKey('Description'),
                            controller: _descriptionController,
                            minLines: 5,
                            maxLines: 8,
                            maxLength: 1000,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              hintText: 'Pet description',
                            ),
                            validator: (value) {
                              return MyValidators.uploadProdTexts(
                                value: value,
                                toBeReturnedString: "Description is missed",
                              );
                            },
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: kBottomNavigationBarHeight + 10,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
