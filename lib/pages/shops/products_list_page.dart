// ignore_for_file: prefer_const_constructors

import 'package:ata_new_app/components/buttons/my_elevated_button.dart';
import 'package:ata_new_app/components/my_filter_option.dart';
import 'package:ata_new_app/components/my_search.dart';
import 'package:ata_new_app/models/body_type.dart';
import 'package:ata_new_app/models/brand.dart';
import 'package:ata_new_app/models/brand_model.dart';
import 'package:ata_new_app/models/category.dart';
import 'package:ata_new_app/models/product.dart';
import 'package:ata_new_app/pages/shops/product_detail_page.dart';
import 'package:ata_new_app/services/body_type_service.dart';
import 'package:ata_new_app/services/brand_model_service.dart';
import 'package:ata_new_app/services/brand_service.dart';
import 'package:ata_new_app/services/category_service.dart';
import 'package:ata_new_app/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:ata_new_app/components/cards/product_card.dart';

class ProductsListPage extends StatefulWidget {
  const ProductsListPage({super.key, this.categoryId});
  final int? categoryId;
  @override
  State<ProductsListPage> createState() => _ProductsListPageState();
}

class _ProductsListPageState extends State<ProductsListPage> {
  List<Product> products = [];
  bool isLoadingProducts = true;
  bool isLoadingProductsError = false;
  bool hasMoreProducts = true;
  bool isLoadingMore = false;
  int currentPage = 1;

  List<Category> categories = [];
  bool isLoadingCategories = true;
  bool isLoadingCategoriesError = false;

  List<BodyType> bodyTypes = [];
  bool isLoadingBodyTypes = true;
  bool isLoadingBodyTypesError = false;

  List<Brand> brands = [];
  bool isLoadingBrands = true;
  bool isLoadingBrandsError = false;

  List<BrandModel> brandModels = [];
  bool isLoadingBrandModels = true;
  bool isLoadingBrandModelsError = false;

  String? search;
  int? selectedCategoryId;
  int? selectedBodyTypeId;
  int? selectedBrandId;
  int? selectedBrandModelId;

