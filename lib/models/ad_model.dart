// models/ad_model.dart

class AdImage {
  final int id;
  final String url;

  AdImage({
    required this.id,
    required this.url,
  });

  factory AdImage.fromJson(Map<String, dynamic> json) {
    return AdImage(
      id: (json['id'] is int) ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      url: json['url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
    };
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
        ?.map((i) => AdImage.fromJson(Map<String, dynamic>.from(i as Map)))
        .toList() ??
        [];

    return AdModel(
      id: (json['id'] is int) ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      images: imagesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'phone': phone,
      'address': address,
      'images': images.map((e) => e.toJson()).toList(),
    };
  }

  /// الصورة الأولى فقط
  String? get firstImageUrl => images.isNotEmpty ? images.first.url : null;
}
