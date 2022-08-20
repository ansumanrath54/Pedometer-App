import 'package:flutter/material.dart';
import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  late Stream<StepCount> stepCount;
  late Stream<PedestrianStatus> pedestrianStatus;
  String status = '?', steps = '?';
  PermissionStatus permissionStatus = PermissionStatus.denied;

  @override
  void initState() {
    requestNotificationPermission();
    super.initState();
    initPlatformState();
  }

  void requestNotificationPermission() async {
    if(permissionStatus.isDenied) {
      final status = await Permission.activityRecognition.request();
      setState(() {
        permissionStatus = status;
      });
    }
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    print(event);
    setState(() {
      status = event.status;
    });
  }

  void onPedestrianStatusError(error) {
    print("onPedestrianStatusError: $error");
    setState(() {
      status = "Pedestrian Status not Available";
    });
  }

  void onStepsCount(StepCount event) {
    print(event);
    setState(() {
      steps = event.steps.toString();
    });
  }

  void onStepCountError(error) {
    print("onStepCountError: $error");
    setState(() {
      steps = "Step Count not Available";
    });
  }

  void initPlatformState() {
    pedestrianStatus = Pedometer.pedestrianStatusStream;
    pedestrianStatus
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    stepCount = Pedometer.stepCountStream;
    stepCount
        .listen(onStepsCount)
        .onError(onStepCountError);

    if(!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Pedometer App"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Steps taken:',
                style: TextStyle(fontSize: 30),
              ),
              Text(
                steps,
                style: TextStyle(fontSize: 60),
              ),
              Divider(
                height: 100,
                thickness: 0,
                color: Colors.white,
              ),
              Text(
                'Pedestrian status:',
                style: TextStyle(fontSize: 30),
              ),
              Icon(
                status == 'walking'
                    ? Icons.directions_walk
                    : status == 'stopped'
                    ? Icons.accessibility_new
                    : Icons.error,
                size: 100,
              ),
              Center(
                child: Text(
                  status,
                  style: status == 'walking' || status == 'stopped'
                      ? TextStyle(fontSize: 30)
                      : TextStyle(fontSize: 20, color: Colors.red),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
