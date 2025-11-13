class ContactModel {
  final int id;
  final String? name;
  final String? description;
  final String? phone;
  final String? whatsapp;
  final String? address;
  final String? googleMapLink;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ContactModel({
    required this.id,
    this.name,
    this.description,
    this.phone,
    this.whatsapp,
    this.address,
    this.googleMapLink,
    this.createdAt,
    this.updatedAt,
  });

  // ✅ من JSON إلى كائن
  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      phone: json['phone'],
      whatsapp: json['whatsapp'],
      address: json['address'],
      googleMapLink: json['google_map_link'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  // ✅ من كائن إلى JSON (لحفظه في الكاش)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'phone': phone,
      'whatsapp': whatsapp,
      'address': address,
      'google_map_link': googleMapLink,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
