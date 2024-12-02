// ignore_for_file: prefer_const_constructors

import 'package:ata_new_app/components/cards/detail_list_card.dart';
import 'package:ata_new_app/components/my_gallery.dart';
import 'package:ata_new_app/models/product.dart';
import 'package:ata_new_app/models/shop.dart';
import 'package:ata_new_app/pages/shops/shop_admin/admin_shop_page.dart';
import 'package:ata_new_app/pages/shops/shop_admin/product_edit_page.dart';
import 'package:ata_new_app/services/product_service.dart';
import 'package:ata_new_app/services/shop_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminProductDetailPage extends StatefulWidget {
  const AdminProductDetailPage(
      {super.key, required this.product, required this.shop});
  final Product product;
  final Shop shop;

  @override
  State<AdminProductDetailPage> createState() => _AdminProductDetailPageState();
}

class _AdminProductDetailPageState extends State<AdminProductDetailPage> {
  late List<String> imageUrls = [];

  late Product productDetail;
  bool isLoadingProductDetail = true;
  bool isLoadingProductDetailError = false;

  late Shop shopDetail;
  bool isLoadingShopDetail = true;
  bool isLoadingShopDetailError = false;

  @override
  void initState() {
    super.initState();
    imageUrls.add(widget.product.imageUrl);

    getResource();
  }

  void getResource() {
    getRelatedProducts();
    getProductDetail();
    getShopDetail();
  }

  List<Product> relatedProducts = [];
  bool isLoadingRelatedProducts = true;
  bool isLoadingRelatedProductsError = false;

  Future<void> getRelatedProducts() async {
    try {
      // Fetch relatedProducts outside of setState
      final fetchedRelatedProduct =
          await ProductService.fetchRelatedProducts(id: widget.product.id);
      // Update the state
      setState(() {
        relatedProducts = fetchedRelatedProduct;
        isLoadingRelatedProducts = false;
      });
    } catch (error) {
      // Handle any errors that occur during the fetch
      setState(() {
        isLoadingRelatedProducts = false;
        isLoadingRelatedProductsError = true;
      });
      // You can also show an error message to the user
      print('Failed to load related Products: $error');
    }
  }

  Future<void> getProductDetail() async {
    try {
      // Fetch relatedProducts outside of setState
      final fetchedProductDetail =
          await ProductService.fetchProductById(id: widget.product.id);
      // Update the state
      setState(() {
        productDetail = fetchedProductDetail;
        imageUrls.addAll(fetchedProductDetail.imagesUrls);
        isLoadingProductDetail = false;
      });
      // print(fetchedProductDetail.imagesUrls[0]);
    } catch (error) {
      // Handle any errors that occur during the fetch
      setState(() {
        isLoadingProductDetail = false;
        isLoadingProductDetailError = true;
      });
      // You can also show an error message to the user
      print('Failed to load Product Detail : $error');
    }
  }

  Future<void> getShopDetail() async {
    try {
      final fetchedShopDetail =
          await ShopService.fetchShopById(id: widget.product.shopId);
      setState(() {
        shopDetail = fetchedShopDetail;
        isLoadingShopDetail = false;
      });
    } catch (error) {
      setState(() {
        isLoadingShopDetail = false;
        isLoadingShopDetailError = true;
      });
      print('Failed to load Shop Detail : $error');
    }
  }

  void deleteProductHandler() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this product?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancel
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirm
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return; // User canceled the action.

    final productService = ProductService();
    final result = await productService.deleteProduct(
      context: context,
      productId: widget.product.id,
    );

    if (result['success']) {
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AdminShopPage(
            shop: widget.shop,
          ),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Colors.transparent,
        title: Text(
          'Product',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              deleteProductHandler();
            },
            icon: Icon(
              Icons.delete_rounded,
              size: 32,
              color: Colors.red.shade300,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProductEditPage(
                          product: productDetail,
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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ========================= Start Images =========================
                MyGallery(imageUrls: imageUrls),
                // ========================= End Images =========================

                // ========================= Start Detail =========================
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          widget.product.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      isLoadingProductDetail
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  Text(
                                    '${productDetail.price} \$',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.redAccent),
                                  ),
                                  // Text(
                                  //   productDetail.isInstock
                                  //       ? 'Instock'
                                  //       : 'Not-Instock',
                                  //   style: TextStyle(
                                  //     fontSize: 16,
                                  //     color: productDetail.isInstock
                                  //         ? Colors.green
                                  //         : Colors.yellow.shade700,
                                  //   ),
                                  // ),
                                  const SizedBox(height: 8.0),
                                  Visibility(
                                    visible:
                                        productDetail.categoryName.isNotEmpty,
                                    child: DetailListCard(
                                      keyword: 'Category',
                                      value: productDetail.categoryName,
                                    ),
                                  ),
                                  Visibility(
                                    visible:
                                        productDetail.bodyTypeName.isNotEmpty,
                                    child: DetailListCard(
                                      keyword: 'Body Type',
                                      value: productDetail.bodyTypeName,
                                    ),
                                  ),
                                  Visibility(
                                    visible: productDetail.brandName.isNotEmpty,
                                    child: DetailListCard(
                                      keyword: 'Brand',
                                      value: productDetail.brandName,
                                    ),
                                  ),
                                  Visibility(
                                    visible: productDetail.createdAt.isNotEmpty,
                                    child: DetailListCard(
                                      keyword: 'Post Date',
                                      value: productDetail.createdAt,
                                    ),
                                  ),

                                  ListTile(
                                    contentPadding: EdgeInsets.all(2),
                                    title: Text(
                                      'Description',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(productDetail.description),
                                  ),
                                ])
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showContactModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Contact',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ContactButton(
                  phoneNumber: shopDetail.phone,
                  label: 'Number : ${shopDetail.phone}'),
              // ContactButton(phoneNumber: '063561156', label: 'Metfone : 063561156'),
              // ContactButton(phoneNumber: '062561155', label: 'Smart : 062561155'),
              SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}

class ContactButton extends StatelessWidget {
  final String phoneNumber;
  final String label;

  const ContactButton({super.key, required this.phoneNumber, required this.label});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
        if (await canLaunchUrl(phoneUri)) {
          await launchUrl(phoneUri);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not make a call')),
          );
        }
      },
      child: Text(label),
    );
  }
}
