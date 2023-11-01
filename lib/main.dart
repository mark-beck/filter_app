import 'dart:ui';

import 'package:adwaita/adwaita.dart';
import 'package:first_app/Device.dart';
import 'package:first_app/DeviceManager.dart';
import 'package:flutter/material.dart';

void main() {
  DeviceManager.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Filter Device Manager',
        theme: AdwaitaThemeData.dark(),
        darkTheme: AdwaitaThemeData.dark(),
        debugShowCheckedModeBanner: false,
        home: ListenableBuilder(
          listenable: DeviceManager(),
          builder: (BuildContext context, Widget? child) {
            return DeviceMainList(title: "App", deviceManager: DeviceManager());
          },
        ));
  }
}

class BottomBar extends StatelessWidget {
  const BottomBar({super.key, required this.deviceManager});

  final DeviceManager deviceManager;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      child: Row(
        children: <Widget>[
          IconButton(
            tooltip: 'Return',
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
          IconButton(
            tooltip: 'Servers',
            icon: const Icon(Icons.cable),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ServerView(deviceManager: deviceManager)));
            },
          ),
        ],
      ),
    );
  }
}

class BottomBarServers extends StatelessWidget {
  const BottomBarServers({super.key, required this.deviceManager});

  final DeviceManager deviceManager;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      child: Row(
        children: <Widget>[
          IconButton(
            tooltip: 'Return',
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}

class ServerView extends StatelessWidget {
  const ServerView({super.key, required this.deviceManager});

  final DeviceManager deviceManager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomBarServers(deviceManager: deviceManager),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          physics: const BouncingScrollPhysics(),
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad
          },
        ),
        child: RefreshIndicator(
          onRefresh: deviceManager.reload,
          child: ListenableBuilder(
              listenable: deviceManager,
              builder: (BuildContext context, Widget? child) {
                return ListView.builder(
                    itemCount: deviceManager.getAllServers().length,
                    itemBuilder: (context, index) {
                      final item = deviceManager.getAllServers()[index];
                      return ListTile(
                        textColor: item.connected() ? null : Colors.red,
                        title: Text(item.name()),
                        subtitle: Text(item.kind()),
                        onTap: () {},
                      );
                    });
              }),
        ),
      ),
    );
  }
}

class DeviceMainList extends StatefulWidget {
  const DeviceMainList(
      {super.key, required this.title, required this.deviceManager});

  final String title;
  final DeviceManager deviceManager;

  @override
  State<DeviceMainList> createState() => _DeviceMainListState();
}

class _DeviceMainListState extends State<DeviceMainList> {
  int topIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomBar(deviceManager: widget.deviceManager),
      body: Container(
        alignment: Alignment.center,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            physics: const BouncingScrollPhysics(),
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
            },
          ),
          child: RefreshIndicator(
            onRefresh: widget.deviceManager.reload,
            child: DeviceList(
              deviceManager: widget.deviceManager,
            ),
          ),
        ),
      ),
    );
  }
}

class DeviceList extends StatelessWidget {
  const DeviceList({super.key, required this.deviceManager});

  final DeviceManager deviceManager;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: deviceManager,
        builder: (BuildContext context, Widget? child) {
          return ListView.builder(
              itemCount: deviceManager.getAllDevices().length,
              itemBuilder: (context, index) {
                final item = deviceManager.getAllDevices()[index];
                return ListTile(
                  title: Text(item.name ?? "Unknown"),
                  subtitle: Text(item.id ?? "what?"),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DeviceView(device: item)));
                  },
                );
              });
        });
  }
}

class DeviceView extends StatefulWidget {
  final Device device;

  const DeviceView({required this.device, super.key});

  @override
  State<StatefulWidget> createState() => DeviceViewState();
}

class DeviceViewState extends State<DeviceView> {
  int topIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomBar(deviceManager: DeviceManager()),
      body: Container(
          alignment: Alignment.center, child: DebugView(device: widget.device)),
    );
  }
}

class DebugView extends StatefulWidget {
  final Device device;

  const DebugView({required this.device, super.key});

  @override
  State<StatefulWidget> createState() => DebugViewState();
}

class DebugViewState extends State<DebugView> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: widget.device,
        builder: (BuildContext context, Widget? child) {
          return DataTable(columns: const [
            DataColumn(
              label: Expanded(
                child: Text(
                  'Measurement',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Value',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ], rows: [
            DataRow(cells: [
              const DataCell(Text("Name")),
              DataCell(Text(widget.device.name ?? "N/A")),
            ]),
            DataRow(cells: [
              const DataCell(Text("Waterlevel")),
              DataCell(
                  Text(widget.device.currentState().waterlevel.toString())),
            ]),
            DataRow(cells: [
              const DataCell(Text("Waterleak")),
              DataCell(Text(widget.device.currentState().leak.toString())),
            ]),
            DataRow(cells: [
              const DataCell(Text("State")),
              DataCell(
                  Text(widget.device.currentState().filter_state.toString())),
            ]),
          ]);
        });
  }
}
