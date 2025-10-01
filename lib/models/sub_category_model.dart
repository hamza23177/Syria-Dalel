// features/category/model/sub_category_model.dart
class SubCategoryResponse {
  final List<SubCategory> data;
  final Links links;
  final Meta meta;

  SubCategoryResponse({
    required this.data,
    required this.links,
    required this.meta,
  });

  factory SubCategoryResponse.fromJson(Map<String, dynamic> json) {
    return SubCategoryResponse(
      data: (json['data'] as List)
          .map((e) => SubCategory.fromJson(e))
          .toList(),
      links: Links.fromJson(json['links']),
      meta: Meta.fromJson(json['meta']),
    );
  }
}

class SubCategory {
  final int id;
  final String name;
  final String? description;
  final int categoryId;
  final int? imageId;
  final String? imageUrl;
  final Category category;
  final String createdAt;
  final String updatedAt;

  SubCategory({
    required this.id,
    required this.name,
    this.description,
    required this.categoryId,
    this.imageId,
    this.imageUrl,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      categoryId: json['category_id'],
      imageId: json['image_id'],
      imageUrl: json['image_url'],
      category: Category.fromJson(json['category']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class Category {
  final int id;
  final String name;
  final String? imageUrl;
  final Area area;

  Category({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.area,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'],
      area: Area.fromJson(json['area']),
    );
  }
}

class Area {
  final int id;
  final String name;
  final Governorate governorate;

  Area({
    required this.id,
    required this.name,
    required this.governorate,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'],
      name: json['name'],
      governorate: Governorate.fromJson(json['governorate']),
    );
  }
}

class Governorate {
  final int id;
  final String name;

  Governorate({required this.id, required this.name});

  factory Governorate.fromJson(Map<String, dynamic> json) {
    return Governorate(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Links {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  Links({this.first, this.last, this.prev, this.next});

  factory Links.fromJson(Map<String, dynamic> json) {
    return Links(
      first: json['first'],
      last: json['last'],
      prev: json['prev'],
      next: json['next'],
    );
  }
}

class Meta {
  final int currentPage;
  final int from;
  final int lastPage;
  final int perPage;
  final int to;
  final int total;

  Meta({
    required this.currentPage,
    required this.from,
    required this.lastPage,
    required this.perPage,
    required this.to,
    required this.total,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      currentPage: json['current_page'],
      from: json['from'],
      lastPage: json['last_page'],
      perPage: json['per_page'],
      to: json['to'],
      total: json['total'],
    );
  }
}
