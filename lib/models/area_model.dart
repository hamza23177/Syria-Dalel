
// area_model.dart
import 'category_model.dart';
import 'governorate_model.dart';

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'governorate': governorate.toJson(), // ✅ تأكد أنها موجودة
    };
  }
}

