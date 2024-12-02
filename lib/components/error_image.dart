import 'package:flutter/material.dart';

class ErrorImage extends StatelessWidget {
  const ErrorImage({super.key, this.size = 22});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100, // Background color for the error state
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined, // Display an error icon
        color: Colors.grey.shade300,
        size: size,
      ),
    );
  }
}
