import 'dart:developer';
import 'dart:io';

import 'package:first_app/device_info.dart';

import 'event.dart';
import 'dart:async';
import 'dart:convert';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'command.dart' as c;

sealed class DeviceConnection {
  Future<DeviceInfo> getDeviceInfo();
  Future<DeviceConfig> getDeviceConfig();

  Future<StateEvent> getLastState();
  Future<List<StateEvent>> getStateHistory(DateTime start, DateTime end);

  Stream<StateEvent> receiveEvents();

  Future<void> sendCommand(c.Command command);
}

class WSDeviceConnection implements DeviceConnection {
  final String _id;
  final String _url;
  final int _port;

  static const apiPath = "/api/v1";

  WSDeviceConnection(this._id, this._url, this._port);

  @override
  Future<DeviceInfo> getDeviceInfo() async {
    final path = "http://$_url:$_port$apiPath/device/$_id";
    final resp = await http.get(Uri.parse(path));
    final map = jsonDecode(resp.body) as Map<String, dynamic>;
    log(map.toString(), name: "WsDeviceConnection.getDeviceInfo");
    return DeviceInfo.fromJson(map);
  }

  @override
  Future<DeviceConfig> getDeviceConfig() async {
    final path = "http://$_url:$_port$apiPath/device/$_id/config";
    final resp = await http.get(Uri.parse(path));
    log(resp.toString(), name: "WsDeviceConnection.getDeviceConfig");
    final map = jsonDecode(resp.body) as Map<String, dynamic>;
    return DeviceConfig.fromJson(map);
  }

  @override
  Future<StateEvent> getLastState() async {
    final path = "http://$_url:$_port$apiPath/device/$_id/history/last";
    final resp = await http.get(Uri.parse(path));
    log(resp.toString(), name: "WsDeviceConnection.getLastState");
    final map = jsonDecode(resp.body) as Map<String, dynamic>;
    return StateEvent.fromJson(map);
  }

  @override
  Future<List<StateEvent>> getStateHistory(DateTime start, DateTime end) async {
    final path =
        "http://$_url:$_port$apiPath/device/$_id/history?from=${start.millisecondsSinceEpoch}&to=${end.millisecondsSinceEpoch}";
    final resp = await http.get(Uri.parse(path));
    log(resp.toString(), name: "WsDeviceConnection.getStateHistory");
    final list = jsonDecode(resp.body) as List<dynamic>;
    final list2 = list.map((e) => StateEvent.fromJson(e)).toList();
    return list2;
  }

  @override
  Stream<StateEvent> receiveEvents() {
    final wsUrl = Uri.parse("ws://$_url:$_port$apiPath/device/$_id/ws");
    var channel = WebSocketChannel.connect(wsUrl);

    return channel.stream.map((event) =>
        StateEvent.fromJson(jsonDecode(event) as Map<String, dynamic>));
  }

  @override
  Future<void> sendCommand(c.Command command) async {
    var path = "http://$_url:$_port$apiPath/device/$_id/command";

    // get command path suffix
    switch (command) {
      case c.ForceStateCommand():
        path += "/forceState";
        break;
    }

    final resp = await http.post(Uri.parse(path),
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        },
        body: jsonEncode(command.toJson()));
    if (resp.statusCode != 200) {
      throw Exception("Failed to send command");
    }
  }
}

class MockConnection implements DeviceConnection {
  late Stream<StateEvent> _eventStream;
  late StreamController<StateEvent> _propertyStream;

  final DeviceInfo _info = DeviceInfo(
      id: "0000000000000000",
      name: "MockDevice",
      token: "",
      type: 1,
      firmwareVersion: 1,
      lastSeen: DateTime.now(),
      baseline: 200);

  final DeviceConfig _config = DeviceConfig(
      waterlevelFillStart: 100,
      waterlevelFillEnd: 10,
      cleanBeforeFillDuration: 3000,
      cleanAfterFillDuration: 30000,
      leakProtection: false);

