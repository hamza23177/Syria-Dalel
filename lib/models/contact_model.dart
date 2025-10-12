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

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      phone: json['phone'],
      whatsapp: json['whatsapp'],
      address: json['address'],
      googleMapLink: json['google_map_link'],
      createdAt:
      json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt:
      json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }
}
