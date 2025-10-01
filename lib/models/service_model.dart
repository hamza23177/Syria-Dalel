class ServiceModel {
  final int id;
  final String name;
  final String phone;
  final String address;
  final String subcategory;
  final String category;
  final String area;
  final String governorate;
  final String? discountPrice;
  final String? imageUrl;
  final String? imageUrl2;
  final String? imageUrl3;

  ServiceModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.subcategory,
    required this.category,
    required this.area,
    required this.governorate,
    this.discountPrice,
    this.imageUrl,
    this.imageUrl2,
    this.imageUrl3,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      address: json['address'],
      subcategory: json['subcategory'],
      category: json['category'],
      area: json['area'],
      governorate: json['governorate'],
      discountPrice: json['discount_price'],
      imageUrl: json['image_url'],
      imageUrl2: json['image_url_2'],
      imageUrl3: json['image_url_3'],
    );
  }
}
