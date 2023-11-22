import 'package:first_app/connection.dart';
import 'package:first_app/device.dart';
import 'package:first_app/ws_server.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final mock = MockConnection(sendEvent: false);

  test("getStateEvents", () async {
    final device = Device(mock, "0000000000000000");

    final bareEvents =
        await mock.getStateHistory(DateTime.now(), DateTime.now());

    expect(
        (await device.getStateEvents(
                DateTime.now().subtract(Duration(hours: 1)), DateTime.now()))
            .length,
        bareEvents.length);
    expect(
        (await device.getStateEvents(
                DateTime.now().subtract(Duration(minutes: 39)), DateTime.now()))
            .length,
        bareEvents.length - 1);
    expect(
        (await device.getStateEvents(
                DateTime.now().subtract(Duration(minutes: 29)), DateTime.now()))
            .length,
        bareEvents.length - 2);
    expect(
        (await device.getStateEvents(
                DateTime.now().subtract(Duration(minutes: 19)), DateTime.now()))
            .length,
        bareEvents.length - 3);
    expect(
        (await device.getStateEvents(
                DateTime.now().subtract(Duration(minutes: 9)), DateTime.now()))
            .length,
        bareEvents.length - 4);
    expect((await device.getStateEvents(DateTime.now(), DateTime.now())).length,
        0);
  });
}
