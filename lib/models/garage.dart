class Garage {
  final int id;
  final String name;
  final String logoUrl;
  final String bannerUrl;
  final String phone;
  final String address;
  final String description;
  final String expertName;
  final String status;
  final int expertId;
  final double? latitude;   // nullable
  final double? longitude;  // nullable

  Garage({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.bannerUrl,
    required this.phone,
    required this.address,
    required this.description,
    required this.expertName,
    required this.expertId,
    required this.status,
    this.latitude,   // optional
    this.longitude,  // optional
  });
}
