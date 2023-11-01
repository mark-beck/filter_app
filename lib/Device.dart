import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'Connection.dart';
import 'Event.dart';

class Device with ChangeNotifier {
  final DeviceConnection _connection;
  final PriorityQueue<StateEvent> _eventhistory = PriorityQueue(
    (a, b) => b.time.compareTo(a.time),
  );
  String _id;
  String? _name;

  String? get id => _id;
  String? get name => _name;

  Device(this._connection, this._id) {
    final info = _connection.getDeviceInfo();
    info.then((value) {
      _id = value.id;
      _name = value.name;
      notifyListeners();
    });
    receiveEvents();
  }

  StateEvent currentState() {
    return _eventhistory.first;
  }

  void receiveEvents() async {
    await for (final StateEvent event in _connection.receiveEvents()) {
      _eventhistory.add(event);
      notifyListeners();
    }
  }
}
