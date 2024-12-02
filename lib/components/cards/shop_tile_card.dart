import 'package:ata_new_app/components/error_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ShopTileCard extends StatelessWidget {
  const ShopTileCard({
    super.key,
    this.onTap,
    this.imageUrl = '',
    this.name = 'N/A',
    this.phone = 'N/A',
    this.address = 'N/A',
    this.isShowChevron = true,
  });

  final void Function()? onTap;
  final String imageUrl;
  final bool isShowChevron;
  final String name;
  final String phone;
  final String address;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Theme.of(context).colorScheme.background,
        elevation: 0,
        shape: RoundedRectangleBorder(
            // side: BorderSide(
            //   width: 0.5,
            //   color: Theme.of(context).colorScheme.primary,
            // ),
            ),
        borderOnForeground: true,
        child: Container(
          padding: EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                  borderRadius: BorderRadius.circular(80),
                  color: Colors.grey.shade300,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(70),
                  child: AspectRatio(
                    aspectRatio: 1 / 1,
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const ErrorImage(size: 60);
                      },
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Container(
                        //   padding: EdgeInsets.only(right: 8, left: 8, top: 1),
                        //   child: Row(
                        //     children: [
                        //       Icon(Icons.star, color: Colors.amber, size: 20,),
                        //       Icon(Icons.star, color: Colors.amber, size: 20,),
                        //       Icon(Icons.star, color: Colors.amber, size: 20,),
                        //       Icon(Icons.star, color: Colors.amber, size: 20,),
                        //       Icon(Icons.star, color: Colors.amber, size: 20,),
                        //       // Icon(Icons.star_half, color: Colors.amber, size: 20,),
                        //       // Icon(Icons.star_outline, color: Colors.amber, size: 20,),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                    Text(
                      phone,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      address,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isShowChevron)
                SizedBox(
                  width: 24,
                  child: Icon(
                    Icons.chevron_right,
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
