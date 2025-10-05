// ignore_for_file: prefer_const_constructors

import 'package:ata_new_app/components/cards/database_card.dart';
import 'package:ata_new_app/components/my_list_header.dart';
import 'package:ata_new_app/components/my_slide_show.dart';
import 'package:ata_new_app/models/category.dart';
import 'package:ata_new_app/models/product.dart';
import 'package:ata_new_app/pages/shops/product_detail_page.dart';
import 'package:ata_new_app/pages/shops/products_list_page.dart';
import 'package:ata_new_app/services/category_service.dart';
import 'package:ata_new_app/services/product_service.dart';
import 'package:ata_new_app/services/slide_service.dart';
import 'package:flutter/material.dart';
import 'package:ata_new_app/components/cards/product_card.dart';
import 'package:easy_localization/easy_localization.dart';

class ShopsPage extends StatefulWidget {
  const ShopsPage({super.key});

  @override
  State<ShopsPage> createState() => _ShopsPageState();
}

class _ShopsPageState extends State<ShopsPage> {
  List<Product> products = [];
  bool isLoadingProducts = true;
  bool isLoadingProductsError = false;
  bool hasMoreProducts = true;
  bool isLoadingMore = false;
  int currentPage = 1;

  List<String> slides = [];
  bool isLoadingSlide = true;
  bool isLoadingSlideError = false;

  List<Category> categories = [];
  bool isLoadingCategories = true;
  bool isLoadingCategoriesError = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getSlides();
    getCategories();
    getProducts();
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

  Future<void> getSlides() async {
    try {
      // Fetch products outside of setState
      final fetchedSlides = await SlideService.fetchSlides(position: 'Shop');
      // Update the state
      setState(() {
        slides = fetchedSlides;
        isLoadingSlide = false;
      });
    } catch (error) {
      // Handle any errors that occur during the fetch
      setState(() {
        isLoadingSlide = false;
        isLoadingSlideError = true;
      });
      // You can also show an error message to the user
      print('Failed to load Slide: $error');
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

  Future<void> getProducts() async {
    try {
      final fetchedProducts = await ProductService.fetchProducts(page: 1);
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
          content: Text('Failed to load Data'.tr()),
        ),
      );
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
      final fetchedProducts =
          await ProductService.fetchProducts(page: currentPage);

      setState(() {
        products.addAll(fetchedProducts);
        isLoadingMore = false;
      });

      if (fetchedProducts.isEmpty) {
        hasMoreProducts = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No more Data!'.tr()),
          ),
        );
      }
    } catch (error) {
      setState(() {
        isLoadingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load Data'.tr()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Shops'.tr(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              final route = MaterialPageRoute(
                builder: (context) => ProductsListPage(),
              );
              Navigator.push(context, route);
            },
            icon: Icon(
              Icons.search_outlined,
              size: 32,
            ),
          ),
        ],
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
                          SliverToBoxAdapter(
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: MySlideShow(imageUrls: slides),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 12,
                                ),
                                MyListHeader(
                                  title: 'Categories'.tr(),
                                  isShowSeeMore: false,
                                ),
                                SizedBox(
                                  height:
                                      130, // Set a fixed height for horizontal ListView
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: categories.length,
                                    itemBuilder: (context, index) {
                                      final category = categories[index];
                                      return DatabaseCard(
                                        image: category.imageUrl,
                                        title: context.locale.languageCode ==
                                                'km'
                                            ? category.nameKh
                                            : category.name,
                                        onTap: () {
                                          final route = MaterialPageRoute(
                                              builder: (context) =>
                                                  ProductsListPage(
                                                    categoryId: category.id,
                                                  ));
                                          Navigator.push(context, route);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 12,
                                ),
                                MyListHeader(
                                  title: 'New Arrivals'.tr(),
                                  isShowSeeMore: false,
                                ),
                              ],
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.all(0.0),
                            sliver: SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, // Number of columns
                                childAspectRatio: 0.72,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                childCount: products.length,
                                (context, index) {
                                  final product = products[index];
                                  return ProductCard(
                                      width: 200,
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
              : Center(
                  child: Text('No Data'.tr()),
                ),
    );
  }
}
