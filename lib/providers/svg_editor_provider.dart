import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

class SvgLayer {
  final String id;
  final String tagName;
  Color color;
  final XmlElement element;
  bool isVisible;
  final int index;

  SvgLayer({
    required this.id,
    required this.tagName,
    required this.color,
    required this.element,
    required this.index,
    this.isVisible = true,
  });

  SvgLayer copyWith({
    String? id,
    String? tagName,
    Color? color,
    XmlElement? element,
    bool? isVisible,
    int? index,
  }) {
    return SvgLayer(
      id: id ?? this.id,
      tagName: tagName ?? this.tagName,
      color: color ?? this.color,
      element: element ?? this.element,
      isVisible: isVisible ?? this.isVisible,
      index: index ?? this.index,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SvgLayer &&
        other.id == id &&
        other.tagName == tagName &&
        other.color == color &&
        other.isVisible == isVisible &&
        other.index == index;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        tagName.hashCode ^
        color.hashCode ^
        isVisible.hashCode ^
        index.hashCode;
  }
}
