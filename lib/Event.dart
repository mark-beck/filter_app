sealed class Event {}

class NameEvent implements Event {
  final String name;

  NameEvent(this.name);
}

class WaterlevelEvent implements Event {
  final int waterlevel;

  WaterlevelEvent(this.waterlevel);
}

class StateEvent implements Event {
  final State state;
  final int timeleft;

  StateEvent(this.state, this.timeleft);
}

class LeakEvent implements Event {
  final bool leak;

  LeakEvent(this.leak);
}

enum State { waiting, filling, cleaning }

enum Property { name, waterlevel, leak, state }
