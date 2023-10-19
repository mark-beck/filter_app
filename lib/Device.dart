import 'package:fluent_ui/fluent_ui.dart' as fl;

import 'Connection.dart';
import 'Event.dart';

class Device with fl.ChangeNotifier {
  final Connection _connection;
  final List<int> _waterhistory = [];
  State? _state;
  String? _name;
  bool _leak = false;

  Device(this._connection) {
    print("mock initiated");
    receiveEvents();
    _connection.getInfo(Property.name);
    _connection.getInfo(Property.state);
    _connection.getInfo(Property.leak);
  }
  
  String? get name => _name;
  State? get state => _state;
  int? get waterlevel {
    if (_waterhistory.isEmpty) {
      return null;
    } else {
      return _waterhistory.last;
    }
  }
  bool get leak => _leak;

  void receiveEvents() async {
    await for (final event in _connection.receiveEvents()) {
      switch (event) {
        case NameEvent(name: var name):
          _name = name;
        case WaterlevelEvent(waterlevel: var waterlevel):
          _waterhistory.add(waterlevel);
        case StateEvent(state: var state):
          _state = state;
        case LeakEvent(leak: var leak):
          _leak = leak;
      }
      notifyListeners();
    }
  }
}
