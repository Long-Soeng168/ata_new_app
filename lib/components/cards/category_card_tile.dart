import 'package:flutter/material.dart';

class CategoryCardTile extends StatefulWidget {
  const CategoryCardTile({super.key});

  @override
  State<CategoryCardTile> createState() => _CategoryCardTileState();
}

class _CategoryCardTileState extends State<CategoryCardTile> {
  @override
  Widget build(BuildContext context) {
    return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 0.5,
                    color: Theme.of(context).colorScheme.primary
                  )
                ),
                borderOnForeground: true,
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text('សៀវភៅសម្រាប់អ្នកចុះឈ្មោះបោះឆ្នោត'),
                      ),
                      Container(
                        width: 24,
                        child: Icon(Icons.chevron_right)),
                    ],
                  ),

                ),
              );
  }
}