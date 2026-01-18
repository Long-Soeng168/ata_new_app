import 'package:flutter/material.dart';

class ProvinceHorizontalList extends StatelessWidget {
  const ProvinceHorizontalList({super.key, this.onProvinceTap});

  final Function(int)? onProvinceTap;

  // 1. Static data for provinces
  final List<Map<String, dynamic>> provinces = const [
    {"id": 4, "name": "Banteay Meanchey", "name_kh": "បន្ទាយមានជ័យ"},
    {"id": 5, "name": "Battambang", "name_kh": "បាត់ដំបង"},
    {"id": 6, "name": "Phnom Penh", "name_kh": "ភ្នំពេញ"},
    {"id": 7, "name": "Siem Reap", "name_kh": "សៀមរាប"},
    {"id": 8, "name": "Kampot", "name_kh": "កំពត"},
    {"id": 9, "name": "Kandal", "name_kh": "កណ្តាល"},
  ];

  // 2. Open Search Sheet
  void _showAllProvinces(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProvinceSearchSheet(
        provinces: provinces,
        onProvinceTap: onProvinceTap, // Passing callback to the sheet
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Header Row ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Provinces',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[900],
                ),
              ),
              TextButton(
                onPressed: () => _showAllProvinces(context),
                child: const Text('See All',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),

        // --- Horizontal List ---
        SizedBox(
          height: 110,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: provinces.length,
            itemBuilder: (context, index) {
              final province = provinces[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12, bottom: 8),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  elevation: 4,
                  shadowColor: Colors.black12,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      if (onProvinceTap != null) {
                        onProvinceTap!(province["id"]);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -10,
                            bottom: -10,
                            child: Icon(Icons.location_on,
                                size: 60,
                                color: Colors.blueAccent.withOpacity(0.05)),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                province["name_kh"],
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.blueGrey[900]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                province["name"],
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.blueAccent,
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
        ),
      ],
    );
  }
}

// --- Internal Search Sheet Widget ---
class _ProvinceSearchSheet extends StatefulWidget {
  final List<Map<String, dynamic>> provinces;
  final Function(int)? onProvinceTap; // Added this

  const _ProvinceSearchSheet({
    required this.provinces,
    this.onProvinceTap, // Added this
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
              p['name'].toLowerCase().contains(val.toLowerCase()) ||
              p['name_kh'].contains(val))
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
                hintText: 'Search province...',
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
                return ListTile(
                  title: Text(item['name_kh'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(item['name']),
                  leading:
                      const Icon(Icons.location_city, color: Colors.blueAccent),
                  onTap: () {
                    // 1. Close the sheet
                    Navigator.pop(context);

                    // 2. Call the tap function to update the list behind the sheet
                    if (widget.onProvinceTap != null) {
                      widget.onProvinceTap!(item['id']);
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
