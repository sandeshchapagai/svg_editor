import 'package:flutter/material.dart';
import 'package:svg_editor/service/parse_service.dart';
import 'package:xml/xml.dart';

import '../providers/svg_editor_provider.dart';
import 'file_service.dart';

enum SvgEditorState {
  initial,
  loading,
  loaded,
  error,
}

class SvgEditorProvider extends ChangeNotifier {
  // Private fields
  XmlDocument? _svgDocument;
  String? _svgString;
  List<SvgLayer> _layers = [];
  SvgEditorState _state = SvgEditorState.initial;
  String? _errorMessage;
  String? _fileName;

  // Getters
  XmlDocument? get svgDocument => _svgDocument;
  String? get svgString => _svgString;
  List<SvgLayer> get layers => List.unmodifiable(_layers);
  SvgEditorState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get fileName => _fileName;
  bool get hasLayers => _layers.isNotEmpty;
  bool get hasSvg => _svgString != null;
  int get layersCount => _layers.length;
  int get visibleLayersCount => _layers.where((l) => l.isVisible).length;

  // Public methods
  Future<void> loadSvgFile() async {
    _setState(SvgEditorState.loading);

    try {
      final content = await FileService.pickSvgFile();
      if (content != null) {
        await _processSvg(content);
        _setState(SvgEditorState.loaded);
      } else {
        _setState(SvgEditorState.initial);
      }
    } catch (e) {
      _setError('Failed to load SVG file: $e');
    }
  }

  Future<void> saveSvgFile() async {
    if (_svgString == null) return;

    try {
      final fileName = _fileName ?? 'edited_svg.svg';
      await FileService.saveSvgFile(_svgString!, fileName);
    } catch (e) {
      _setError('Failed to save SVG file: $e');
    }
  }

  void updateLayerColor(SvgLayer layer, Color newColor) {
    final layerIndex = _layers.indexWhere((l) => l.index == layer.index);
    if (layerIndex == -1) return;

    // Update the layer model
    _layers[layerIndex] = layer.copyWith(color: newColor);

    // Update the XML element
    SvgParserService.updateLayerColor(_layers[layerIndex], newColor);

    // Regenerate SVG string
    _regenerateSvgString();
    notifyListeners();
  }

  void toggleLayerVisibility(SvgLayer layer) {
    final layerIndex = _layers.indexWhere((l) => l.index == layer.index);
    if (layerIndex == -1) return;

    final updatedLayer = _layers[layerIndex].copyWith(
      isVisible: !_layers[layerIndex].isVisible,
    );
    _layers[layerIndex] = updatedLayer;

    // Update the XML element
    SvgParserService.toggleLayerVisibility(updatedLayer);

    // Regenerate SVG string
    _regenerateSvgString();
    notifyListeners();
  }

  void resetAllLayers() {
    for (int i = 0; i < _layers.length; i++) {
      if (!_layers[i].isVisible) {
        _layers[i] = _layers[i].copyWith(isVisible: true);
        _layers[i].element.removeAttribute('display');
      }
    }
    _regenerateSvgString();
    notifyListeners();
  }

  void clearSvg() {
    _svgDocument = null;
    _svgString = null;
    _layers.clear();
    _fileName = null;
    _errorMessage = null;
    _setState(SvgEditorState.initial);
  }

  // Private methods
  void _setState(SvgEditorState newState) {
    _state = newState;
    if (newState != SvgEditorState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _setState(SvgEditorState.error);
  }

  Future<void> _processSvg(String content) async {
    try {
      _svgDocument = SvgParserService.parseSvg(content);
      _svgString = content;
      _layers = SvgParserService.extractLayers(_svgDocument!);
      _fileName = 'imported_svg.svg';
    } catch (e) {
      throw Exception('Error processing SVG: $e');
    }
  }

  void _regenerateSvgString() {
    if (_svgDocument != null) {
      _svgString = _svgDocument!.toXmlString();
    }
  }
}
