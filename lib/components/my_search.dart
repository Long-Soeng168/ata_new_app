import 'package:flutter/material.dart';

class MySearch extends StatefulWidget {
  final TextEditingController searchController;
  final VoidCallback onSearchSubmit;
  final String placeholder;

  const MySearch({
    super.key,
    required this.searchController,
    required this.onSearchSubmit,
    this.placeholder = 'Search DTC (កូដកំហូច)...',
  });

  @override
  State<MySearch> createState() => _MySearchState();
}

class _MySearchState extends State<MySearch> {
  @override
  void initState() {
    super.initState();

    // Listen to changes in the text field
    widget.searchController.addListener(() {
      setState(() {}); // Redraw the widget when the input changes
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8, right: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          width: 0.5,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      child: TextField(
        controller: widget.searchController,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey.shade400,
            size: 24,
          ),
          border: InputBorder.none,
          hintText: widget.placeholder,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          contentPadding: EdgeInsets.only(top: 12.0),
          suffixIcon: widget.searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: Colors.grey,
                    size: 24,
                  ),
                  onPressed: () {
                    setState(() {
                      widget.searchController.clear(); // Clear the text
                    });
                  },
                )
              : null, // Show the clear button only if there is text
        ),
        onSubmitted: (_) => widget.onSearchSubmit(), // Trigger search on submit
      ),
    );
  }
}
