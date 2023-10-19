
import 'package:first_app/Connection.dart';

import 'Device.dart';

class DeviceManager {
  static DeviceManager? _cache;
  Device _mockDevice = Device(MockConnection());
  List<Device> _devices = [];

  factory DeviceManager() {
    if (_cache != null) {
      return _cache!;
    }
    init();
    return _cache!;
  }

  DeviceManager._create();

  static void init() {
    _cache = DeviceManager._create();
  }

  Device get mockdevice => _mockDevice;

  List<Device> getAllDevices() {
    List<Device> res = List.from(_devices);
    res.add(_mockDevice);
    return res;
  }
}