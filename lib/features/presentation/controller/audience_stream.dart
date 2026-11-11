import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class AudienceStream {
  AudienceStream._(this._server, this._process, this._socket);

  final ServerSocket _server;
  final Process _process;
  final Socket _socket;

  static Future<AudienceStream> open({required Offset position}) async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    Process? process;
    try {
      final arguments = [
        '--churchlib-audience',
        '--churchlib-audience-port=${server.port}',
        '--churchlib-audience-x=${position.dx.round()}',
        '--churchlib-audience-y=${position.dy.round()}',
      ];
      process = await Process.start(Platform.resolvedExecutable, arguments);
      process.stdout.listen((_) {});
      process.stderr.listen((_) {});
      final socket = await server.first.timeout(const Duration(seconds: 10));
      return AudienceStream._(server, process, socket);
    } catch (_) {
      process?.kill();
      await server.close();
      rethrow;
    }
  }

  void send(Uint8List frame) {
    final header = ByteData(4)..setUint32(0, frame.length, Endian.big);
    _socket
      ..add(header.buffer.asUint8List())
      ..add(frame);
  }

  void close() {
    _socket.destroy();
    _server.close();
    _process.kill();
  }
}
