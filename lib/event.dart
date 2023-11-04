sealed class Event {}

class StateEvent extends Event {
  final DateTime time;
  final State filterState;
  final int forcedTimeLeft;
  final DateTime lastStateChange;
  final int waterlevel;
  final bool measurementError;
  final DateTime measurementErrorOccured;
  final int measurementErrorCount;
  final bool leak;
  final DateTime leakOccured;

  StateEvent({
    required this.time,
    required this.filterState,
    required this.forcedTimeLeft,
    required this.lastStateChange,
    required this.waterlevel,
    required this.measurementError,
    required this.measurementErrorOccured,
    required this.measurementErrorCount,
    required this.leak,
    required this.leakOccured,
  });

  StateEvent.fromJson(Map<String, dynamic> json)
      : time = DateTime.fromMillisecondsSinceEpoch(json['time']),
        filterState = stateFromString(json['filter_state']),
        forcedTimeLeft = (json['forced_time_left'] ?? 0),
        lastStateChange =
            DateTime.fromMillisecondsSinceEpoch(json['last_state_change']),
        waterlevel = json['waterlevel'],
        measurementError = json['measurement_error'],
        measurementErrorOccured = DateTime.fromMillisecondsSinceEpoch(
            json['measurement_error_occured']),
        measurementErrorCount = json['measurement_error_count'],
        leak = json['leak'],
        leakOccured =
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
