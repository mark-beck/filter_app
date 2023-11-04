sealed class Command {
  Map<String, dynamic> toJson();
}

class ForceStateCommand extends Command {
  final State state;
  final int time;

  ForceStateCommand(this.state, this.time);

  @override
  Map<String, dynamic> toJson() => {
        'state': state.toString().split('.').last,
        'time': time,
      };
}

enum State { clean, fill, idle }