  Future<void> initCombinedStream() async {
    _propertyStream = StreamController<StateEvent>();
    Stream<StateEvent> periodicStream = Stream.periodic(
        const Duration(seconds: 1),
        (a) => StateEvent(
            time: DateTime.now(),
            filterState: State.idle,
            forcedTimeLeft: 0,
            lastStateChange: DateTime.now(),
            waterlevel: a,
            measurementError: false,
            measurementErrorOccured: DateTime.now(),
            measurementErrorCount: 0,
            leak: false,
            leakOccured: DateTime.now()));

    StreamGroup<StateEvent> streamGroup = StreamGroup();
    streamGroup
      ..add(_propertyStream.stream)
      ..add(periodicStream)
      ..close();
    _eventStream = streamGroup.stream;
  }

  @override
  Future<DeviceInfo> getDeviceInfo() async {
    return _info;
  }

  @override
  Future<DeviceConfig> getDeviceConfig() async {
    return _config;
  }

  @override
  Future<StateEvent> getLastState() async {
    return StateEvent(
        time: DateTime.now(),
        filterState: State.idle,
        forcedTimeLeft: 0,
        lastStateChange: DateTime.now(),
        waterlevel: 100,
        measurementError: false,
        measurementErrorOccured: DateTime.now(),
        measurementErrorCount: 0,
        leak: false,
        leakOccured: DateTime.now());
  }

  @override
  Stream<StateEvent> receiveEvents() {
    initCombinedStream();
    return _eventStream;
  }

  @override
  Future<List<StateEvent>> getStateHistory(DateTime start, DateTime end) async {
    return [
      StateEvent(
          time: DateTime.now(),
          filterState: State.idle,
          forcedTimeLeft: 0,
          lastStateChange: DateTime.now(),
          waterlevel: 10,
          measurementError: false,
          measurementErrorOccured: DateTime.now(),
          measurementErrorCount: 0,
          leak: false,
          leakOccured: DateTime.now()),
      StateEvent(
          time: DateTime.now().subtract(const Duration(minutes: 10)),
          filterState: State.idle,
          forcedTimeLeft: 0,
          lastStateChange: DateTime.now(),
          waterlevel: 20,
          measurementError: false,
          measurementErrorOccured: DateTime.now(),
          measurementErrorCount: 0,
          leak: false,
          leakOccured: DateTime.now()),
      StateEvent(
          time: DateTime.now().subtract(const Duration(minutes: 20)),
          filterState: State.idle,
          forcedTimeLeft: 0,
          lastStateChange: DateTime.now(),
          waterlevel: 30,
          measurementError: false,
          measurementErrorOccured: DateTime.now(),
          measurementErrorCount: 0,
          leak: false,
          leakOccured: DateTime.now()),
      StateEvent(
          time: DateTime.now().subtract(const Duration(minutes: 30)),
          filterState: State.idle,
          forcedTimeLeft: 0,
          lastStateChange: DateTime.now(),
          waterlevel: 40,
          measurementError: false,
          measurementErrorOccured: DateTime.now(),
          measurementErrorCount: 0,
          leak: false,
          leakOccured: DateTime.now()),
      StateEvent(
          time: DateTime.now().subtract(const Duration(minutes: 40)),
          filterState: State.idle,
          forcedTimeLeft: 0,
          lastStateChange: DateTime.now(),
          waterlevel: 30,
          measurementError: false,
          measurementErrorOccured: DateTime.now(),
          measurementErrorCount: 0,
          leak: false,
          leakOccured: DateTime.now())
    ];
  }

  @override
  Future<void> sendCommand(c.Command command) async {
    switch (command) {
      case c.ForceStateCommand():
        _propertyStream.add(StateEvent(
            time: DateTime.now(),
            filterState: State.idle,
            forcedTimeLeft: 0,
            lastStateChange: DateTime.now(),
            waterlevel: 100,
            measurementError: false,
            measurementErrorOccured: DateTime.now(),
            measurementErrorCount: 0,
            leak: false,
            leakOccured: DateTime.now()));
        break;
    }
  }
}
