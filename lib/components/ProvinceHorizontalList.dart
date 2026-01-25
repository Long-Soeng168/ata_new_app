import 'dart:convert';
import 'package:ata_new_app/pages/garages/garages_list_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProvinceHorizontalList extends StatefulWidget {
  const ProvinceHorizontalList({
    super.key,
    this.onProvinceTap,
    this.selectedId,
  });

  final Function(int)? onProvinceTap;
  final int? selectedId;

  @override
  State<ProvinceHorizontalList> createState() => _ProvinceHorizontalListState();
}

class _ProvinceHorizontalListState extends State<ProvinceHorizontalList> {
  List<dynamic> provinces = [];
  bool isLoading = true;
  String? errorMessage;

  // Controller to handle scrolling back to the start when sorting
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchProvinces();
  }

  // Listen for changes from the parent (e.g., when tapping a province)
  @override
  void didUpdateWidget(covariant ProvinceHorizontalList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If selection changed, re-sort the existing list and scroll to front
    if (widget.selectedId != oldWidget.selectedId && provinces.isNotEmpty) {
      _sortAndScroll();
    }
  }

  void _sortAndScroll() {
    setState(() {
      provinces.sort((a, b) {
        if (a['id'] == widget.selectedId) return -1;
        if (b['id'] == widget.selectedId) return 1;
        return 0;
      });
    });

    // Smoothly scroll back to the start to show the selected item at index 0
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _fetchProvinces() async {
    try {
      final response =
          await http.get(Uri.parse('https://atech-auto.com/api/provinces'));
      if (response.statusCode == 200) {
        if (mounted) {
          List<dynamic> data = json.decode(response.body);

          // Initial sort if a selection already exists
          if (widget.selectedId != null) {
            data.sort((a, b) {
              if (a['id'] == widget.selectedId) return -1;
              if (b['id'] == widget.selectedId) return 1;
              return 0;
            });
          }

          setState(() {
            provinces = data;
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "Failed to load provinces";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  void _showAllProvinces(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProvinceSearchSheet(
        provinces: provinces.cast<Map<String, dynamic>>(),
        selectedId: widget.selectedId,
        onProvinceTap: widget.onProvinceTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Provinces'.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              if (!isLoading && errorMessage == null)
                TextButton(
                  onPressed: () => _showAllProvinces(context),
                  child: Text('See All'.tr(),
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ),
        _buildContent(),
      ],
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const SizedBox(
          height: 110, child: Center(child: CircularProgressIndicator()));
    }
    if (errorMessage != null) {
      return SizedBox(
          height: 110,
          child: Center(
              child: Text(errorMessage!,
                  style: const TextStyle(color: Colors.red))));
    }

    return SizedBox(
      height: 110,
      child: ListView.builder(
        controller: _scrollController, // Attach controller here
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: provinces.length,
        itemBuilder: (context, index) {
          final province = provinces[index];
          final bool isSelected = widget.selectedId == province['id'];

          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12, bottom: 8),
            child: Material(
              color: isSelected ? Colors.blueAccent : Colors.white,
              borderRadius: BorderRadius.circular(12),
              elevation: isSelected ? 8 : 4,
              shadowColor: Colors.black12,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  if (widget.onProvinceTap != null) {
                    widget.onProvinceTap!(province['id']);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              GaragesListPage(provinceId: province['id'])),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -10,
                        bottom: -10,
                        child: Icon(
                          Icons.location_on,
                          size: 60,
                          color: isSelected
                              ? Colors.white.withOpacity(0.2)
                              : Colors.blueAccent.withOpacity(0.05),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            province["name_kh"] ?? '',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.blueGrey[900]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            province["name"] ?? '',
                            style: TextStyle(
                                fontSize: 13,
                                color: isSelected
                                    ? Colors.white.withOpacity(0.9)
                                    : Colors.blueAccent,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
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

class _ProvinceSearchSheet extends StatefulWidget {
  final List<Map<String, dynamic>> provinces;
  final Function(int)? onProvinceTap;
  final int? selectedId;

  const _ProvinceSearchSheet({
    required this.provinces,
    this.onProvinceTap,
    this.selectedId,
  });

  @override
  State<_ProvinceSearchSheet> createState() => _ProvinceSearchSheetState();
}

class _ProvinceSearchSheetState extends State<_ProvinceSearchSheet> {
  late List<Map<String, dynamic>> filteredList;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredList = widget.provinces;
  }

  void _filter(String val) {
    setState(() {
      filteredList = widget.provinces
          .where((p) =>
              (p['name']?.toLowerCase().contains(val.toLowerCase()) ?? false) ||
              (p['name_kh']?.contains(val) ?? false))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
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
              onChanged: _filter,
              decoration: InputDecoration(
                hintText: 'Search province...'.tr(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          _filter("");
                        })
                    : null,
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
                final bool isSelected = widget.selectedId == item['id'];

                return ListTile(
                  selected: isSelected,
                  selectedTileColor: Colors.blueAccent.withOpacity(0.1),
                  title: Text(item['name_kh'] ?? '',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.blueAccent : null)),
                  subtitle: Text(item['name'] ?? ''),
                  leading: Icon(Icons.location_city,
                      color: isSelected ? Colors.blueAccent : Colors.grey),
                  onTap: () {
                    Navigator.pop(context);
                    if (widget.onProvinceTap != null) {
                      widget.onProvinceTap!(item['id']);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                GaragesListPage(provinceId: item['id'])),
                      );
                    }
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
