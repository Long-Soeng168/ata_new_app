import 'package:flutter/material.dart';

class FolderCard extends StatelessWidget {
  const FolderCard({super.key, this.onTap, this.isFolder = true, this.name = ''});

  final void Function()? onTap;
  final bool isFolder;
  final String name;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        shape: const RoundedRectangleBorder(
            // side: BorderSide(
            //   width: 0.5,
            //   color: Theme.of(context).colorScheme.primary,
            // ),
            ),
        borderOnForeground: true,
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              isFolder
                  ? Image.asset(
                      'lib/assets/icons/folder.png',
                      width: 28,
                      height: 28,
                    )
                  : Image.asset(
                      'lib/assets/icons/pdf.png',
                      width: 28,
                      height: 28,
                    ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(),
                ),
              ),
              SizedBox(
                width: 24,
                child: Icon(
                  isFolder
                      ? Icons.chevron_right
                      : Icons.remove_red_eye_outlined,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
