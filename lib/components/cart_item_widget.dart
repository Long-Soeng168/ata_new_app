// widgets/cart_item_widget.dart
import 'package:ata_new_app/models/cart_item.dart';
import 'package:ata_new_app/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;

  const CartItemWidget({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return ListTile(
      leading: Image.network(cartItem.videoPlaylist.imageUrl, width: 100),
      title: Text(
        cartItem.videoPlaylist.name,
        maxLines: 2,
      ),
      subtitle: Text(
        '\$${cartItem.videoPlaylist.price}',
        maxLines: 1,
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.delete,
          color: Colors.red.shade300,
        ),
        onPressed: () {
          cartProvider.removeFromCart(cartItem.videoPlaylist.id);
        },
      ),
      // trailing: Row(
      //   mainAxisSize: MainAxisSize.min,
      //   children: [
      //     IconButton(
      //       icon: Icon(Icons.remove),
      //       onPressed: () {
      //         if (cartItem.quantity > 1) {
      //           cartProvider.decreaseQuantity(cartItem.videoPlaylist.id);
      //         } else {
      //           cartProvider.removeFromCart(cartItem.videoPlaylist.id);
      //         }
      //       },
      //     ),
      //     Text(cartItem.quantity.toString()),
      //     IconButton(
      //       icon: Icon(Icons.add),
      //       onPressed: () {
      //         cartProvider.increaseQuantity(cartItem.videoPlaylist.id);
      //       },
      //     ),
      //     IconButton(
      //       icon: Icon(Icons.delete),
      //       onPressed: () {
      //         cartProvider.removeFromCart(cartItem.videoPlaylist.id);
      //       },
      //     ),
      //   ],
      // ),
    );
  }
}
