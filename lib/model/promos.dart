class Promo {
  final String id;
  final String title;
  final String subtitle;
  final String offerText;
  final String description;
  final String terms;
  final DateTime validUntil;
  final String category;
  final bool isActive;

  Promo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.offerText,
    required this.description,
    required this.terms,
    required this.validUntil,
    required this.category,
    this.isActive = true,
  });

  String get formattedValidUntil {
    return "${validUntil.day}/${validUntil.month}/${validUntil.year}";
  }

  factory Promo.fromJson(Map<String, dynamic> json) {
    return Promo(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      offerText: json['offer_text'],
      description: json['description'],
      terms: json['terms'],
      validUntil: DateTime.parse(json['valid_until']),
      category: json['category'],
      isActive: json['is_active'] == "1" || json['is_active'] == 1,
    );
  }
}
