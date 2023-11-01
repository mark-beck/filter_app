import 'package:first_app/Device.dart';
import 'package:first_app/DeviceManager.dart';
import 'package:flutter/material.dart';
import 'package:adwaita/adwaita.dart';

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
        theme: AdwaitaThemeData.light(),
        darkTheme: AdwaitaThemeData.dark(),
        debugShowCheckedModeBanner: false,
        home: ListenableBuilder(
          listenable: DeviceManager(),
          builder: (BuildContext context, Widget? child) {
            return FlNavBar(title: "App", deviceManager: DeviceManager());
          },
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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

class FlNavBar extends StatefulWidget {
  const FlNavBar({super.key, required this.title, required this.deviceManager});

  final String title;
  final DeviceManager deviceManager;

  @override
  State<FlNavBar> createState() => _FlNavbarState();
}

class _FlNavbarState extends State<FlNavBar> {
  int topIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            topIndex = index;
          });
        },
        indicatorColor: Colors.amber[800],
        selectedIndex: topIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Devices',
          ),
          NavigationDestination(
            icon: Icon(Icons.business),
            label: 'Servers',
          ),
        ],
      ),
      body: <Widget>[
        Container(
            alignment: Alignment.center,
            child: DeviceList(
              deviceManager: DeviceManager(),
            )),
        Container(
          color: Colors.green,
          alignment: Alignment.center,
          child: const Text('Page 2'),
        ),
      ][topIndex],
    );
  }
}

class DeviceList extends StatelessWidget {
  DeviceList({super.key, required this.deviceManager});

  DeviceManager deviceManager;

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
      appBar: AppBar(
        title: const Text('AppBar Demo'),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            topIndex = index;
          });
        },
        indicatorColor: Colors.amber[800],
        selectedIndex: topIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Debug',
          ),
          NavigationDestination(
            icon: Icon(Icons.business),
            label: 'Other Stuff',
          ),
        ],
      ),
      body: [
        Container(
            alignment: Alignment.center,
            child: DebugView(device: widget.device)),
        Container(
          color: Colors.green,
          alignment: Alignment.center,
          child: const Text('Other stuff'),
        ),
      ][topIndex],
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
              DataCell(Text("Name")),
              DataCell(Text(widget.device.name ?? "N/A")),
            ]),
            DataRow(cells: [
              DataCell(Text("Waterlevel")),
              DataCell(
                  Text(widget.device.currentState().waterlevel.toString())),
            ]),
            DataRow(cells: [
              DataCell(Text("Waterleak")),
              DataCell(Text(widget.device.currentState().leak.toString())),
            ]),
            DataRow(cells: [
              DataCell(Text("State")),
              DataCell(
                  Text(widget.device.currentState().filter_state.toString())),
            ]),
          ]);
        });
  }
}
