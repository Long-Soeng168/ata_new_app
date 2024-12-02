// ignore_for_file: prefer_const_constructors

import 'package:ata_new_app/components/buttons/my_elevated_button.dart';
import 'package:ata_new_app/components/cards/garage_card.dart';
import 'package:ata_new_app/components/my_filter_option.dart';
import 'package:ata_new_app/components/my_search.dart';
import 'package:ata_new_app/models/brand.dart';
import 'package:ata_new_app/models/garage.dart';
import 'package:ata_new_app/pages/garages/garage_detail_page.dart';
import 'package:ata_new_app/services/brand_service.dart';
import 'package:ata_new_app/services/garage_service.dart';
import 'package:flutter/material.dart';

class GaragesListPage extends StatefulWidget {
  const GaragesListPage({super.key, this.expertId});
  final int? expertId;

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

  final TextEditingController _searchController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if(widget.expertId != null){
      setState(() {
        selectedBrandId = widget.expertId;
      });
    }
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
    super.dispose();
  }

  Future<void> getGarages() async {
    try {
      final fetchedGarages = await GarageService.fetchGarages(
          page: 1, expertId: selectedBrandId, search: search);
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
        SnackBar(
          content: Text('Failed to load Data'),
        ),
      );
    }
  }

  Future<void> loadMoreGarages() async {
    if (!hasMoreGarages || isLoadingMore) {
      return;
    }

    setState(() {
      isLoadingMore = true;
    });

    try {
      currentPage++;
      final fetchedGarages =
          await GarageService.fetchGarages(page: currentPage);

      setState(() {
        garages.addAll(fetchedGarages);
        isLoadingMore = false;
      });

      if (fetchedGarages.isEmpty) {
        hasMoreGarages = false;
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

  Future<void> getBrands() async {
    try {
      // Fetch Garages outside of setState
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
                    isLoadingGarages = true;
                    currentPage = 1;
                    hasMoreGarages = true;
                  });
                  getGarages(); // Refetch with search query
                },
              ),
            ),
            // Actions without any extra space
            if (isLoadingBrands)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            if (!isLoadingBrands)
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
      body: isLoadingGarages
          ? Center(
              child: CircularProgressIndicator(),
            )
          : garages.isNotEmpty
              ? SafeArea(
                  child: Stack(
                    children: [
                      CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          SliverPadding(
                            padding: EdgeInsets.all(8.0),
                            sliver: SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, // Number of columns
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
                                      final route = MaterialPageRoute(
                                        builder: (context) => GarageDetailPage(
                                          garage: garage,
                                        ),
                                      );
                                      Navigator.push(context, route);
                                    },
                                  );
                                },
                                childCount: garages.length,
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
                  child: Text('No Data'),
                ),
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
                  title: 'Experts',
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
                    });
                  },
                ),

                SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: MyElevatedButton(
                    onPressed: () {
                      setState(() {
                        isLoadingGarages = true;
                        currentPage = 1;
                        hasMoreGarages = true;
                      });
                      getGarages();
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
