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
}

class Category {
  final int id;
  final String name;
  final String imageUrl;
  final Area area;

  Category({required this.id, required this.name, required this.imageUrl, required this.area});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'] ?? '',
      area: Area.fromJson(json['area']),
    );
  }
}

class SubCategory {
  final int id;
  final String name;
  final String imageUrl;
  final Category category;

  SubCategory({required this.id, required this.name, required this.imageUrl, required this.category});

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'] ?? '',
      category: Category.fromJson(json['category']),
    );
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
}
