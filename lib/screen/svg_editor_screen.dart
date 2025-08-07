import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:svg_editor/chat_app/chat_app.dart';
import 'package:svg_editor/screen/widgets/svg_header_widget.dart';
import 'package:svg_editor/screen/widgets/svg_layer_panel.dart';
import 'package:svg_editor/screen/widgets/svg_preview_widget.dart';

import '../service/svg_editor_service.dart';

class SvgEditorScreen extends StatelessWidget {
  const SvgEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SVG Color Editor'),
        actions: [
          Consumer<SvgEditorProvider>(
            builder: (context, provider, child) {
              if (provider.hasSvg) {
                return IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: provider.saveSvgFile,
                  tooltip: 'Save SVG',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8EAF6), Colors.white],
          ),
        ),
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ChatApp())),
                child: Text("Chat App")),
            const SvgHeaderWidget(),
            const SvgPreviewWidget(),
            const Expanded(child: SvgLayersPanel()),
          ],
        ),
      ),
    );
  }
}
