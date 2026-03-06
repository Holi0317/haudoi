class Tag {
  final int id;
  final String name;
  final String color;
  final String emoji;
  final int createdAt;

  const Tag({
    required this.id,
    required this.name,
    required this.color,
    required this.emoji,
    required this.createdAt,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as int,
      name: json['name'] as String,
      color: json['color'] as String,
      emoji: json['emoji'] as String,
      createdAt: json['created_at'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'emoji': emoji,
      'created_at': createdAt,
    };
  }
}

class TagListResponse {
  final List<Tag> items;

  const TagListResponse({required this.items});

  factory TagListResponse.fromJson(Map<String, dynamic> json) {
    final itemsRaw = (json['items'] as List<dynamic>? ?? const []);

    return TagListResponse(
      items: itemsRaw
          .map((item) => Tag.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TagCreateBody {
  final String name;
  final String color;
  final String? emoji;

  const TagCreateBody({
    required this.name,
    required this.color,
    this.emoji,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'color': color,
      if (emoji != null) 'emoji': emoji,
    };
  }
}

class TagUpdateBody {
  final String? name;
  final String? color;
  final String? emoji;

  const TagUpdateBody({
    this.name,
    this.color,
    this.emoji,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (emoji != null) 'emoji': emoji,
    };
  }
}
