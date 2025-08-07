import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../service/svg_editor_service.dart';

class SvgHeaderWidget extends StatelessWidget {
  const SvgHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Consumer<SvgEditorProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: provider.state == SvgEditorState.loading
                        ? null
                        : provider.loadSvgFile,
                    icon: const Icon(Icons.file_upload),
                    label: const Text('Import SVG'),
                  ),
                  if (provider.hasSvg) ...[
                    ElevatedButton.icon(
                      onPressed: provider.clearSvg,
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ],
              ),
              if (provider.state == SvgEditorState.loading) ...[
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
                const SizedBox(height: 8),
                const Text('Loading SVG...'),
              ],
              if (provider.hasLayers) ...[
                const SizedBox(height: 16),
                _buildStatsRow(provider),
              ],
              if (provider.state == SvgEditorState.error) ...[
                const SizedBox(height: 16),
                _buildErrorMessage(provider.errorMessage!),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsRow(SvgEditorProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.deepPurple.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.layers, color: Colors.deepPurple.shade600, size: 16),
          const SizedBox(width: 8),
          Text(
            '${provider.layersCount} layers • ${provider.visibleLayersCount} visible',
            style: TextStyle(
              color: Colors.deepPurple.shade600,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
