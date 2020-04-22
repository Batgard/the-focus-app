import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'TimerScreenView.dart';

class TimerScreenViewModel extends State<TimerScreenView> {
  static const String routeId = "TimerScreen";

  final TimeFormatter _timeFormatter = TimeFormatter();
  final methodChannel = MethodChannel("fr.batgard.thefocusapp.notificationChannel");

  PomodoroTimer timer;

  @override
  void initState() {
    super.initState();
    final notification = TimerNotification(context: context, formatter: _timeFormatter);
    timer = PomodoroTimer(formatter: _timeFormatter, notification: notification);
    timer.timerTypeChanges().listen((Activity startingActivity) {
      setState(() {
      });
    });
  }

  @override
  void dispose() {
    timer.dispose();
    super.dispose();
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

  TimerNotification notification;
  TimerConfiguration configuration;
  TimeFormatter formatter;

  TimerValue _value;
  ActivityType _activityType = ActivityType.pomodoro;
  var _running = false;
  Timer _timer;
  var _completedPomodorosCount = 0;

  final _streamController = StreamController<String>();
  final _currentStatusStreamController = StreamController<Activity>();

  PomodoroTimer({this.configuration, this.formatter, this.notification}) {
    if (configuration == null) {
      configuration = TimerConfiguration.debug();
    }
    if (formatter == null) {
      formatter = TimeFormatter();
    }
    _value = TimerValue(duration: configuration.pomodoroDuration);
  }

  void _startTimer() {
    _running = true;
    _timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (_value.isComplete()) {
        _pause();
        _restart();
      }
      _value.decrementOneSecond();
      _streamController.sink.add(formatter.formatValue(_value.asDuration()));
      if (Platform.isAndroid) {
        notification.updateExistingNotification(getCurrentActivity());
      }
    });
  }

  void dispose() {
    _streamController.close();
    _currentStatusStreamController.close();
  }

  void _startPomodoro() {
    _value.reset(duration: configuration.pomodoroDuration);
    _startTimer();
  }

  void _startShortBreak() {
    _value.reset(duration: configuration.shortBreakDuration);
    _startTimer();
  }

  void _startLongBreak() {
    _value.reset(duration: configuration.longBreakDuration);
    _startTimer();
  }

  void _pause() {
    _running = false;
    _timer.cancel();
    final activity = Activity(_activityType, _value.asDuration());
    notification.updateExistingNotificationActivityPaused(activity);
  }

  void _restart() {
    TimerDuration activityDuration;

    if (_activityType != ActivityType.pomodoro) {
      _activityType = ActivityType.pomodoro;
      activityDuration = configuration.pomodoroDuration;
      _startPomodoro();
    } else {
      _completedPomodorosCount++;
      if (_completedPomodorosCount % configuration.numberOfCompletedPomodorosRequiredForLongBreak == 0) {
        _activityType = ActivityType.longBreak;
        activityDuration = configuration.longBreakDuration;
        _startLongBreak();
      } else {
        _activityType = ActivityType.shortBreak;
        activityDuration = configuration.shortBreakDuration;
        _startShortBreak();
      }
    }
    final activity = Activity(_activityType, activityDuration);
    _currentStatusStreamController.sink.add(activity);
    notification.showNewActivityStartNotification(activity);
  }

  void _resume() {
    _startTimer();
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
    return _activityType == ActivityType.pomodoro ? Colors.blueGrey: Colors.green;
  }

  Stream<String> displayableValue() {
    return _streamController.stream;
  }

  Stream<Activity> timerTypeChanges() => _currentStatusStreamController.stream;

  String getInitialValue() => formatter.formatValue(_value.asDuration());

  Activity getCurrentActivity() {
    return Activity(_activityType, _value.asDuration());
  }
}

class TimerValue {

  final TimerDuration duration;
  int _minutes;
  int _seconds;

  TimerValue({this.duration}) {
    _minutes = duration.minutes;
    _seconds = duration.seconds;
  }

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

  void reset({TimerDuration duration}) {
    if (duration == null) {
      _minutes = this.duration.minutes;
      _seconds = this.duration.seconds;
    } else {
      _minutes = duration.minutes;
      _seconds = duration.seconds;
    }
  }

  bool isComplete() => _seconds == 0 && _minutes == 0;

  TimerDuration asDuration() => TimerDuration(minutes: _minutes, seconds: _seconds);
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

