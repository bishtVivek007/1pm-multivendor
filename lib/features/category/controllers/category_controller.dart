import 'dart:convert';

import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/features/category/domain/models/category_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:sixam_mart/features/category/domain/services/category_service_interface.dart';

class CategoryController extends GetxController implements GetxService {
  final CategoryServiceInterface categoryServiceInterface;
  CategoryController({required this.categoryServiceInterface});

  List<CategoryModel>? _categoryList;
  List<CategoryModel>? get categoryList => _categoryList;

  List<CategoryModel>? _mainCategoryList;
  List<CategoryModel>? get mainCategoryList => _mainCategoryList;

  List<CategoryModel>? _subCategoryList;
  List<CategoryModel>? get subCategoryList => _subCategoryList;

  List<Item>? _categoryItemList;
  List<Item>? get categoryItemList => _categoryItemList;

  List<Store>? _categoryStoreList;
  List<Store>? get categoryStoreList => _categoryStoreList;

  List<Item>? _searchItemList = [];
  List<Item>? get searchItemList => _searchItemList;

  List<Store>? _searchStoreList = [];
  List<Store>? get searchStoreList => _searchStoreList;

  List<bool>? _interestSelectedList;
  List<bool>? get interestSelectedList => _interestSelectedList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int? _pageSize;
  int? get pageSize => _pageSize;

  int? _restPageSize;
  int? get restPageSize => _restPageSize;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  int _subCategoryIndex = 0;
  int get subCategoryIndex => _subCategoryIndex;

  String _type = 'all';
  String get type => _type;

  bool _isStore = false;
  bool get isStore => _isStore;

  String? _searchText = '';
  String? get searchText => _searchText;

  int _offset = 1;
  int get offset => _offset;

  int _selectedMainCategoryId = -1;
  int get selectedMainCategoryId => _selectedMainCategoryId;

  void setSelectedMainCategory(int id) {
    _selectedMainCategoryId = id;
    update(); // Refresh the UI
  }

  List<CategoryModel> getSubCategoriesByMainId(int mainId) {
    return _categoryList!.where((cat) => cat.parentId == mainId).toList();
  }

  void clearCategoryList() {
    _categoryList = null;
  }

