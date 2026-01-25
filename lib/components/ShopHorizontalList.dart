import 'package:ata_new_app/components/my_list_header.dart';
import 'package:ata_new_app/models/shop.dart';
import 'package:ata_new_app/pages/shops/shop_detail_page.dart';
import 'package:ata_new_app/pages/shops/shops_list_page.dart';
import 'package:ata_new_app/services/shop_service.dart'; // Import your service
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ShopHorizontalList extends StatefulWidget {
  const ShopHorizontalList({super.key, this.onShopTap});

  final Function(Shop)? onShopTap;

  @override
  State<ShopHorizontalList> createState() => _ShopHorizontalListState();
}

class _ShopHorizontalListState extends State<ShopHorizontalList> {
  List<Shop> shops = [];
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    getTopShops();
  }

  // --- Uses your existing ShopService logic ---
  Future<void> getTopShops() async {
    try {
      final data = await ShopService.fetchShops(
        page: 1, // We only need the first page for the horizontal list
        // You can add a limit here if your service supports it
      );

      if (mounted) {
        setState(() {
          shops = data;
          isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyListHeader(
          title: 'Shops'.tr(),
          onTap: () {
            final route =
                MaterialPageRoute(builder: (context) => ShopsListPage());
            Navigator.push(context, route);
          },
        ),
        _buildContent(),
      ],
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const SizedBox(
        height: 110,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (isError) {
      return const SizedBox(
        height: 110,
        child: Center(child: Icon(Icons.error_outline, color: Colors.red)),
      );
    }

    return SizedBox(
      height: 110,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: shops.length,
        itemBuilder: (context, index) {
          final shop = shops[index];
          return Container(
            width: 220,
            margin: const EdgeInsets.only(right: 12, bottom: 8),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              elevation: 3,
              shadowColor: Colors.black12,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ShopDetailPage(shop: shop),
                    ),
                  )
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          shop.logoUrl, // Using your model's getter
                          width: 55,
                          height: 55,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 55,
                              height: 55,
                              color: Colors.grey[100],
                              child: const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 55,
                            height: 55,
                            color: Colors.grey[100],
                            child: const Icon(Icons.store, color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              shop.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey[900],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              shop.address,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
