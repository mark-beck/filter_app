import 'dart:developer';

import 'package:flutter/material.dart';

import 'Device.dart';
import 'ws_server.dart';

class DeviceManager with ChangeNotifier {
  static DeviceManager? _cache;

  List<Device> _devices = [];
  List<Server> _servers = [];

  factory DeviceManager() {
    if (_cache != null) {
      return _cache!;
    }
    init();
    return _cache!;
  }

  Future<void> loadServerDevices(Server server) async {
    final ids = await server.getDeviceIds();
    for (final id in ids) {
      _devices.add(server.getDevice(id));
    }
  }

  DeviceManager._create() {
    addServer(MockServer());
    addServer(WSServer("192.168.122.1", 4000, ""));
  }

  static void init() {
    _cache = DeviceManager._create();
  }

  List<Device> getAllDevices() {
    return List.from(_devices);
  }

  List<Server> getAllServers() {
    return List.from(_servers);
  }

  void addServer(Server server) {
    _servers.add(server);
    loadServerDevices(server).then((value) => notifyListeners());
  }
}