  Future<void> getCategoryList(bool reload, {bool allCategory = false, DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    if(_categoryList == null || reload || fromRecall) {
      if(reload) {
        _categoryList = null;
      }
      List<CategoryModel>? categoryList;
      if(dataSource == DataSourceEnum.local) {
        categoryList = await categoryServiceInterface.getCategoryList(allCategory, source: DataSourceEnum.local);
        _prepareCategoryList(categoryList);
        getCategoryList(false, fromRecall: true, allCategory: allCategory, dataSource: DataSourceEnum.client);
      } else {
        categoryList = await categoryServiceInterface.getCategoryList(allCategory, source: DataSourceEnum.client);
        _prepareCategoryList(categoryList);
      }

    }
  }

  _prepareCategoryList(List<CategoryModel>? categoryList) {
    if (categoryList != null) {
      _categoryList = [];
      _interestSelectedList = [];
      _categoryList!.addAll(categoryList);
      for(int i = 0; i < _categoryList!.length; i++) {
        _interestSelectedList!.add(false);
      }
    }
    update();
  }

  Future<void> getSubCategoryList(String? categoryID) async {
    _subCategoryIndex = 0;
    _subCategoryList = null;
    _categoryItemList = null;
    List<CategoryModel>? subCategoryList = await categoryServiceInterface.getSubCategoryList(categoryID);
    if (subCategoryList != null) {
      _subCategoryList= [];
      _subCategoryList!.add(CategoryModel(id: int.parse(categoryID!), name: 'all'.tr));
      _subCategoryList!.addAll(subCategoryList);
      getCategoryItemList(categoryID, 1, 'all', false);
    }
  }

  Future<void> getMainCategoryList() async {
    _mainCategoryList = [];
    _categoryList = [];
    _isLoading = true;
    update(); // Notify UI that loading has started

    try {
      var response = await http.get(
        Uri.parse('https://mandiatdoor.in/admin/api/v1/categories/head-categories'),
        headers: {
          'Content-Type': 'application/json',
          'moduleId': '1',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        for (var mainCategory in data) {
          // Store main category
          _mainCategoryList!.add(CategoryModel(
            id: mainCategory['id'],
            name: mainCategory['name'],
            imageFullUrl: mainCategory['image_full_url']
          ));

          // Fetch and store only relevant subcategories
          List<CategoryModel> filteredCategories = (mainCategory['categories'] as List<dynamic>)
              .map((subCategory) => CategoryModel(
            id: subCategory['id'],
            parentId: mainCategory['id'],
            name: subCategory['name'],
            imageFullUrl: subCategory['image_full_url'],
          )).toList();

          _categoryList!.addAll(filteredCategories);
          update();
          print('✅ Main Category: ${mainCategory['name']}');
          for (var category in filteredCategories) {
            print('   → ID: ${category.id}, Name: ${category.name}, Image: ${category.imageFullUrl}');
          }
          print('--------------------');
        }
      } else {
        print("❌ Failed to load categories: ${response.statusCode}");
      }
    } catch (e) {
      print("⚠️ Error fetching categories: $e");
    }

    _isLoading = false;
    update(); // Notify UI that loading is complete
  }


  // void getSubCategoryList(String? categoryID) async {
  //   _subCategoryIndex = 0;
  //   _subCategoryList = null;
  //   _categoryItemList = null;
  //   List<CategoryModel>? subCategoryList = await categoryServiceInterface.getSubCategoryList(categoryID);
  //   if (subCategoryList != null) {
  //     _subCategoryList= [];
  //     _subCategoryList!.add(CategoryModel(id: int.parse(categoryID!), name: 'all'.tr));
  //     _subCategoryList!.addAll(subCategoryList);
  //     getCategoryItemList(categoryID, 1, 'all', false);
  //   }
  // }

  void setSubCategoryIndex(int index, String? categoryID) {
    _subCategoryIndex = index;
    if(_isStore) {
      getCategoryStoreList(_subCategoryIndex == 0 ? categoryID : _subCategoryList![index].id.toString(), 1, _type, true);
    }else {
      getCategoryItemList(_subCategoryIndex == 0 ? categoryID : _subCategoryList![index].id.toString(), 1, _type, true);
    }
  }

  void getCategoryItemList(String? categoryID, int offset, String type, bool notify) async {
    _offset = offset;
    if(offset == 1) {
      if(_type == type) {
        _isSearching = false;
      }
      _type = type;
      if(notify) {
        update();
      }
      _categoryItemList = null;
    }
    ItemModel? categoryItem = await categoryServiceInterface.getCategoryItemList(categoryID, offset, type);
    if (categoryItem != null) {
      if (offset == 1) {
        _categoryItemList = [];
      }
      _categoryItemList!.addAll(categoryItem.items!);
      _pageSize = categoryItem.totalSize;
      _isLoading = false;
    }
    update();
  }

  void getCategoryStoreList(String? categoryID, int offset, String type, bool notify) async {
    _offset = offset;
    if(offset == 1) {
      if(_type == type) {
        _isSearching = false;
      }
      _type = type;
      if(notify) {
        update();
      }
      _categoryStoreList = null;
    }
    StoreModel? categoryStore = await categoryServiceInterface.getCategoryStoreList(categoryID, offset, type);
    if (categoryStore != null) {
      if (offset == 1) {
        _categoryStoreList = [];
      }
      _categoryStoreList!.addAll(categoryStore.stores!);
      _restPageSize = categoryStore.totalSize;
      _isLoading = false;
    }
    update();
  }

  void searchData(String? query, String? categoryID, String type) async {
    if((_isStore && query!.isNotEmpty) || (!_isStore && query!.isNotEmpty /*&& query != _itemResultText*/)) {
      _searchText = query;
      _type = type;
      _isStore ? _searchStoreList = null : _searchItemList = null;
      _isSearching = true;
      update();

      Response response = await categoryServiceInterface.getSearchData(query, categoryID, _isStore, type);
      if (response.statusCode == 200) {
        if (query.isEmpty) {
          _isStore ? _searchStoreList = [] : _searchItemList = [];
        } else {
          if (_isStore) {
            _searchStoreList = [];
            _searchStoreList!.addAll(StoreModel.fromJson(response.body).stores!);
            update();
          } else {
            _searchItemList = [];
            _searchItemList!.addAll(ItemModel.fromJson(response.body).items!);
          }
        }
      }
      update();
    }
  }

  void toggleSearch() {
    _isSearching = !_isSearching;
    _searchItemList = [];
    if(_categoryItemList != null) {
      _searchItemList!.addAll(_categoryItemList!);
    }
    update();
  }

  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  Future<bool> saveInterest(List<int?> interests) async {
    _isLoading = true;
    update();
    bool isSuccess = await categoryServiceInterface.saveUserInterests(interests);
    _isLoading = false;
    update();
    return isSuccess;
  }

  void addInterestSelection(int index) {
    _interestSelectedList![index] = !_interestSelectedList![index];
    update();
  }

  void setRestaurant(bool isRestaurant) {
    _isStore = isRestaurant;
    update();
  }

}
