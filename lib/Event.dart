sealed class Event {}

class StateEvent extends Event {
  final String id;
  final DateTime time;
  final State filter_state;
  final int forced_time_left;
  final DateTime last_state_change;
  final int waterlevel;
  final bool measurement_error;
  final DateTime measurement_error_occured;
  final int measurement_error_count;
  final bool leak;
  final DateTime leak_occured;

  StateEvent({
    required this.id,
    required this.time,
    required this.filter_state,
    required this.forced_time_left,
    required this.last_state_change,
    required this.waterlevel,
    required this.measurement_error,
    required this.measurement_error_occured,
    required this.measurement_error_count,
    required this.leak,
    required this.leak_occured,
  });

  StateEvent.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        time = DateTime.fromMillisecondsSinceEpoch(json['time']),
        filter_state = stateFromString(json['filter_state']),
        forced_time_left = json['forced_time_left'] ?? 0,
        last_state_change =
            DateTime.fromMillisecondsSinceEpoch(json['last_state_change']),
        waterlevel = json['waterlevel'],
        measurement_error = json['measurement_error'],
        measurement_error_occured = DateTime.fromMillisecondsSinceEpoch(
            json['measurement_error_occured']),
        measurement_error_count = json['measurement_error_count'],
        leak = json['leak'],
        leak_occured =
            DateTime.fromMillisecondsSinceEpoch(json['leak_occured']);
}

enum State {
  idle,
  cleanBeforeFill,
  cleanAfterFill,
  fill,
  forcedIdle,
  forcedClean,
  forcedFill
}

State stateFromString(String str) {
  switch (str) {
    case "idle":
      return State.idle;
    case "cleanBeforeFill":
      return State.cleanBeforeFill;
    case "cleanAfterFill":
      return State.cleanAfterFill;
    case "fill":
      return State.fill;
    case "forcedIdle":
      return State.forcedIdle;
    case "forcedClean":
      return State.forcedClean;
    case "forcedFill":
      return State.forcedFill;
    default:
      throw Exception("Unknown state: $str");
  }
}
