import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'TimerScreenView.dart';

class TimerScreenViewModel extends State<TimerScreenView> {
  PomodoroTimer timer = PomodoroTimer();

  @override
  void initState() {
    super.initState();
    timer.timerTypeChanges().listen((bool event) {
      setState(() {});
    });
  }

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
                initialData: timer.getInitialValue(),
                stream: timer.displayableValue(),
                builder: buildTimer),
          ),
          FloatingActionButton(
            foregroundColor: Colors.white,
            backgroundColor: timer.color(),
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
    return Text(
      asyncSnapshot.data,
      style: TextStyle(color: timer.color()),
    );
  }
}

class PomodoroTimer {
  TimerValue _value = TimerValue(minutes: 0, seconds: 10);
  var _break = false;
  var _running = false;
  Timer _timer;

  final _streamController = StreamController<String>();
  final _currentStatusStreamController = StreamController<bool>();

  void _startTimer() {
    _running = true;
    _timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (_value.isComplete()) {
        _pause();
        _restart();
      }
      _value.decrementOneSecond();
      _streamController.sink.add(_formatValue(_value));
    });
  }

  void _startPomodoro() {
    _value.reset(minutes: 0, seconds: 10);
    _startTimer();
  }

  void _startBreak() {
    _value.reset(minutes: 0, seconds: 10);
    _startTimer();
  }

  void _pause() {
    _running = false;
    _timer.cancel();
  }

  void _restart() {
    if (_break) {
      _startBreak();
    } else {
      _startPomodoro();
    }
    _break = !_break;
    _currentStatusStreamController.sink.add(true);
  }

  void _resume() {
    _startTimer();
  }

  String _formatValue(TimerValue value) {
    return "${_value._minutes} : ${_value._seconds}";
  }

  void toggle() {
    if (_running) {
      _pause();
    } else {
      _resume();
    }
  }

  bool isRunning() => _running;

  MaterialColor color() {
    return _break ? Colors.green : Colors.blueGrey;
  }

  Stream<String> displayableValue() {
    return _streamController.stream;
  }

  Stream<bool> timerTypeChanges() => _currentStatusStreamController.stream;

  String getInitialValue() => _formatValue(_value);
}

class TimerValue {
  int _minutes;
  int _seconds;

  void decrementOneSecond() {
    if (_seconds == 0) {
      if (_minutes != 0) {
        _seconds = 59;
        _minutes--;
      }
    } else {
      _seconds--;
    }
  }

  void reset({int minutes, int seconds}) {
    _minutes = minutes;
    _seconds = seconds;
  }

  bool isComplete() => _seconds == 0 && _minutes == 0;

  TimerValue({int minutes, int seconds}) {
    _minutes = minutes;
    _seconds = seconds;
  }
}
