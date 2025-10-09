class AdModel {
  final int id;
  final String? title;
  final String? description;
  final String? imageUrl;
  final String? phone;
  final String? address;

  AdModel({
    required this.id,
    this.title,
    this.description,
    this.imageUrl,
    this.phone,
    this.address,
  });

  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['image_url'],
      phone: json['phone'],
      address: json['address'],
    );
  }
}
