import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class AudienceFrameCapture {
  AudienceFrameCapture(this.onFrame);

  final ValueChanged<Uint8List> onFrame;
  final boundaryKey = GlobalKey();
  bool _disposed = false;

  Future<void> capture() async {
    final renderObject = boundaryKey.currentContext?.findRenderObject();
    if (renderObject is! RenderRepaintBoundary || !renderObject.hasSize) return;
    try {
      final image = await renderObject.toImage(pixelRatio: 1);
      final data = await image.toByteData(format: ImageByteFormat.png);
      image.dispose();
      if (data == null || _disposed) return;
      onFrame(
        Uint8List.fromList(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        ),
      );
    } catch (error) {
      debugPrint('Could not capture the presentation preview: $error');
    }
  }

  void dispose() => _disposed = true;
}
