import 'package:ata_new_app/models/video_playlist.dart';

class CartItem {
  final VideoPlaylist videoPlaylist;
  int quantity;

  CartItem({required this.videoPlaylist, this.quantity = 1});

  // Convert a CartItem into a Map object for JSON encoding
  Map<String, dynamic> toJson() => {
        'videoPlaylist': videoPlaylist.toJson(),
        'quantity': quantity,
      };

  // Create a CartItem from a Map object (for decoding)
  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        videoPlaylist: VideoPlaylist.fromJson(json['videoPlaylist']),
        quantity: json['quantity'],
      );
}
