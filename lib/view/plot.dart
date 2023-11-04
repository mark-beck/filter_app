import 'package:first_app/device.dart';
import 'package:first_app/event.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math';
import 'dart:developer' as d;
import 'package:first_app/event.dart' as st;

class WaterlevelChart extends StatelessWidget {
  const WaterlevelChart(
      {super.key, required this.device, required this.duration});

  final Device device;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final currentTime = DateTime.now();
    final hourBefore = currentTime.subtract(duration);

    return FutureBuilder(
        future: device.getStateEvents(hourBefore, currentTime),
        builder:
            (BuildContext context, AsyncSnapshot<List<StateEvent>> snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;
            int baseline =
                device.baseline ?? data.map((e) => e.waterlevel).reduce(max);

            d.log("events: ${data.length}, baseline: $baseline");
            return Center(
                child: SfCartesianChart(
                    // Initialize category axis
                    trackballBehavior: TrackballBehavior(),
                    primaryXAxis:
                        DateTimeAxis(minimum: hourBefore, maximum: currentTime),
                    primaryYAxis:
                        NumericAxis(minimum: 0, maximum: baseline.toDouble()),
                    series: <LineSeries<StateEvent, DateTime>>[
                  LineSeries<StateEvent, DateTime>(
                      // Bind data source
                      dataSource: data,
                      xValueMapper: (StateEvent event, _) => event.time,
                      yValueMapper: (StateEvent event, _) =>
                          baseline - event.waterlevel,
                      pointColorMapper: (StateEvent event, _) {
                        if (event.leak) {
                          return Colors.red;
                        } else if (event.filterState == st.State.idle) {
                          return Colors.yellow;
                        } else if (event.filterState ==
                                st.State.cleanAfterFill ||
                            event.filterState == st.State.cleanBeforeFill) {
                          return Colors.purple;
                        } else {
                          return Colors.green;
                        }
                      })
                ]));
          } else if (snapshot.hasError) {
            var error = snapshot.error;
            var trace = snapshot.stackTrace;
            d.log("error: $error", stackTrace: trace);
            return Center(
              child: Text("Error loading chart: $error"),
            );
          } else {
            return const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}

class UpdatingWaterlevelChart extends StatelessWidget {
  const UpdatingWaterlevelChart(
      {super.key, required this.device, required this.duration});

  final Device device;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: device,
        builder: (context, widget) {
          final currentTime = DateTime.now();
          final hourBefore = currentTime.subtract(duration);
          return FutureBuilder(
              future: device.getStateEvents(hourBefore, currentTime),
              builder: (BuildContext context,
                  AsyncSnapshot<List<StateEvent>> snapshot) {
                if (snapshot.hasData) {
                  final data = snapshot.data!;
                  int baseline = device.baseline ??
                      data.map((e) => e.waterlevel).reduce(max);

                  d.log("events: ${data.length}, baseline: $baseline");
                  return Center(
                      child: SfCartesianChart(
                          // Initialize category axiS
                          primaryXAxis: DateTimeAxis(
                              minimum: hourBefore, maximum: currentTime),
                          primaryYAxis: NumericAxis(
                              minimum: 0, maximum: baseline.toDouble()),
                          series: <FastLineSeries<StateEvent, DateTime>>[
                        FastLineSeries<StateEvent, DateTime>(
                            // Bind data source
                            dataSource: data,
                            xValueMapper: (StateEvent event, _) => event.time,
                            yValueMapper: (StateEvent event, _) =>
                                baseline - event.waterlevel,
                        )
                      ]));
                } else if (snapshot.hasError) {
                  var error = snapshot.error;
                  var trace = snapshot.stackTrace;
                  d.log("error: $error", stackTrace: trace);
                  return Center(
                    child: Text("Error loading chart: $error"),
                  );
                } else {
                  return const SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(),
                  );
                }
              });
        });
  }
}