  final TextEditingController _searchController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.categoryId != null) {
      setState(() {
        selectedCategoryId = widget.categoryId;
      });
    }
    getProducts();
    getCategories();
    getBodyTypes();
    getBrands();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore) {
        loadMoreProducts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> getProducts() async {
    try {
      final fetchedProducts = await ProductService.fetchProducts(
        page: 1,
        search: search,
        categoryId: selectedCategoryId,
        bodyTypeId: selectedBodyTypeId,
        brandId: selectedBrandId,
        brandModelId: selectedBrandModelId,
      );
      setState(() {
        products = fetchedProducts;
        isLoadingProducts = false;
      });
    } catch (error) {
      setState(() {
        isLoadingProducts = false;
        isLoadingProductsError = true;
        isLoadingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load Data'),
        ),
      );
    }
  }

  Future<void> getCategories() async {
    try {
      // Fetch products outside of setState
      final fetchedCategories = await CategoryService.fetchCategories();
      // Update the state
      setState(() {
        categories = fetchedCategories;
        isLoadingCategories = false;
      });
    } catch (error) {
      // Handle any errors that occur during the fetch
      setState(() {
        isLoadingCategories = false;
        isLoadingCategoriesError = true;
      });
      // You can also show an error message to the user
      print('Failed to load Catogries: $error');
    }
  }

  Future<void> getBodyTypes() async {
    try {
      // Fetch products outside of setState
      final fetchedBodyTypes = await BodyTypeService.fetchBodyTypes();
      // Update the state
      setState(() {
        bodyTypes = fetchedBodyTypes;
        isLoadingBodyTypes = false;
      });
    } catch (error) {
      // Handle any errors that occur during the fetch
      setState(() {
        isLoadingBodyTypes = false;
        isLoadingBodyTypesError = true;
      });
      // You can also show an error message to the user
      print('Failed to load Body Types: $error');
    }
  }

  Future<void> getBrands() async {
    try {
      // Fetch products outside of setState
      final fetchedBrands = await BrandService.fetchBrands();
      // Update the state
      setState(() {
        brands = fetchedBrands;
        isLoadingBrands = false;
      });
    } catch (error) {
      // Handle any errors that occur during the fetch
      setState(() {
        isLoadingBrands = false;
        isLoadingBrandsError = true;
      });
      // You can also show an error message to the user
      print('Failed to load Brands: $error');
    }
  }

  Future<void> getBrandModels() async {
    try {
      // Fetch products outside of setState
      final fetchedBrandModels =
          await BrandModelService.fetchBrandModels(brandId: selectedBrandId);
      // Update the state
      setState(() {
        brandModels = fetchedBrandModels;
        isLoadingBrandModels = false;
      });
    } catch (error) {
      // Handle any errors that occur during the fetch
      setState(() {
        isLoadingBrandModels = false;
        isLoadingBrandModelsError = true;
      });
      // You can also show an error message to the user
      print('Failed to load BrandModels: $error');
    }
  }

  Future<void> loadMoreProducts() async {
    if (!hasMoreProducts || isLoadingMore) {
      return;
    }

    setState(() {
      isLoadingMore = true;
    });

    try {
      currentPage++;
      final fetchedProducts = await ProductService.fetchProducts(
          page: currentPage, search: search, categoryId: selectedCategoryId);

      setState(() {
        products.addAll(fetchedProducts);
        isLoadingMore = false;
      });

      if (fetchedProducts.isEmpty) {
        hasMoreProducts = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No more Data!'),
          ),
        );
      }
    } catch (error) {
      setState(() {
        isLoadingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load Data'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
        titleSpacing: 0, // Remove default title spacing
        title: Row(
          children: [
            // Search bar
            Expanded(
              child: MySearch(
                placeholder: 'Search...',
                searchController: _searchController,
                onSearchSubmit: () {
                  setState(() {
                    search = _searchController.text;
                    isLoadingProducts = true;
                    currentPage = 1;
                    hasMoreProducts = true;
                  });
                  getProducts(); // Refetch with search query
                },
              ),
            ),
            // Actions without any extra space
            if (isLoadingCategories || isLoadingBrands || isLoadingBodyTypes)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            if (!isLoadingCategories && !isLoadingBrands && !isLoadingBodyTypes)
              IconButton(
                onPressed: () {
                  filterModal(context);
                },
                icon: Icon(
                  Icons.filter_list,
                  size: 32,
                ),
              ),
          ],
        ),
      ),
      body: isLoadingProducts
          ? Center(
              child: CircularProgressIndicator(),
            )
          : products.isNotEmpty
              ? SafeArea(
                  child: Stack(
                    children: [
                      CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          if (!isLoadingBrandModels && brandModels.isNotEmpty)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: brandModelsFilterOption(),
                              ),
                            ),
                          SliverPadding(
                            padding: EdgeInsets.all(8.0),
                            sliver: SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, // Number of columns
                                childAspectRatio: 0.70,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                childCount: products.length,
                                (context, index) {
                                  final product = products[index];
                                  return ProductCard(
                                      // width: 200,
                                      id: product.id,
                                      title: product.name,
                                      price: product.price,
                                      imageUrl: product.imageUrl,
                                      onTap: () {
                                        final route = MaterialPageRoute(
                                          builder: (context) =>
                                              ProductDetailPage(
                                            product: product,
                                          ),
                                        );
                                        Navigator.push(context, route);
                                      });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (isLoadingMore)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              : SafeArea(
                  child: Stack(
                    children: [
                      CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          if (!isLoadingBrandModels && brandModels.isNotEmpty)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: brandModelsFilterOption(),
                              ),
                            ),
                          SliverToBoxAdapter(
                            child: Center(
                              child: Text('No Data...'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  MyFilterOption brandModelsFilterOption() {
    return MyFilterOption(
      title: 'Models',
      showImage: false,
      selectedItem: selectedBrandModelId,
      options: brandModels.map((item) {
        return {
          'id': item.id,
          'title': item.name,
          'image': item.imageUrl,
        };
      }).toList(),
      handleSelect: (selected) {
        // print(selected);
        setState(() {
          selectedBrandModelId = selected;
          isLoadingProducts = true;
        });
        getProducts();
      },
    );
  }

  Future<dynamic> filterModal(BuildContext context) {
    return showModalBottomSheet(
      showDragHandle: true,
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Example filter options
                MyFilterOption(
                  title: 'Categories',
                  selectedItem: selectedCategoryId,
                  options: categories.map((item) {
                    return {
                      'id': item.id,
                      'title': item.name,
                      'image': item.imageUrl,
                    };
                  }).toList(), // Don't forget to convert it to a List if necessary

                  handleSelect: (selected) {
                    // print(selected);
                    setState(() {
                      selectedCategoryId = selected;
                    });
                  },
                ),
                SizedBox(height: 16),
                MyFilterOption(
                  title: 'Brands',
                  selectedItem: selectedBrandId,
                  options: brands.map((item) {
                    return {
                      'id': item.id,
                      'title': item.name,
                      'image': item.imageUrl,
                    };
                  }).toList(), // Don't forget to convert it to a List if necessary

                  handleSelect: (selected) {
                    // print(selected);
                    setState(() {
                      selectedBrandId = selected;
                      selectedBrandModelId = null;
                    });
                  },
                ),
                SizedBox(height: 16),
                MyFilterOption(
                  title: 'Body Types',
                  selectedItem: selectedBodyTypeId,
                  options: bodyTypes.map((item) {
                    return {
                      'id': item.id,
                      'title': item.name,
                      'image': item.imageUrl,
                    };
                  }).toList(), // Don't forget to convert it to a List if necessary

                  handleSelect: (selected) {
                    // print(selected);
                    setState(() {
                      selectedBodyTypeId = selected;
                    });
                  },
                ),
                SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: MyElevatedButton(
                    onPressed: () {
                      setState(() {
                        isLoadingProducts = true;
                        currentPage = 1;
                        hasMoreProducts = true;
                      });
                      getProducts();
                      if (selectedBrandId != null) {
                        getBrandModels();
                      }
                      if(selectedBrandModelId == null) {
                        brandModels = [];
                      }
                      Navigator.pop(context); // Close the bottom sheet
                    },
                    title: 'Filter',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
