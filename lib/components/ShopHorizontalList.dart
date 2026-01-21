import 'package:ata_new_app/components/my_list_header.dart';
import 'package:ata_new_app/pages/shops/shops_list_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ShopHorizontalList extends StatelessWidget {
  const ShopHorizontalList({super.key, this.onShopTap});

  final Function(Map<String, dynamic>)? onShopTap;

  final List<Map<String, dynamic>> shops = const [
    {
      "id": 1,
      "name": "AI Spare Part SHOP",
      "address": "Sokha Chan, #45E0, St. 310, Phnom Penh",
      "logo":
          "https://atech-auto.com/assets/images/shops/thumb/1746864535_ai.webp",
    },
    {
      "id": 2,
      "name": "ATA Shop",
      "address": "ផ្ទះ148, ផ្លូវ148, រាជធានីភ្នំពេញ",
      "logo":
          "https://atech-auto.com/assets/images/shops/thumb/1746876072_1732983888_1000001895.webp",
    },
    {
      "id": 8,
      "name": "CAMB-SCAM",
      "address": "ភូមិគោកឪឡឹក ,សង្កាត់ស្ពាន់ថ្ម , រាជធានីភ្នំពេញ",
      "logo":
          "https://atech-auto.com/assets/images/shops/thumb/1763793321_photo_2025-11-22_13-29-06.webp",
    },
    {
      "id": 13,
      "name": "Ousaphea Auto Parts",
      "address": "បុរីពិភពថ្មីឈូកវ៉ា 2, ភូមិ តិក្ខបញ្ញោ",
      "logo":
          "https://atech-auto.com/assets/images/shops/thumb/1766798721_FB_IMG_1766798703309.webp",
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ... Header remains same ...
        MyListHeader(
          title: 'Top Shops'.tr(),
          onTap: () {
            final route =
                MaterialPageRoute(builder: (context) => ShopsListPage());
            Navigator.push(context, route);
          },
        ),

        SizedBox(
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
                    onTap: () => onShopTap?.call(shop),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          // --- UPDATED LOGO SECTION ---
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              shop["logo"],
                              width: 55,
                              height: 55,
                              fit: BoxFit.cover,
                              // Shows while the image is downloading
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: 55,
                                  height: 55,
                                  color: Colors.grey[100],
                                  child: const Center(
                                      child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2))),
                                );
                              },
                              // Shows if the URL is broken or there is no internet
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 55,
                                height: 55,
                                color: Colors.grey[100],
                                child:
                                    const Icon(Icons.store, color: Colors.grey),
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
                                  shop["name"],
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey[900]),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  shop["address"],
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey[600]),
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
        ),
      ],
    );
  }

  void _showAllShops(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _ShopSearchSheet(shops: shops, onShopTap: onShopTap),
    );
  }
}

// --- Internal Search Sheet Updated with Network Images ---
class _ShopSearchSheet extends StatefulWidget {
  final List<Map<String, dynamic>> shops;
  final Function(Map<String, dynamic>)? onShopTap;
  const _ShopSearchSheet({required this.shops, this.onShopTap});

  @override
  State<_ShopSearchSheet> createState() => _ShopSearchSheetState();
}

class _ShopSearchSheetState extends State<_ShopSearchSheet> {
  late List<Map<String, dynamic>> filteredList;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredList = widget.shops;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
              height: 5,
              width: 40,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              onChanged: (val) => setState(() => filteredList = widget.shops
                  .where((s) =>
                      s['name'].toLowerCase().contains(val.toLowerCase()))
                  .toList()),
              decoration: InputDecoration(
                hintText: 'Search shops...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final item = filteredList[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      item['logo'],
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, e, s) =>
                          const CircleAvatar(child: Icon(Icons.store)),
                    ),
                  ),
                  title: Text(item['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(item['address'],
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onShopTap?.call(item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
