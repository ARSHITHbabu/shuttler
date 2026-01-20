/// Tournament data model matching backend schema
class Tournament {
  final int id;
  final String name;
  final DateTime date;
  final String location;
  final String? description;
  final String? category;

  Tournament({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    this.description,
    this.category,
  });

  /// Create Tournament instance from JSON
  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'] as int,
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      location: json['location'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
    );
  }

  /// Convert Tournament instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'date': date.toIso8601String().split('T')[0],
      'location': location,
      'description': description,
      'category': category,
    };
  }

  /// Check if tournament is upcoming
  bool get isUpcoming => date.isAfter(DateTime.now());

  /// Check if tournament is past
  bool get isPast => date.isBefore(DateTime.now());

  @override
  String toString() {
    return 'Tournament(id: $id, name: $name, date: $date, location: $location)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tournament && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
