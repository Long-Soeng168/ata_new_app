import 'package:ata_new_app/components/error_image.dart';
import 'package:flutter/material.dart';

class TabCard extends StatelessWidget {
  const TabCard(
      {super.key,
      required this.image,
      required this.title,
      this.onTap,
      this.isSelected = false});

  final String image;
  final String title;
  final void Function()? onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
                width: isSelected ? 2.5 : 0,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade400),
          ),
        ),
        padding: EdgeInsets.only(top: 12, bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              image,
              width: 20,
              height: 20,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const ErrorImage(size: 20);
              },
            ),
            SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
