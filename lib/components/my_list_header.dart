import 'package:flutter/material.dart';

class MyListHeader extends StatelessWidget {
  const MyListHeader({
    super.key,
    required this.title,
    this.isShowSeeMore = true,
    this.onTap,
  });

  final String title;
  final bool isShowSeeMore;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            if (isShowSeeMore) // Conditional rendering
              Row(
                children: [
                  Text(
                    'See More',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
