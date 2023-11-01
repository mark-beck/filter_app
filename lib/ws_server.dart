import 'package:first_app/Connection.dart';
import 'package:first_app/Device.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

sealed class Server {
  String name();
  Future<List<String>> getDeviceIds();
  Device getDevice(String id);
}

class WSServer extends Server {
  final String _url;
  final int _port;
  String _auth_token;

  static const apiPath = "/api/v1";

  WSServer(this._url, this._port, this._auth_token);

  @override
  String name() {
    return _url;
  }

  @override
  Future<List<String>> getDeviceIds() async {
    final path = "http://$_url:$_port$apiPath/device";
    final resp = await http.get(Uri.parse(path));
    final list = jsonDecode(resp.body) as List<dynamic>;
    return list.map((e) => e as String).toList();
  }

  @override
  Device getDevice(String id) {
    return Device(WSDeviceConnection(id, _url, _port), id);
  }
}

class MockServer extends Server {
  @override
  String name() {
    return "MockServer";
  }

  @override
  Future<List<String>> getDeviceIds() async {
    return ["mock"];
  }

  @override
  Device getDevice(String id) {
    return Device(MockConnection(), id);
  }
}
