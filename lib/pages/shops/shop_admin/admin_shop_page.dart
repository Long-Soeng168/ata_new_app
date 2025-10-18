// ignore_for_file: prefer_const_constructors

import 'package:ata_new_app/components/cards/detail_list_card.dart';
import 'package:ata_new_app/components/cards/product_card.dart';
import 'package:ata_new_app/components/cards/shop_tile_card.dart';
import 'package:ata_new_app/components/my_slide_show.dart';
import 'package:ata_new_app/components/my_tab_button.dart';
import 'package:ata_new_app/models/product.dart';
import 'package:ata_new_app/models/shop.dart';
import 'package:ata_new_app/pages/app_info/web_view_page.dart';
import 'package:ata_new_app/pages/main_page.dart';
import 'package:ata_new_app/pages/shops/shop_admin/admin_product_detail_page.dart';
import 'package:ata_new_app/pages/shops/shop_admin/product_create_page.dart';
import 'package:ata_new_app/pages/shops/shop_admin/shop_edit_page.dart';
import 'package:ata_new_app/services/product_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AdminShopPage extends StatefulWidget {
  const AdminShopPage({super.key, required this.shop});
  final Shop shop;
  @override
  State<AdminShopPage> createState() => _AdminShopPageState();
}

class _AdminShopPageState extends State<AdminShopPage> {
  int _selectedTabIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    getProducts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore) {
        loadMoreProducts();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkShopStatus();
    });
  }

  void _checkShopStatus() {
    final status = widget.shop.status.toLowerCase();

    if (status == 'pending' || status == 'suspended' || status == 'rejected') {
      IconData icon;
      Color iconColor;
      String message;

      switch (status) {
        case 'pending':
          icon = Icons.hourglass_bottom;
          iconColor = Colors.amber;
          message =
              "Your shop is pending approval. Please wait for verification.".tr();
          break;
        case 'suspended':
          icon = Icons.pause_circle_filled;
          iconColor = Colors.orange;
          message =
              "Your shop has been suspended. Contact support for details.".tr();
          break;
        case 'rejected':
          icon = Icons.block;
          iconColor = Colors.red;
          message = "Your shop has been rejected. Contact us for further info.".tr();
          break;
        default:
          icon = Icons.info;
          iconColor = Colors.blueGrey;
          message = "Status: $status";
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(icon, color: iconColor, size: 28),
                SizedBox(width: 8),
                Text(
                  "Shop Status".tr(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message, style: TextStyle(fontSize: 16, height: 1.4)),
                SizedBox(height: 12),
                Text(
                  "${'Current Status'.tr()}: ${status[0].toUpperCase()}${status.substring(1)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            actionsPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            actions: [
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ShopEditPage(shop: widget.shop)),
                  );
                },
                icon: Icon(Icons.edit, size: 18),
                label: Text("Edit Shop".tr()),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
                onPressed: () {
                  final route = MaterialPageRoute(
                    builder: (context) => WebViewPage(
                      title: 'Contact Us'.tr(),
                      url: 'https://atech-auto.com/contact-us-webview',
                    ),
                  );
                  Navigator.push(context, route);
                },
                icon: Icon(Icons.support_agent, size: 18),
                label: Text("Contact Us".tr()),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MainPage()),
                  );
                },
                icon: const Icon(Icons.home, color: Colors.white, size: 18),
                label: Text(
                  "Back to Home".tr(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  List<Product> products = [];
  bool isLoadingProducts = true;
  bool isLoadingProductsError = false;
  bool hasMoreProducts = true;
  bool isLoadingMore = false;
  int currentPage = 1;

  final ScrollController _scrollController = ScrollController();

  Future<void> getProducts() async {
    try {
      final fetchedProducts =
          await ProductService.fetchProducts(page: 1, shopId: widget.shop.id);
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        foregroundColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Colors.transparent,
        title: Text(
          widget.shop.name,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ShopEditPage(
                          shop: widget.shop,
                        )),
              );
            },
            icon: Icon(
              Icons.edit,
              size: 32,
            ),
          ),
        ],
      ),
      floatingActionButton: widget.shop.status == 'approved'
          ? SizedBox(
              height: 70.0, // Custom height
              width: 70.0, // Custom width
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductCreatePage(
                        shop: widget.shop,
                      ),
                    ),
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100), // Fully rounded
                ),
                child: const Icon(
                  Icons.add,
                  size: 35,
                ),
              ),
            )
          : null,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========================= Start Slide Show =========================
            AspectRatio(
              aspectRatio: 16 / 9,
              child: MySlideShow(imageUrls: [
                widget.shop.bannerUrl,
              ]),
            ),
            // ========================= End Slide Show =========================
            ShopTileCard(
              imageUrl: widget.shop.logoUrl,
              address: widget.shop.address,
              name: widget.shop.name,
              phone: widget.shop.phone,
              isShowChevron: false,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                // Row(
                //   children: [
                //     SizedBox(
                //       width: 8,
                //     ),
                //     Row(
                //       children: [
                //         IconButton(
                //           onPressed: () {},
                //           icon: Icon(
                //             Icons.thumb_up_outlined,
                //             size: 24,
                //             color: Colors.grey,
                //           ),
                //         ),
                //         Text(
                //           '2139',
                //           maxLines: 1,
                //           overflow: TextOverflow.ellipsis,
                //           style: TextStyle(
                //             fontSize: 16,
                //             color: Colors.grey,
                //           ),
                //         ),
                //       ],
                //     ),
                //     Container(
                //       width: 1,
                //       height: 14,
                //       margin: EdgeInsets.only(left: 18, right: 8),
                //       color: Colors.grey,
                //     ),
                //     Row(
                //       children: [
                //         IconButton(
                //           onPressed: () {},
                //           icon: Icon(
                //             Icons.thumb_down_outlined,
                //             size: 24,
                //             color: Colors.grey,
                //           ),
                //         ),
                //         Text(
                //           '138',
                //           maxLines: 1,
                //           overflow: TextOverflow.ellipsis,
                //           style: TextStyle(
                //             fontSize: 16,
                //             color: Colors.grey,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ],
                // ),
              ],
            ),

            // ========================= Start Tab =========================
            Row(
              children: [
                MyTabButton(
                  title: 'Products'.tr(),
                  isSelected: _selectedTabIndex == 0,
                  onTap: () {
                    setState(() {
                      _selectedTabIndex = 0;
                    });
                  },
                ),
                MyTabButton(
                  title: 'About Shop'.tr(),
                  isSelected: _selectedTabIndex == 1,
                  onTap: () {
                    setState(() {
                      _selectedTabIndex = 1;
                    });
                  },
                ),
              ],
            ),
            // ========================= End Tab =========================

            // ========================= Start Product =========================
            if (_selectedTabIndex == 0)
              Column(
                children: [
                  isLoadingProducts
                      ? SizedBox(
                          width: double.infinity,
                          height: 100,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Visibility(
                          visible: products.isNotEmpty,
                          child: Column(
                            children: [
                              GridView.builder(
                                shrinkWrap:
                                    true, // Important: Let GridView take up only needed space
                                physics:
                                    NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, // Number of columns
                                  childAspectRatio:
                                      0.72, // Aspect ratio of the grid items
                                ),
                                itemCount: products
                                    .length, // Total number of filtered items
                                itemBuilder: (context, index) {
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
                                              AdminProductDetailPage(
                                            product: product,
                                            shop: widget.shop,
                                          ),
                                        );
                                        Navigator.push(context, route);
                                      });
                                }, // Use your PublicationCard widget
                              ),
                            ],
                          ),
                        ),
                  Visibility(
                    visible: isLoadingProductsError,
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Center(
                        child: Text('Error Loading Resources'.tr()),
                      ),
                    ),
                  ),
                ],
              ),
            // ========================= End Product =========================

            // ========================= Start Detail =========================
            if (_selectedTabIndex == 1)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.0),
                    Column(children: [
                      // Start Detail
                      DetailListCard(
                        keyword: 'Contact'.tr(),
                        value: widget.shop.phone,
                      ),
                      DetailListCard(
                        keyword: 'Address'.tr(),
                        value: widget.shop.address,
                      ),
                      // End Detail

                      ListTile(
                        contentPadding: EdgeInsets.all(2),
                        title: Text(
                          'Description'.tr(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(widget.shop.description),
                      ),
                    ])
                  ],
                ),
              ),
            // ========================= End Detail =========================
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
