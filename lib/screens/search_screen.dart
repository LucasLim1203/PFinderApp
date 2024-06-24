import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pet_model.dart';
import '../providers/pet_provider.dart';
import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';

import '../widgets/pet_widget.dart';
import '../widgets/title_text.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/SearchScreen';
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController searchTextController;

  @override
  void initState() {
    searchTextController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  List<PetModel> petListSearch = [];
  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context);

    String? passedCategory =
        ModalRoute.of(context)!.settings.arguments as String?;

    final List<PetModel> petList = passedCategory == null
        ? petProvider.getPets
        : petProvider.findByCategory(ctgName: passedCategory);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          appBar: AppBar(
            title: TitlesTextWidget(label: passedCategory ?? "Search"),
          ),
          body: StreamBuilder<List<PetModel>>(
              stream: petProvider.fetchPetsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: TitlesTextWidget(
                      label: snapshot.error.toString(),
                    ),
                  );
                } else if (snapshot.data == null) {
                  return const Center(
                    child: TitlesTextWidget(
                      label: "No pet has been added",
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 15.0,
                      ),
                      TextField(
                        controller: searchTextController,
                        decoration: InputDecoration(
                          hintText: "Search",
                          filled: true,
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              // setState(() {
                              searchTextController.clear();
                              FocusScope.of(context).unfocus();
                              // });
                            },
                            child: const Icon(
                              Icons.clear,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          // setState(() {
                          //   petListSearch = petProvider.searchQuery(
                          //       searchText: searchTextController.text);
                          // });
                        },
                        onSubmitted: (value) {
                          setState(() {
                            petListSearch = petProvider.searchQuery(
                                searchText: searchTextController.text,
                                passedList: petList);
                          });
                        },
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      if (searchTextController.text.isNotEmpty &&
                          petListSearch.isEmpty) ...[
                        const Center(
                            child: TitlesTextWidget(
                          label: "No results found",
                          fontSize: 40,
                        ))
                      ],
                      Expanded(
                        child: DynamicHeightGridView(
                          itemCount: searchTextController.text.isNotEmpty
                              ? petListSearch.length
                              : petList.length,
                          builder: ((context, index) {
                            return PetWidget(
                              petId: searchTextController.text.isNotEmpty
                                  ? petListSearch[index].petId
                                  : petList[index].petId,
                            );
                          }),
                          crossAxisCount: 2,
                        ),
                      ),
                    ],
                  ),
                );
              })),
    );
  }
}
