import 'dart:async';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectionService {
  static final ConnectionService _instance = ConnectionService._internal();
  factory ConnectionService() => _instance;
  ConnectionService._internal();

  final InternetConnectionChecker _checker =
      InternetConnectionChecker.createInstance(
        checkInterval: const Duration(seconds: 1),
        checkTimeout: const Duration(seconds: 3),
        slowConnectionConfig: SlowConnectionConfig(
          enableToCheckForSlowConnection: true,
          slowConnectionThreshold: Duration(seconds: 5),
        ),
      );
  StreamController<bool>? _controller;

  Stream<bool> get onStatusChange {
    _controller ??= StreamController<bool>.broadcast();
    _checker.onStatusChange.listen((status) {
      _controller?.add(status == InternetConnectionStatus.connected);
    });
    return _controller!.stream;
  }

  Future<bool> get isConnected async => await _checker.hasConnection;

  void dispose() {
    _controller?.close();
    _controller = null;
  }
}
