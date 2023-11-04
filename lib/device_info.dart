class DeviceInfo {
  String id;
  String? name;
  String token;
  num type;
  num firmwareVersion;
  DateTime lastSeen;
  int? baseline;

  DeviceInfo({
    required this.id,
    required this.name,
    required this.token,
    required this.type,
    required this.firmwareVersion,
    required this.lastSeen,
    required this.baseline,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      id: json['id'],
      name: json['name'],
      token: json['token'],
      type: json['type'],
      firmwareVersion: json['firmware_version'],
      lastSeen: DateTime.fromMillisecondsSinceEpoch(json['last_seen']),
      baseline: json['baseline'],
    );
  }
}

class DeviceConfig {
  int waterlevelFillStart;
  int waterlevelFillEnd;
  int cleanBeforeFillDuration;
  int cleanAfterFillDuration;
  bool leakProtection;

  DeviceConfig({
    required this.waterlevelFillStart,
    required this.waterlevelFillEnd,
    required this.cleanBeforeFillDuration,
    required this.cleanAfterFillDuration,
    required this.leakProtection,
  });

  factory DeviceConfig.fromJson(Map<String, dynamic> json) {
    return DeviceConfig(
      waterlevelFillStart: json['waterlevelFillStart'],
      waterlevelFillEnd: json['waterlevelFillEnd'],
      cleanBeforeFillDuration: json['cleanBeforeFillDuration'],
      cleanAfterFillDuration: json['cleanAfterFillDuration'],
      leakProtection: json['leakProtection'],
    );
  }
}
