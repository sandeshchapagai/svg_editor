import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

import '../providers/svg_editor_provider.dart';

class SvgParserService {
  static const List<String> _colorAttributes = ['fill', 'stroke'];
  static const List<String> _shapeElements = [
    'rect',
    'circle',
    'ellipse',
    'line',
    'polyline',
    'polygon',
    'path',
    'g'
  ];

  static XmlDocument? parseSvg(String content) {
    try {
      return XmlDocument.parse(content);
    } catch (e) {
      throw SvgParsingException('Failed to parse SVG: $e');
    }
  }

  static List<SvgLayer> extractLayers(XmlDocument document) {
    final layers = <SvgLayer>[];
    int layerIndex = 0;

    _extractLayersRecursive(document.rootElement, layers, layerIndex);
    return layers;
  }

  static void _extractLayersRecursive(
    XmlElement element,
    List<SvgLayer> layers,
    int layerIndex,
  ) {
    if (_hasColorAttribute(element)) {
      final color = _extractColor(element);
      final id = element.getAttribute('id') ?? '';

      layers.add(SvgLayer(
        id: id,
        tagName: element.name.local,
        color: color,
        element: element,
        index: layerIndex++,
      ));
    }

    for (final child in element.childElements) {
      _extractLayersRecursive(child, layers, layerIndex);
      layerIndex++;
    }
  }

  static bool _hasColorAttribute(XmlElement element) {
    // Check if element is a shape that can have colors
    if (!_shapeElements.contains(element.name.local)) {
      return false;
    }

    return _colorAttributes.any((attr) => element.getAttribute(attr) != null) ||
        (element.getAttribute('style')?.contains('fill:') ?? false) ||
        (element.getAttribute('style')?.contains('stroke:') ?? false);
  }

  static Color _extractColor(XmlElement element) {
    String? colorString;

    // Priority: fill > stroke > style
    final fill = element.getAttribute('fill');
    final stroke = element.getAttribute('stroke');
    final style = element.getAttribute('style');

    if (fill != null && fill != 'none' && fill != 'transparent') {
      colorString = fill;
    } else if (stroke != null && stroke != 'none' && stroke != 'transparent') {
      colorString = stroke;
    } else if (style != null) {
      colorString = _extractColorFromStyle(style, 'fill') ??
          _extractColorFromStyle(style, 'stroke');
    }

    return ColorParser.parseColor(colorString ?? '#000000');
  }

  static String? _extractColorFromStyle(String style, String property) {
    final regex = RegExp('$property:\\s*([^;]+)');
    final match = regex.firstMatch(style);
    return match?.group(1)?.trim();
  }

  static void updateLayerColor(SvgLayer layer, Color newColor) {
    final colorHex = ColorParser.colorToHex(newColor);

    final fill = layer.element.getAttribute('fill');
    final stroke = layer.element.getAttribute('stroke');
    final style = layer.element.getAttribute('style');

    if (fill != null && fill != 'none') {
      layer.element.setAttribute('fill', colorHex);
    } else if (stroke != null && stroke != 'none') {
      layer.element.setAttribute('stroke', colorHex);
    } else if (style != null) {
      String newStyle = style;
      if (style.contains('fill:')) {
        newStyle =
            newStyle.replaceAll(RegExp(r'fill:\s*[^;]+'), 'fill: $colorHex');
      } else if (style.contains('stroke:')) {
        newStyle = newStyle.replaceAll(
            RegExp(r'stroke:\s*[^;]+'), 'stroke: $colorHex');
      }
      layer.element.setAttribute('style', newStyle);
    }
  }

  static void toggleLayerVisibility(SvgLayer layer) {
    if (layer.isVisible) {
      layer.element.setAttribute('display', 'none');
    } else {
      layer.element.removeAttribute('display');
    }
  }
}

class ColorParser {
  static Color parseColor(String colorString) {
    colorString = colorString.trim();

    if (colorString.startsWith('#')) {
      return _parseHexColor(colorString);
    } else if (colorString.startsWith('rgb')) {
      return _parseRgbColor(colorString);
    } else if (_namedColors.containsKey(colorString.toLowerCase())) {
      return _namedColors[colorString.toLowerCase()]!;
    }

    return Colors.black;
  }

  static Color _parseHexColor(String hex) {
    hex = hex.substring(1);
    if (hex.length == 3) {
      hex = hex[0] + hex[0] + hex[1] + hex[1] + hex[2] + hex[2];
    }
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    return Colors.black;
  }

  static Color _parseRgbColor(String rgb) {
    final regex = RegExp(r'rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*[\d.]+)?\)');
    final match = regex.firstMatch(rgb);
    if (match != null) {
      final r = int.parse(match.group(1)!);
      final g = int.parse(match.group(2)!);
      final b = int.parse(match.group(3)!);
      return Color.fromARGB(255, r, g, b);
    }
    return Colors.black;
  }

  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2)}';
  }

  static const Map<String, Color> _namedColors = {
    'black': Colors.black,
    'white': Colors.white,
    'red': Colors.red,
    'green': Colors.green,
    'blue': Colors.blue,
    'yellow': Colors.yellow,
    'orange': Colors.orange,
    'purple': Colors.purple,
    'pink': Colors.pink,
    'brown': Colors.brown,
    'grey': Colors.grey,
    'gray': Colors.grey,
  };
}

class SvgParsingException implements Exception {
  final String message;
  SvgParsingException(this.message);
}
