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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Area {
  final int id;
  final String name;
  final Governorate governorate;

  Area({required this.id, required this.name, required this.governorate});

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'],
      name: json['name'],
      governorate: Governorate.fromJson(json['governorate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'governorate': governorate.toJson(),
    };
  }
}

class Category {
  final int id;
  final String name;
  final String imageUrl;
  final Area area;

  Category({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.area,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'] ?? '',
      area: Area.fromJson(json['area']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'area': area.toJson(),
    };
  }
}

class SubCategory {
  final int id;
  final String name;
  final String imageUrl;
  final Category category;

  SubCategory({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.category,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'] ?? '',
      category: Category.fromJson(json['category']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'category': category.toJson(),
    };
  }
}

class Product {
  final int id;
  final String name;
  final String imageUrl;
  final String area;
  final String governorate;
  final String category;
  final String subcategory;
  final String? imageUrl2;
  final String? imageUrl3;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.area,
    required this.governorate,
    required this.category,
    required this.subcategory,
    this.imageUrl2,
    this.imageUrl3,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'] ?? '',
      area: json['area'],
      governorate: json['governorate'],
      category: json['category'],
      subcategory: json['subcategory'],
      imageUrl2: json['image_url_2'],
      imageUrl3: json['image_url_3'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'area': area,
      'governorate': governorate,
      'category': category,
      'subcategory': subcategory,
      'image_url_2': imageUrl2,
      'image_url_3': imageUrl3,
    };
  }
}

class HomeData {
  final List<Governorate> governorates;
  final List<Area> areas;
  final List<Category> categories;
  final List<SubCategory> subCategories;
  final List<Product> products;

  HomeData({
    required this.governorates,
    required this.areas,
    required this.categories,
    required this.subCategories,
    required this.products,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      governorates: (json['governorates'] as List)
          .map((e) => Governorate.fromJson(e))
          .toList(),
      areas: (json['areas'] as List)
          .map((e) => Area.fromJson(e))
          .toList(),
      categories: (json['category'] as List)
          .map((e) => Category.fromJson(e))
          .toList(),
      subCategories: (json['subCategory'] as List)
          .map((e) => SubCategory.fromJson(e))
          .toList(),
      products: (json['products'] as List)
          .map((e) => Product.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'governorates': governorates.map((e) => e.toJson()).toList(),
      'areas': areas.map((e) => e.toJson()).toList(),
      'category': categories.map((e) => e.toJson()).toList(),
      'subCategory': subCategories.map((e) => e.toJson()).toList(),
      'products': products.map((e) => e.toJson()).toList(),
    };
  }
}
