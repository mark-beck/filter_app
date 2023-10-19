import 'package:first_app/DeviceManager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Device Manager is  singleton", () {
    var dm1 = DeviceManager();
    var dm2 = DeviceManager();
    expect(dm1, dm2);
  });

  test("Device Manager has at least one Device", () {
    expect(DeviceManager().getAllDevices().isNotEmpty, true);
  });
}