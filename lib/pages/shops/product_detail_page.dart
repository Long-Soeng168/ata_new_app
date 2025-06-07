// ignore_for_file: prefer_const_constructors

import 'package:ata_new_app/components/buttons/my_elevated_button.dart';
import 'package:ata_new_app/components/cards/detail_list_card.dart';
import 'package:ata_new_app/components/cards/product_card.dart';
import 'package:ata_new_app/components/cards/shop_tile_card.dart';
import 'package:ata_new_app/components/my_gallery.dart';
import 'package:ata_new_app/components/my_list_header.dart';
import 'package:ata_new_app/models/product.dart';
import 'package:ata_new_app/models/shop.dart';
import 'package:ata_new_app/pages/shops/products_list_page.dart';
import 'package:ata_new_app/pages/shops/shop_detail_page.dart';
import 'package:ata_new_app/services/product_service.dart';
import 'package:ata_new_app/services/shop_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.product});
  final Product product;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
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
        // actions: [
        //   IconButton(
        //     onPressed: () {},
        //     icon: Icon(
        //       Icons.favorite,
        //       size: 32,
        //     ),
        //   ),
        // ],
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
                            fontSize: 20,
                            // fontWeight: FontWeight.bold,
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
                                  Visibility(
                                    visible:
                                        productDetail.description.isNotEmpty,
                                    child: ListTile(
                                      contentPadding: EdgeInsets.all(2),
                                      title: Text(
                                        'Description',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(productDetail.description),
                                    ),
                                  ),
                                ])
                    ],
                  ),
                ),

                if (!isLoadingShopDetail && !isLoadingShopDetailError)
                  ShopTileCard(
                    imageUrl: shopDetail.logoUrl,
                    address: shopDetail.address,
                    name: shopDetail.name,
                    phone: shopDetail.phone,
                    onTap: () {
                      final route = MaterialPageRoute(
                          builder: (context) => ShopDetailPage(
                                shop: shopDetail,
                              ));
                      Navigator.push(context, route);
                    },
                  ),
                // ========================= End Detail =========================

                // ========================= Start Related Product =========================
                SizedBox(height: 24),

                if (relatedProducts.isNotEmpty)
                  Column(
                    children: [
                      MyListHeader(
                        title: 'Related Products',
                        onTap: () {
                          final route = MaterialPageRoute(
                              builder: (context) => ProductsListPage());
                          Navigator.push(context, route);
                        },
                      ),
                      SizedBox(
                        height:
                            290, // Set a fixed height for horizontal ListView
                        child: ListView.builder(
                          itemCount: relatedProducts.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final product = relatedProducts[index];
                            return ProductCard(
                                imageUrl: product.imageUrl,
                                title: product.name,
                                price: product.price,
                                onTap: () {
                                  final route = MaterialPageRoute(
                                    builder: (context) => ProductDetailPage(
                                      product: product,
                                    ),
                                  );
                                  Navigator.push(context, route);
                                });
                          },
                        ),
                      ),
                      // ========================= End Related Product =========================
                    ],
                  ),

                SizedBox(height: 80),
              ],
            ),
          ),
          if (!isLoadingShopDetail && !isLoadingShopDetailError)
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: MyElevatedButton(
                  title: 'Call',
                  onPressed: () => showContactModal(context),
                  // onPressed: () async {
                  //   final Uri phoneUri = Uri(
                  //       scheme: 'tel',
                  //       path: '061561154');
                  //  if (await canLaunchUrl(phoneUri)) {
                  //     await launchUrl(phoneUri);
                  //   } else {
                  //     MySnackBar(context, 'Failed to make a call');
                  //     print("Could not launch the dialer.");
                  //   }
                  // },
                ),
              ),
            )
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

  const ContactButton(
      {super.key, required this.phoneNumber, required this.label});

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