  factory TimerConfiguration.debug() {
    return new TimerConfiguration(pomodoroDuration: TimerDuration(minutes: 0, seconds: 5),
        shortBreakDuration: TimerDuration(minutes: 0, seconds: 2),
        longBreakDuration: TimerDuration(minutes: 0, seconds: 4),
        numberOfCompletedPomodorosRequiredForLongBreak: 4);
  }
}

class TimerNotification {

  static const int notificationId = 0;
  final TimeFormatter formatter;
  final BuildContext context;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid = new AndroidInitializationSettings('ic_tomato_timer');
  IOSInitializationSettings initializationSettingsIOS;
  InitializationSettings initializationSettings;
  NotificationChannel channel;
  NotificationDetails platformChannelSpecifics;

  TimerNotification({this.context, this.formatter}) {
    initializationSettingsIOS = new IOSInitializationSettings(
        onDidReceiveLocalNotification: null);
    initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: null);

    channel = NotificationChannel("newActivityStart",
        "New Activity Start",
        "Receive a notification when a new pomodoro or break start");

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        channel.id, channel.name, channel.description,
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  }

  void updateExistingNotificationActivityPaused(Activity activity) async {
    NotificationContent content;

    switch(activity.type) {
      case ActivityType.pomodoro: {
        content = NotificationContent(
            "Pomodoro - Paused",
            "Time left: ${formatter.formatValue(activity.duration)}",
            TimerScreenViewModel.routeId);
        break;
      }
      case ActivityType.shortBreak: {
        content = NotificationContent(
            "Break - Paused",
            "Time left: ${formatter.formatValue(activity.duration)}",
            TimerScreenViewModel.routeId);
        break;
      }
      case ActivityType.longBreak: {
        content = NotificationContent(
            "Break - Paused",
            "Time left: ${formatter.formatValue(activity.duration)}",
            TimerScreenViewModel.routeId);
        break;
      }
    }

    await flutterLocalNotificationsPlugin.show(
        notificationId,
        content.title,
        content.body,
        platformChannelSpecifics,
        payload: content.payload);
  }

  void updateExistingNotification(Activity activity) async {
    NotificationContent content;

    switch(activity.type) {
      case ActivityType.pomodoro: {
        content = NotificationContent(
            "Pomodoro",
            "Time left: ${formatter.formatValue(activity.duration)}",
            TimerScreenViewModel.routeId);
        break;
      }
      case ActivityType.shortBreak: {
        content = NotificationContent(
            "Break!",
            "Time left: ${formatter.formatValue(activity.duration)}",
            TimerScreenViewModel.routeId);
        break;
      }
      case ActivityType.longBreak: {
        content = NotificationContent(
            "Break!",
            "Time left: ${formatter.formatValue(activity.duration)}",
            TimerScreenViewModel.routeId);
        break;
      }
    }

    await flutterLocalNotificationsPlugin.show(
        notificationId,
        content.title,
        content.body,
        platformChannelSpecifics,
        payload: content.payload);
  }

  void showNewActivityStartNotification(Activity activity) async {

    NotificationContent content;

    switch(activity.type) {
      case ActivityType.pomodoro: {
        content = NotificationContent(
            "It's time to focus",
            "A new pomodoro of ${activity.duration.minutes}m started",
            TimerScreenViewModel.routeId);
        break;
      }
      case ActivityType.shortBreak: {
        content = NotificationContent(
            "Break!",
            "A new short break of ${activity.duration.minutes}m started",
            TimerScreenViewModel.routeId);
        break;
      }
      case ActivityType.longBreak: {
        content = NotificationContent(
            "Break!",
            "A new long break of ${activity.duration.minutes}m started",
            TimerScreenViewModel.routeId);
        break;
      }
    }

    await flutterLocalNotificationsPlugin.show(
        notificationId,
        content.title,
        content.body,
        platformChannelSpecifics,
        payload: content.payload
    );
  }

}

class NotificationChannel {
  final String id;
  final String name;
  final String description;

  NotificationChannel(this.id, this.name,
      this.description);
}

class NotificationContent {
  final String title;
  final String body;
  final String payload;

  NotificationContent(this.title, this.body, this.payload);
}

enum ActivityType {
  pomodoro,
  shortBreak,
  longBreak
}

class Activity {
  final ActivityType type;
  final TimerDuration duration;

  Activity(this.type, this.duration);
}

class TimeFormatter {
  String formatValue(TimerDuration value) {
    return "${value.minutes}:${_formatSeconds(value.seconds)}";
  }

  String _formatSeconds(int seconds) {
    return seconds < 10 ? "0$seconds": "$seconds";
  }
}
