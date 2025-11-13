// governorate_model.dart
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

  @override
  String toString() => 'Governorate(id: $id, name: $name)';
}
