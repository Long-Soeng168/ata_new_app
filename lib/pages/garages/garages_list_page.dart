// ignore_for_file: prefer_const_constructors

import 'package:ata_new_app/components/ProvinceHorizontalList.dart';
import 'package:ata_new_app/components/buttons/my_elevated_button.dart';
import 'package:ata_new_app/components/cards/garage_card.dart';
import 'package:ata_new_app/components/my_filter_option.dart';
import 'package:ata_new_app/components/my_search.dart';
import 'package:ata_new_app/models/brand.dart';
import 'package:ata_new_app/models/garage.dart';
import 'package:ata_new_app/pages/garages/garage_detail_page.dart';
import 'package:ata_new_app/services/brand_service.dart';
import 'package:ata_new_app/services/garage_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class GaragesListPage extends StatefulWidget {
  const GaragesListPage({super.key, this.expertId, this.provinceId});
  final int? expertId;
  final int? provinceId;

  @override
  State<GaragesListPage> createState() => _GaragesListPageState();
}

class _GaragesListPageState extends State<GaragesListPage> {
  List<Garage> garages = [];
  bool isLoadingGarages = true;
  bool isLoadingGaragesError = false;
  bool hasMoreGarages = true;
  bool isLoadingMore = false;
  int currentPage = 1;

  List<Brand> brands = [];
  bool isLoadingBrands = true;
  bool isLoadingBrandsError = false;

  String? search;
  int? selectedBrandId;
  int? selectedProvinceId; // Added province state

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initialize filters from widget parameters
    selectedBrandId = widget.expertId;
    selectedProvinceId = widget.provinceId;

    getGarages();
    getBrands();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore) {
        loadMoreGarages();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Reusable method to reset pagination and show loading
  void _resetAndFetch() {
    setState(() {
      isLoadingGarages = true;
      currentPage = 1;
      hasMoreGarages = true;
    });
    getGarages();
  }

  Future<void> getGarages() async {
    try {
      final fetchedGarages = await GarageService.fetchGarages(
          page: 1,
          expertId: selectedBrandId,
          provinceId: selectedProvinceId, // Added provinceId to service call
          search: search);
      setState(() {
        garages = fetchedGarages;
        isLoadingGarages = false;
      });
    } catch (error) {
      setState(() {
        isLoadingGarages = false;
        isLoadingGaragesError = true;
        isLoadingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load Data')),
      );
    }
  }

  Future<void> loadMoreGarages() async {
    if (!hasMoreGarages || isLoadingMore) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      currentPage++;
      final fetchedGarages = await GarageService.fetchGarages(
          page: currentPage,
          expertId: selectedBrandId,
          provinceId: selectedProvinceId, // Keep filters during pagination
          search: search);

      setState(() {
        garages.addAll(fetchedGarages);
        isLoadingMore = false;
        if (fetchedGarages.isEmpty) {
          hasMoreGarages = false;
        }
      });
    } catch (error) {
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  Future<void> getBrands() async {
    try {
      final fetchedBrands = await BrandService.fetchBrands();
      setState(() {
        brands = fetchedBrands;
        isLoadingBrands = false;
      });
    } catch (error) {
      setState(() {
        isLoadingBrands = false;
        isLoadingBrandsError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
        titleSpacing: 0,
        title: Row(
          children: [
            Expanded(
              child: MySearch(
                placeholder: 'Search...'.tr(),
                searchController: _searchController,
                onSearchSubmit: () {
                  search = _searchController.text;
                  _resetAndFetch();
                },
              ),
            ),
            if (isLoadingBrands)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else
              IconButton(
                onPressed: () => filterModal(context),
                icon: Icon(Icons.filter_list, size: 32),
              ),
          ],
        ),
      ),
      body: isLoadingGarages
          ? Center(child: CircularProgressIndicator())
          : garages.isNotEmpty
              ? SafeArea(
                  child: Stack(
                    children: [
                      CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          // Province Filter List
                          SliverToBoxAdapter(
                            child: ProvinceHorizontalList(
                              // 1. Pass the current state to the component
                              selectedId: selectedProvinceId,
                              onProvinceTap: (id) {
                                setState(() {
                                  // 2. Logic: If user taps the same province, clear the filter (unselect)
                                  // If they tap a different one, select that one.
                                  if (selectedProvinceId == id) {
                                    selectedProvinceId = null;
                                  } else {
                                    selectedProvinceId = id;
                                  }
                                });
                                // 3. Refresh the garage list with the new filter
                                _resetAndFetch();
                              },
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.all(8.0),
                            sliver: SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.95,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final garage = garages[index];
                                  return GarageCard(
                                    id: garage.id,
                                    name: garage.name,
                                    address: garage.address,
                                    expert: garage.expertName,
                                    logoUrl: garage.logoUrl,
                                    bannerUrl: garage.bannerUrl,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              GarageDetailPage(garage: garage),
                                        ),
                                      );
                                    },
                                  );
                                },
                                childCount: garages.length,
                              ),
                            ),
                          ),
                          // Extra space for the loading indicator at the bottom
                          if (isLoadingMore)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              ),
                            )
                        ],
                      ),
                    ],
                  ),
                )
              : Center(child: Text('No Data'.tr())),
    );
  }

  Future<dynamic> filterModal(BuildContext context) {
    return showModalBottomSheet(
      showDragHandle: true,
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyFilterOption(
                  title: 'Experts'.tr(),
                  selectedItem: selectedBrandId,
                  options: brands.map((item) {
                    return {
                      'id': item.id,
                      'title': item.name,
                      'image': item.imageUrl,
                    };
                  }).toList(),
                  handleSelect: (selected) {
                    setState(() {
                      selectedBrandId = selected;
                    });
                  },
                ),
                SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: MyElevatedButton(
                    onPressed: () {
                      _resetAndFetch();
                      Navigator.pop(context);
                    },
                    title: 'Filter'.tr(),
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
