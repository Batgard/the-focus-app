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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Center(),
          Padding(
            padding: EdgeInsets.all(16),
            child: StreamBuilder(
                initialData: timer.getInitialValue(),
                stream: timer.displayableValue(),
                builder: buildTimer),
          ),
          _formatCompletedPomodoroCount(),
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

  Text _formatCompletedPomodoroCount() {
    String pomodoro = "🍅";
    String completedPomodoros = "";
    for (int i = 0; i< timer.getCompletedPomodoroCount(); i++) {
      completedPomodoros = completedPomodoros+pomodoro;
    }
    return Text(completedPomodoros);
  }
}

class PomodoroTimer {

  TimerConfiguration configuration;

  TimerValue _value;
  var _break = false;
  var _running = false;
  Timer _timer;
  var _completedPomodorosCount = 0;

  final _streamController = StreamController<String>();
  final _currentStatusStreamController = StreamController<bool>();

  PomodoroTimer({this.configuration}) {
    if (configuration == null) {
      configuration = TimerConfiguration.setUpWithDefaults();
    }
    _value = TimerValue(
        minutes: configuration.pomodoroDuration.minutes,
        seconds: configuration.pomodoroDuration.seconds
    );
  }

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
    _value.reset(minutes: configuration.pomodoroDuration.minutes,
        seconds: configuration.pomodoroDuration.seconds);
    _startTimer();
  }

  void _startShortBreak() {
    _value.reset(minutes: configuration.shortBreakDuration.minutes,
        seconds: configuration.shortBreakDuration.seconds
    );
    _startTimer();
  }

  void _startLongBreak() {
    _value.reset(minutes: configuration.longBreakDuration.minutes,
        seconds: configuration.longBreakDuration.seconds);
    _startTimer();
  }

  void _pause() {
    _running = false;
    _timer.cancel();
  }

  void _restart() {
    if (_break) {
      _startPomodoro();
    } else {
      _completedPomodorosCount++;
      if (_completedPomodorosCount % configuration.numberOfCompletedPomodorosRequiredForLongBreak == 0) {
        _startLongBreak();
      } else {
        _startShortBreak();
      }
    }
    _currentStatusStreamController.sink.add(true);
    _break = !_break;
  }

  void _resume() {
    _startTimer();
  }

  String _formatValue(TimerValue value) {
    return "${_value._minutes}:${_formatSeconds(_value._seconds)}";
  }

  String _formatSeconds(int seconds) {
    return seconds < 10 ? "0$seconds": "$seconds";
  }

  int getCompletedPomodoroCount() => _completedPomodorosCount;

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
  final int defaultMinutes = 25;
  final int defaultSeconds = 0;
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

class TimerDuration {
  final int minutes;
  final int seconds;

  TimerDuration({this.minutes, this.seconds});

}

class TimerConfiguration {

  final TimerDuration pomodoroDuration;
  final TimerDuration shortBreakDuration;
  final TimerDuration longBreakDuration;
  final int numberOfCompletedPomodorosRequiredForLongBreak;

  TimerConfiguration({
    this.pomodoroDuration,
    this.shortBreakDuration,
    this.longBreakDuration,
    this.numberOfCompletedPomodorosRequiredForLongBreak
  });

  factory TimerConfiguration.setUpWithDefaults() {
    return new TimerConfiguration(pomodoroDuration: TimerDuration(minutes: 25, seconds: 0),
        shortBreakDuration: TimerDuration(minutes: 5, seconds: 0),
        longBreakDuration: TimerDuration(minutes: 15, seconds: 0),
        numberOfCompletedPomodorosRequiredForLongBreak: 4);
  }
}
