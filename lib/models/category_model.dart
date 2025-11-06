import 'area_model.dart';

class CategoryResponse {
  final List<Category> data;
  final Links links;
  final Meta meta;

  CategoryResponse({
    required this.data,
    required this.links,
    required this.meta,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      data: (json['data'] as List)
          .map((e) => Category.fromJson(e))
          .toList(),
      links: Links.fromJson(json['links']),
      meta: Meta.fromJson(json['meta']),
    );
  }
}

class Category {
  final int id;
  final String name;
  final String description;
  final int? imageId;
  final String? imageUrl;
  final Area area;
  final String createdAt;
  final String updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.imageId,
    required this.imageUrl,
    required this.area,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageId: json['image_id'] is int
          ? json['image_id']
          : int.tryParse('${json['image_id']}'),
      imageUrl: json['image_url']?.toString(),
      area: Area.fromJson(json['area']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}


class Links {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  Links({this.first, this.last, this.prev, this.next});

  factory Links.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Links();
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
  final List<LinkItem> links;
  final String path;
  final int perPage;
  final int to;
  final int total;

  Meta({
    required this.currentPage,
    required this.from,
    required this.lastPage,
    required this.links,
    required this.path,
    required this.perPage,
    required this.to,
    required this.total,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      currentPage: json['current_page'] ?? 0,
      from: json['from'] ?? 0,
      lastPage: json['last_page'] ?? 0,
      links: (json['links'] as List?)
          ?.map((e) => LinkItem.fromJson(e))
          .toList() ??
          [],
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 0,
      to: json['to'] ?? 0,
      total: json['total'] ?? 0,
    );
  }

}

class LinkItem {
  final String? url;
  final String label;
  final bool active;

  LinkItem({
    this.url,
    required this.label,
    required this.active,
  });

  factory LinkItem.fromJson(Map<String, dynamic> json) {
    return LinkItem(
      url: json['url'],
      label: json['label'],
      active: json['active'],
    );
  }
}
