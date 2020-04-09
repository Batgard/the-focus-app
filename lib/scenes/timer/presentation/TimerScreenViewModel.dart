import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'TimerScreenView.dart';

class TimerScreenViewModel extends State<TimerScreenView> {
  PomodoroTimer timer = PomodoroTimer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Focus"),
      ),
      body: Column(
        children: <Widget>[
          Center(),
          Padding(
            padding: EdgeInsets.all(16),
            child: StreamBuilder(
                initialData: "25:00",
                stream: timer.displayableValue(),
                builder: buildTimer),
          ),
          FloatingActionButton(
            child: Icon(timer.isRunning() ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              setState(() {
                timer.toggle();
              });
            },
          )
        ],
      ),
    );
  }

  Widget buildTimer(BuildContext context, AsyncSnapshot asyncSnapshot) {
    return Text(asyncSnapshot.data);
  }
}

class PomodoroTimer {
  TimerValue _value = TimerValue();
  bool _running = false;
  Timer _timer;

  final _streamController = StreamController<String>();

  void _start() {
    _running = true;
    //TODO: Check how to run an action every second on a dedicated thread
    _timer = Timer.periodic(Duration(seconds: 1), (t) {
      _value.decrementOneSecond();
      if (!_value.isComplete()) {
        _streamController.sink.add(formatValue(_value));
      } else {
        _pause();
        //TODO: Start new Timer for break
      }
    });
  }

  void _pause() {
    _running = false;
    _timer.cancel();
  }

  void toggle() {
    if (_running) {
      _pause();
    } else {
      _start();
    }
  }

  bool isRunning() => _running;

  String formatValue(TimerValue value) {
    return "${_value.minutes} : ${_value.seconds}";
  }

  Stream<String> displayableValue() {
    return _streamController.stream;
  }
}

class TimerValue {
  int minutes = 25;
  int seconds = 0;

  void decrementOneSecond() {
    if (seconds == 0) {
      if (minutes != 0) {
        seconds = 59;
        minutes--;
      }
    } else {
      seconds--;
    }
  }

  bool isComplete() => seconds == 0 && minutes == 0;
}
