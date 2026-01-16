class Avatar {
  final int? id;
  final int userId;
  final String hairStyle;
  final String hairColor;
  final String outfit;
  final String outfitColor;
  final String? updatedAt;

  Avatar({
    this.id,
    required this.userId,
    required this.hairStyle,
    required this.hairColor,
    required this.outfit,
    required this.outfitColor,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'hair_style': hairStyle,
      'hair_color': hairColor,
      'outfit': outfit,
      'outfit_color': outfitColor,
      'updated_at': updatedAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory Avatar.fromMap(Map<String, dynamic> map) {
    return Avatar(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      hairStyle: map['hair_style'] as String,
      hairColor: map['hair_color'] as String,
      outfit: map['outfit'] as String,
      outfitColor: map['outfit_color'] as String,
      updatedAt: map['updated_at'] as String?,
    );
  }

  Avatar copyWith({
    int? id,
    int? userId,
    String? hairStyle,
    String? hairColor,
    String? outfit,
    String? outfitColor,
    String? updatedAt,
  }) {
    return Avatar(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      hairStyle: hairStyle ?? this.hairStyle,
      hairColor: hairColor ?? this.hairColor,
      outfit: outfit ?? this.outfit,
      outfitColor: outfitColor ?? this.outfitColor,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
