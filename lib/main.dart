import 'package:first_app/Device.dart';
import 'package:first_app/DeviceManager.dart';
import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fl;

void main() {
  DeviceManager.init();
  runApp(const MyApp());
}

class MyApp extends fl.StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return fl.FluentApp(
      title: 'Flutter Demo',
      theme: fl.FluentThemeData(),
      home: const FlNavBar(title: "App"),
    );
  }
}

class MyHomePage extends fl.StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends fl.State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class FlNavBar extends fl.StatefulWidget {
  const FlNavBar({super.key, required this.title});

  final String title;

  @override
  State<FlNavBar> createState() => _FlNavbarState();
}

class _FlNavbarState extends fl.State<FlNavBar> {
  int topIndex = 0;

  List<fl.NavigationPaneItem> items = [
    fl.PaneItem(
      icon: const Icon(fl.FluentIcons.home),
      title: const Text('Home'),
      body: const MyHomePage(title: "home"),
    ),
    fl.PaneItemSeparator(),
    fl.PaneItem(
      icon: const Icon(fl.FluentIcons.connect_virtual_machine),
      title: const Text('connections'),
      body: Container(
        color: Colors.green,
        alignment: Alignment.center,
        child: const Text('Connections'),
      ),
    ),
    fl.PaneItemExpander(
      icon: const Icon(fl.FluentIcons.add_phone),
      title: const Text("Devices"),
      body: const Text("List of all Devices"),
      items: DeviceManager()
          .getAllDevices()
          .map((Device dev) => fl.PaneItem(
              icon: const Icon(fl.FluentIcons.decimals),
              title: Text(dev.name ?? "Unknown"),
              body: DebugView(device: dev)))
          .toList(),
    )
  ];

  @override
  Widget build(BuildContext context) {
    return fl.NavigationView(
      appBar: const fl.NavigationAppBar(
        title: Text('NavigationView'),
      ),
      pane: fl.NavigationPane(
        selected: topIndex,
        onChanged: (index) => setState(() => topIndex = index),
        displayMode: fl.PaneDisplayMode.compact,
        items: items,
      ),
    );
  }
}

class DebugView extends fl.StatefulWidget {
  final Device device;

  const DebugView({required this.device, super.key});

  @override
  State<StatefulWidget> createState() => DebugViewState();
}

class DebugViewState extends fl.State<DebugView> {
  @override
  Widget build(BuildContext context) {
    return fl.ListenableBuilder(
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
              DataCell(Text("Name")),
              DataCell(Text(widget.device.name ?? "N/A")),
            ]),
            DataRow(cells: [
              DataCell(Text("Waterlevel")),
              DataCell(Text(widget.device.waterlevel?.toString() ?? "N/A")),
            ]),
            DataRow(cells: [
              DataCell(Text("Waterleak")),
              DataCell(Text(widget.device.leak.toString())),
            ]),
            DataRow(cells: [
              DataCell(Text("State")),
              DataCell(Text(widget.device.state?.toString() ?? "N/A")),
            ]),
          ]);
        });
  }
}
