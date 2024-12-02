class Shop {
  final int id;
  final String name;
  final String description;
  final String logoUrl;
  final String bannerUrl;
  final String address;
  final String phone; 
  final int ownerId;

  Shop({
    required this.id,
    required this.name,
    required this.description,
    required this.logoUrl,
    required this.bannerUrl,
    required this.address,
    required this.phone, 
    this.ownerId = 0,
  });
}
