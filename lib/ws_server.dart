import 'dart:developer';

import 'package:first_app/Connection.dart';
import 'package:first_app/Device.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

sealed class Server {
  String name();
  String kind();
  bool connected();
  Future<List<String>> getDeviceIds();
  Device getDevice(String id);
}

class WSServer extends Server {
  final String _url;
  final int _port;
  String _auth_token;
  bool _connected = false;

  @override
  bool connected() => _connected;

  @override
  String kind() => "Http Server";

  @override
  String name() => _url;

  static const apiPath = "/api/v1";

  WSServer(this._url, this._port, this._auth_token);

  @override
  Future<List<String>> getDeviceIds() async {
    try {
      final path = "http://$_url:$_port$apiPath/device";
      final resp = await http.get(Uri.parse(path));
      final list = jsonDecode(resp.body) as List<dynamic>;
      _connected = true;
      return list.map((e) => e as String).toList();
    } catch (e) {
      log("could not connect to $_url:$_port", name: "WSServer.getDeviceIds");
      _connected = false;
      return [];
    }
  }

  @override
  Device getDevice(String id) {
    return Device(WSDeviceConnection(id, _url, _port), id);
  }
}

class MockServer extends Server {
  @override
  String name() => "MockServer";

  @override
  String kind() => "Mock";

  @override
  bool connected() => true;

  @override
  Future<List<String>> getDeviceIds() async {
    return ["mock"];
  }

  @override
  Device getDevice(String id) {
    return Device(MockConnection(), id);
  }
}
