import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

import '../../providers/svg_editor_provider.dart';
import '../../service/svg_editor_service.dart';

class LayerItemWidget extends StatelessWidget {
  final SvgLayer layer;
  final int index;

  const LayerItemWidget({
    super.key,
    required this.layer,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: layer.isVisible ? Colors.grey.shade200 : Colors.grey.shade400,
        ),
      ),
      child: ListTile(
        leading: _buildColorCircle(),
        title: Text(
          '${layer.tagName} ${index + 1}',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: layer.isVisible ? Colors.black : Colors.grey.shade600,
          ),
        ),
        subtitle: Text(
          layer.id.isNotEmpty ? 'ID: ${layer.id}' : 'No ID',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        trailing: _buildActionButtons(context),
      ),
    );
  }

  Widget _buildColorCircle() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: layer.isVisible ? layer.color : Colors.grey.shade300,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.grey.shade400,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: layer.isVisible
          ? null
          : Icon(
              Icons.visibility_off,
              size: 16,
              color: Colors.grey.shade600,
            ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            layer.isVisible ? Icons.visibility : Icons.visibility_off,
            color: layer.isVisible ? Colors.blue : Colors.grey,
            size: 20,
          ),
          onPressed: () {
            context.read<SvgEditorProvider>().toggleLayerVisibility(layer);
          },
          tooltip: layer.isVisible ? 'Hide layer' : 'Show layer',
        ),
        IconButton(
          icon: const Icon(
            Icons.color_lens,
            color: Colors.deepPurple,
            size: 20,
          ),
          onPressed: layer.isVisible ? () => _showColorPicker(context) : null,
          tooltip: 'Change color',
        ),
      ],
    );
  }

  void _showColorPicker(BuildContext context) {
    Color pickerColor = layer.color;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Pick color for ${layer.tagName}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        contentPadding: const EdgeInsets.all(20),
        content: SizedBox(
          width: 300,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Current vs New Color Preview
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: layer.color,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Current',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      const Icon(Icons.arrow_forward, color: Colors.grey),
                      const SizedBox(width: 20),
                      Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: pickerColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'New',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ColorPicker(
                  pickerColor: pickerColor,
                  onColorChanged: (color) {
                    pickerColor = color;
                  },
                  labelTypes: const [ColorLabelType.hex],
                  pickerAreaHeightPercent: 0.8,
                  displayThumbColor: true,
                  paletteType: PaletteType.hsvWithHue,
                  enableAlpha: false,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context
                  .read<SvgEditorProvider>()
                  .updateLayerColor(layer, pickerColor);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Apply',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
