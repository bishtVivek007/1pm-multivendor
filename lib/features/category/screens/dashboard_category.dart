import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

import '../../../helper/route_helper.dart';
import '../domain/models/category_model.dart';

class DashboardCategoryScreen extends StatefulWidget {
  final bool isDashboard;
  const DashboardCategoryScreen({super.key, required this.isDashboard});

  @override
  _DashboardCategoryScreenState createState() => _DashboardCategoryScreenState();
}

class _DashboardCategoryScreenState extends State<DashboardCategoryScreen> {
  final CategoryController catController = Get.find<CategoryController>();
  final Map<int, List> subCategoryMap = {}; // Stores subcategories for each category
  bool isLoading = true; // Track overall loading state
  final bool _isDataLoaded = true;

  @override
  void initState() {
    super.initState();
    fetchMainCategories();
  }

  Future<void> fetchMainCategories() async {
    await catController.getMainCategoryList();
    // catController.update(); // Ensure UI updates after fetching main categories
  }

  Future<void> fetchSubCategories(String categoryId) async {
    await catController.getSubCategoryList(categoryId);

    setState(() {
      subCategoryMap[int.parse(categoryId)] = List.from(catController.subCategoryList ?? []);
    });

    // catController.update();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: widget.isDashboard ?
        AppBar(
        title: Text('All Categories', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 25,),
            onPressed: () {
              Get.toNamed(RouteHelper.getSearchRoute());
              // print('Search button tapped!');
            },
          ),
        ],
        centerTitle: true,
      ) : null,
      body: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: _isDataLoaded ? SingleChildScrollView(
          child: Column(
            children: [
              // Display Main Categories
              GetBuilder<CategoryController>(
                builder: (catController) {
                  if (catController.isLoading || catController.mainCategoryList == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  var mainCategoriesRaw = catController.mainCategoryList!;
                  var uniqueMainCategoryMap = <String, CategoryModel>{};
                  for (var mainCat in mainCategoriesRaw) {
                    uniqueMainCategoryMap[mainCat.name!] = mainCat; // latest occurrence stays
                  }
                  var uniqueMainCategories = uniqueMainCategoryMap.values.toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: uniqueMainCategories.length,
                        itemBuilder: (context, index) {
                          var mainCategory = uniqueMainCategories[index];

                          var subCategoriesRaw = catController.categoryList!
                              .where((category) => category.parentId == mainCategory.id)
                              .toList();

                          // Remove duplicate subcategory names
                          var subCategories = <String, CategoryModel>{};
                          for (var subCat in subCategoriesRaw) {
                            subCategories[subCat.name!] = subCat;  // If duplicate name, only latest will remain
                          }
                          var uniqueSubCategories = subCategories.values.toList();


                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Main Category Card
                              ListTile(
                                title: Text(mainCategory.name!, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                              ),
          
                              // Grid of subcategories under this main category
                              if (uniqueSubCategories.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  child: GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4, // Adjust grid count as needed
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: .5, // Adjust aspect ratio for better fit
                                    ),
                                    itemCount: uniqueSubCategories.length,
                                    itemBuilder: (context, subIndex) {
                                      var subCategory = uniqueSubCategories[subIndex];
          
                                      return Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () => Get.toNamed(RouteHelper.getCategoryItemRoute(
                                              subCategory.id!, subCategory.name!,
                                            )),
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.all(2.0),
                                                    child: Image.network(
                                                      subCategory.imageFullUrl!,
                                                      height: screenWidth * 0.2,
                                                      width: screenWidth * 0.2,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) => Icon(
                                                        Icons.broken_image,
                                                        color: Theme.of(context).disabledColor,
                                                        size: 40,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            subCategory.name!,
                                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              const SizedBox(height: 10),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 50),
                    ],
                  );
                },
              ),
            ],
          ),
        ) : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
