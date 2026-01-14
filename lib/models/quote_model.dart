import 'dart:ui';

class Quote {
  final String? id;
  final String userId;
  final String content;
  final String author;
  final String? profession;
  final String? avatar;
  final int backgroundColor;
  final int textColor;
  final double? fontSize;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final String fontFamily;

  Quote({
    this.id,
    required this.userId,
    required this.content,
    required this.author,
    this.profession,
    this.avatar,
    required this.backgroundColor,
    required this.textColor,
    required this.fontWeight,
    required this.textAlign,
    required this.fontFamily,
    this.fontSize,
  });

  // Helper parsers to handle numbers that may come as int/double or String
  static int _parseInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }

  static double _parseDouble(dynamic value, {double fallback = 28.0}) {
    if (value == null) return fallback;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? fallback;
  }

  factory Quote.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString();
    final userId = json['user_id']?.toString() ?? '';
    final content = json['content']?.toString() ?? '';
    final author = json['author']?.toString() ?? '';
    final profession = json['profession']?.toString();
    final avatar = json['avatar']?.toString();

    final backgroundColor = _parseInt(
      json['background_color'],
      fallback: 0xFFFFFFFF,
    ); // default white if missing
    final textColor = _parseInt(
      json['text_color'],
      fallback: 0xFF000000,
    ); // default black
    final fontSize = _parseDouble(json['font_size'], fallback: 20.0);

    final fontWeightIndex = _parseInt(json['font_weight'], fallback: 3);
    final textAlignIndex = _parseInt(json['text_align'], fallback: 2);
    final fontFamily = json['font_family']?.toString() ?? 'Inter';

    // Safely clamp enum indices to valid ranges
    final fontWeight =
        (fontWeightIndex >= 0 && fontWeightIndex < FontWeight.values.length)
        ? FontWeight.values[fontWeightIndex]
        : FontWeight.normal;

    final textAlign =
        (textAlignIndex >= 0 && textAlignIndex < TextAlign.values.length)
        ? TextAlign.values[textAlignIndex]
        : TextAlign.center;

    return Quote(
      id: id,
      userId: userId,
      content: content,
      author: author,
      profession: profession,
      avatar: avatar,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontWeight: fontWeight,
      fontSize: fontSize,
      textAlign: textAlign,
      fontFamily: fontFamily,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'content': content,
      'author': author,
      'profession': profession,
      'avatar': avatar,
      'background_color': backgroundColor,
      'text_color': textColor,
      'font_size': fontSize?.toInt() ?? 28,
      'font_weight': fontWeight.index,
      'text_align': textAlign.index,
      'font_family': fontFamily,
    };
  }
}
