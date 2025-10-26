class ServiceModel {
  final int id;
  final String name;
  final String phone;
  final String address;
  final String subcategory;
  final String category;
  final String area;
  final String governorate;
  final String? description;
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
    this.description,
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
      description: json['description'],
      imageUrl: json['image_url'],
      imageUrl2: json['image_url_2'],
      imageUrl3: json['image_url_3'],
    );
  }
}

class Links {
  final String? next;
  final String? prev;

  Links({this.next, this.prev});

  factory Links.fromJson(Map<String, dynamic> json) {
    return Links(
      next: json['next'],
      prev: json['prev'],
    );
  }
}

class Meta {
  final int currentPage;
  final int lastPage;

  Meta({required this.currentPage, required this.lastPage});

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      currentPage: json['current_page'],
      lastPage: json['last_page'],
    );
  }
}

class ServiceResponse {
  final List<ServiceModel> data;
  final Links links;
  final Meta meta;

  ServiceResponse({
    required this.data,
    required this.links,
    required this.meta,
  });

  factory ServiceResponse.fromJson(Map<String, dynamic> json) {
    return ServiceResponse(
      data: (json['data'] as List).map((e) => ServiceModel.fromJson(e)).toList(),
      links: Links.fromJson(json['links']),
      meta: Meta.fromJson(json['meta']),
    );
  }
}

