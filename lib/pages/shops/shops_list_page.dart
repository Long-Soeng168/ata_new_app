// ignore_for_file: prefer_const_constructors

import 'package:ata_new_app/components/cards/shop_card.dart';
import 'package:ata_new_app/components/my_search.dart';
import 'package:ata_new_app/models/shop.dart';
import 'package:ata_new_app/pages/shops/shop_detail_page.dart';
import 'package:ata_new_app/services/shop_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ShopsListPage extends StatefulWidget {
  const ShopsListPage({super.key, this.provinceId});
  final int? provinceId;

  @override
  State<ShopsListPage> createState() => _ShopsListPageState();
}

class _ShopsListPageState extends State<ShopsListPage> {
  List<Shop> shops = [];

  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;

  int currentPage = 1;
  String? search;
  int? selectedProvinceId;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    selectedProvinceId = widget.provinceId;
    fetchShops();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore &&
          hasMore) {
        loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _resetAndFetch() {
    setState(() {
      currentPage = 1;
      hasMore = true;
      isLoading = true;
      shops.clear();
    });
    fetchShops();
  }

  Future<void> fetchShops() async {
    try {
      final data = await ShopService.fetchShops(
        page: currentPage,
        search: search,
      );

      setState(() {
        shops = data;
        isLoading = false;
        hasMore = data.isNotEmpty;
      });
    } catch (_) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load shops')),
      );
    }
  }

  Future<void> loadMore() async {
    if (!hasMore || isLoadingMore) return;

    setState(() => isLoadingMore = true);

    try {
      currentPage++;

      final data = await ShopService.fetchShops(
        page: currentPage,
        search: search,
      );

      setState(() {
        shops.addAll(data);
        isLoadingMore = false;
        if (data.isEmpty) hasMore = false;
      });
    } catch (_) {
      setState(() => isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        titleSpacing: 0,
        title: MySearch(
          placeholder: 'Search shops...'.tr(),
          searchController: _searchController,
          onSearchSubmit: () {
            search = _searchController.text;
            _resetAndFetch();
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : shops.isEmpty
              ? Center(child: Text('No shops found'.tr()))
              : CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.all(8),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final shop = shops[index];
                            return ShopCard(
                              id: shop.id,
                              name: shop.name,
                              address: shop.address,
                              phone: shop.phone,
                              logoUrl: shop.logoUrl,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ShopDetailPage(shop: shop),
                                  ),
                                );
                              },
                            );
                          },
                          childCount: shops.length,
                        ),
                      ),
                    ),
                    if (isLoadingMore)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}
