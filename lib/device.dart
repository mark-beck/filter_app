import 'package:collection/collection.dart';
import 'package:first_app/device_info.dart';
import 'package:flutter/material.dart';

import 'connection.dart';
import 'event.dart';

class Device with ChangeNotifier {
  final DeviceConnection _connection;
  final PriorityQueue<StateEvent> _eventhistory = PriorityQueue(
    (a, b) => b.time.compareTo(a.time),
  );
  // final List<StateEvent> _eventhistory = [];
  String _id;
  String? _name;
  int? _baseline;
  DateTime? _oldestEventArrived;

  String get id => _id;
  String? get name => _name;
  int? get baseline => _baseline;

  Device(this._connection, this._id) {
    final info = _connection.getDeviceInfo();
    info.then((value) {
      _id = value.id;
      _name = value.name;
      _baseline = value.baseline;
      notifyListeners();
    });
    receiveEvents();
  }

  Future<List<StateEvent>> getStateEvents(DateTime start, DateTime end) async {
    final oldestTimeKnown = oldestEventLocal();

    if (oldestTimeKnown == null) {
      final oldEvents = await _connection.getStateHistory(start, end);
      _eventhistory.addAll(oldEvents);
      _oldestEventArrived = start;
    } else if (start.isBefore(oldestTimeKnown)) {
      final oldEvents =
          await _connection.getStateHistory(start, oldestTimeKnown);
      _eventhistory.addAll(oldEvents);
      _oldestEventArrived = start;
    }

    return _eventhistory
        .toList()
        .where((e) => e.time.isAfter(start) && e.time.isBefore(end))
        .toList();
  }

  DateTime? oldestEventLocal() {
    if (_eventhistory.isEmpty) {
      return null;
    }
    return _oldestEventArrived ??
        _eventhistory.toList().map((e) => e.time).reduce(
            (DateTime value, element) =>
                (value.isBefore(element) ? value : element));
  }

  Future<DeviceConfig> deviceConfig() {
    return _connection.getDeviceConfig();
  }

  Future<StateEvent> currentState() async {
    if (_eventhistory.isEmpty) {
      return await _connection.getLastState();
    }
    return _eventhistory.first;
  }

  void receiveEvents() async {
    await for (final StateEvent event in _connection.receiveEvents()) {
      _eventhistory.add(event);
      notifyListeners();
    }
  }
}
