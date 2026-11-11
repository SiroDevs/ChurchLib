import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

bool runAudienceReceiver(List<String> arguments) {
  if (!arguments.contains('--churchlib-audience')) return false;
  final portValue = _argumentValue(arguments, '--churchlib-audience-port=');
  final port = int.tryParse(portValue ?? '');
  if (port == null) return false;
  WidgetsFlutterBinding.ensureInitialized();
  runApp(_AudienceReceiverApp(port: port));
  return true;
}

String? _argumentValue(List<String> arguments, String prefix) {
  for (final argument in arguments) {
    if (argument.startsWith(prefix)) return argument.substring(prefix.length);
  }
  return null;
}

class _AudienceReceiverApp extends StatefulWidget {
  const _AudienceReceiverApp({required this.port});

  final int port;

  @override
  State<_AudienceReceiverApp> createState() => _AudienceReceiverAppState();
}

class _AudienceReceiverAppState extends State<_AudienceReceiverApp> {
  Socket? _socket;
  Uint8List _pending = Uint8List(0);
  Uint8List? _frame;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    try {
      final socket = await Socket.connect(
        InternetAddress.loopbackIPv4,
        widget.port,
      );
      _socket = socket;
      socket.listen(
        _receive,
        onDone: _closeReceiver,
        onError: (_) => _closeReceiver(),
      );
    } catch (_) {
      if (mounted) setState(() => _frame = null);
    }
  }

  void _closeReceiver() {
    _socket?.destroy();
    if (mounted) SystemNavigator.pop();
  }

  void _receive(List<int> chunk) {
    _pending = Uint8List.fromList([..._pending, ...chunk]);
    while (_pending.length >= 4) {
      final frameLength = ByteData.sublistView(
        _pending,
        0,
        4,
      ).getUint32(0, Endian.big);
      if (_pending.length < frameLength + 4) return;
      final frame = Uint8List.sublistView(_pending, 4, frameLength + 4);
      _pending = Uint8List.sublistView(_pending, frameLength + 4);
      if (mounted) setState(() => _frame = frame);
    }
  }

  @override
  void dispose() {
    _socket?.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ColoredBox(
      color: Colors.black,
      child: SizedBox.expand(
        child: _frame == null
            ? const SizedBox.shrink()
            : Image.memory(_frame!, fit: BoxFit.fill, gaplessPlayback: true),
      ),
    ),
  );
}
