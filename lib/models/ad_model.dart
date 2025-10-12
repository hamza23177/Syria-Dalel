class AdImage {
  final int id;
  final String url;

  AdImage({
    required this.id,
    required this.url,
  });

  factory AdImage.fromJson(Map<String, dynamic> json) {
    return AdImage(
      id: json['id'] ?? 0,
      url: json['url'] ?? '',
    );
  }
}

class AdModel {
  final int id;
  final String? title;
  final String? description;
  final String? phone;
  final String? address;
  final List<AdImage> images;

  AdModel({
    required this.id,
    this.title,
    this.description,
    this.phone,
    this.address,
    this.images = const [],
  });

  factory AdModel.fromJson(Map<String, dynamic> json) {
    final imagesList = (json['images'] as List?)
        ?.map((i) => AdImage.fromJson(i))
        .toList() ??
        [];

    return AdModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      phone: json['phone'],
      address: json['address'],
      images: imagesList,
    );
  }

  /// الصورة الأولى فقط
  String? get firstImageUrl =>
      images.isNotEmpty ? images.first.url : null;
}
