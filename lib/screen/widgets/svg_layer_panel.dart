import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../service/svg_editor_service.dart';
import 'item_layer.dart';

class SvgLayersPanel extends StatelessWidget {
  const SvgLayersPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SvgEditorProvider>(
      builder: (context, provider, child) {
        if (!provider.hasLayers) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(provider),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: provider.layers.length,
                  itemBuilder: (context, index) {
                    return LayerItemWidget(
                      layer: provider.layers[index],
                      index: index,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(SvgEditorProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.layers,
            color: Colors.deepPurple.shade600,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Layers (${provider.layersCount})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (provider.visibleLayersCount < provider.layersCount)
            TextButton.icon(
              onPressed: provider.resetAllLayers,
              icon: const Icon(Icons.visibility, size: 16),
              label: const Text('Show All'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
        ],
      ),
    );
  }
}
