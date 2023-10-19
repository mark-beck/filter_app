import 'Event.dart';
import 'dart:async';
import 'package:async/async.dart';

sealed class Connection {
  Future<void> getInfo(Property prop);

  Stream<Event> receiveEvents();
}

// class BTConnection implements Connection {}
// class WSConnection implements Connection {}
class MockConnection implements Connection {
  late Stream<Event> _eventStream;
  late StreamController<Event> _propertyStream;

  Future<void> initCombinedStream() async {
    _propertyStream = StreamController<Event>();
    Stream<Event> periodicStream = Stream.periodic(const Duration(seconds: 1), (a) => WaterlevelEvent(a));

    StreamGroup<Event> streamGroup = StreamGroup();
    streamGroup
      ..add(_propertyStream.stream)
      ..add(periodicStream)
      ..close();
    _eventStream = streamGroup.stream;
  }

  @override
  Future<void> getInfo(Property prop) async {
    var event = switch (prop) {
      Property.name => NameEvent("Mock Device"),
      Property.state => StateEvent(State.waiting, 0),
      Property.waterlevel => WaterlevelEvent(10),
      Property.leak => LeakEvent(false),
    };
    _propertyStream.add(event);
  }

  @override
  Stream<Event> receiveEvents() {
    initCombinedStream();
    return _eventStream;
  }
}
