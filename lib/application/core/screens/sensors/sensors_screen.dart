import 'package:esara/application/core/constants/colors.dart';
import 'package:esara/application/core/constants/text_string.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../home/home_page_screen.dart';

class SensorsScreen extends StatefulWidget {
  const SensorsScreen({
    super.key,
  });

  @override
  State<SensorsScreen> createState() => _SensorsScreenState();
}

class _SensorsScreenState extends State<SensorsScreen> {
  @override
  void initState() {
    _sms();
    super.initState();
  }

  Future _sms() async {
    final status = await Permission.sms.request();
    if (status != PermissionStatus.granted) {
      throw 'Sms permission not granted';
    }
  }

  double _getCorrectValue(double? value) {
    double result = 0;
    value ??= 0;
    if (value < 0) {
      result = 0;
    } else if (value > 1) {
      result = 1;
    } else {
      result = value;
    }
    return result;
  }

  Future<bool> _onWillPop() async {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()));
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 32.0, right: 16.0),
              child: Container(),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularPercentIndicator(
                    radius: 100.0,
                    lineWidth: 8.0,
                    percent: .60,
                    center: const Text(
                      tInfo4,
                      style: TextStyle(fontSize: 35.0),
                    ),
                    progressColor: tPrimaryColor,
                    backgroundColor: Colors.blue,
                  ),
                  StreamBuilder(
                      stream: SensorsPlatform.instance.accelerometerEvents,
                      builder: (_, snapshot) {
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 64.0,
                                  top: 32.0,
                                  right: 64.0,
                                  bottom: 8.0),
                              child: LinearPercentIndicator(
                                lineHeight: 5,
                                percent: _getCorrectValue(snapshot.data?.x),
                                progressColor: tPrimaryColor,
                                backgroundColor: Colors.deepPurple.shade200,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 64.0,
                                  top: 8.0,
                                  right: 64.0,
                                  bottom: 8.0),
                              child: LinearPercentIndicator(
                                lineHeight: 5,
                                percent: _getCorrectValue(snapshot.data?.y),
                                progressColor: Colors.blue,
                                backgroundColor: Colors.deepPurple.shade200,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 64.0,
                                  top: 8.0,
                                  right: 64.0,
                                  bottom: 8.0),
                              child: LinearPercentIndicator(
                                lineHeight: 5,
                                percent: _getCorrectValue(snapshot.data?.z),
                                progressColor: Colors.red,
                                backgroundColor: Colors.deepPurple.shade200,
                              ),
                            )
                          ],
                        );
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
