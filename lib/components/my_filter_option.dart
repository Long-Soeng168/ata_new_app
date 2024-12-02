import 'package:ata_new_app/components/error_image.dart';
import 'package:flutter/material.dart';

class MyFilterOption extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> options;
  final Function handleSelect;
  final int? selectedItem; 

  const MyFilterOption({
    super.key,
    required this.title,
    required this.options,
    required this.handleSelect,
    this.selectedItem, 
  });

  @override
  _MyFilterOptionState createState() => _MyFilterOptionState();
}

class _MyFilterOptionState extends State<MyFilterOption> {
  int? selectedOption;

  @override
  void initState() {
    // TODO: implement initState
    selectedOption = widget.selectedItem;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal, // Enable horizontal scrolling
          child: Row(children: [
            ChoiceChip(
              showCheckmark: false,
              label: IntrinsicWidth(
                child: SizedBox(
                  height: 50,
                  child: Center(
                    child: Text(
                      'All',
                      style: TextStyle(
                        color: selectedOption == null
                            ? Colors.white
                            : Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              selected: selectedOption == null,
              selectedColor: Theme.of(context)
                  .colorScheme
                  .primary, // Background color when selected
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .surface, // Background color when not selected
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0), // Rounded corners
                side: BorderSide(
                  color: selectedOption == null
                      ? Theme.of(context)
                          .colorScheme
                          .primary // Border color when selected
                      : Theme.of(context)
                          .colorScheme
                          .primary, // Border color when not selected
                  width: 0.5, // Border width
                ),
              ),
              onSelected: (selected) {
                setState(() {
                  selectedOption = null;
                });
                widget.handleSelect(null);
              },
            ), 

            const SizedBox(
              width: 8,
            ),
            ...widget.options.map((option) {
              return Padding(
                // Add spacing between ChoiceChips
                padding: const EdgeInsets.only(
                    right: 8), // Right spacing for horizontal alignment
                child: ChoiceChip(
                  showCheckmark: false,
                  label: IntrinsicWidth(
                    child: Column(
                      children: [
                        Image.network(
                          option['image'],
                          height: 32,
                          width: 32,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const ErrorImage(size: 32);
                          },
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) {
                              return child;
                            } else {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          },
                        ),
                        Text(
                          option['title'].toString(),
                          style: TextStyle(
                            color: selectedOption == option['id']
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  selected: selectedOption == option['id'],
                  selectedColor: Theme.of(context)
                      .colorScheme
                      .primary, // Background color when selected
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .surface, // Background color when not selected
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // Rounded corners
                    side: BorderSide(
                      color: selectedOption == option['id']
                          ? Theme.of(context)
                              .colorScheme
                              .primary // Border color when selected
                          : Theme.of(context)
                              .colorScheme
                              .primary, // Border color when not selected
                      width: 0.5, // Border width
                    ),
                  ),
                  onSelected: (selected) {
                    setState(() {
                      selectedOption = selected ? option['id'] : null;
                    });
                    widget.handleSelect(selectedOption);
                  },
                ),
              );
            }),
          ]),
        )
      ],
    );
  }
}
