import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:thefocusapp/scenes/timer/data/ActivityType.dart';
import 'package:thefocusapp/scenes/timer/data/TimerDuration.dart';
import 'package:thefocusapp/scenes/timer/framework/Activity.dart';
import 'package:thefocusapp/scenes/timer/framework/Configuration.dart';
import 'package:thefocusapp/scenes/timer/framework/timerinfo.dart';

import 'TimerScreenView.dart';

class TimerScreenViewModel extends State<TimerScreenView> with WidgetsBindingObserver {
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
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    timer.dispose();
    WidgetsBinding.instance.removeObserver(this);
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

  /// WidgetsBindingObserver region
  /// Only call this method if the app is backgrounded and the timer is running
    void startTimerNotification() async {
        final Activity activity = timer.getCurrentActivity();
        final pomodoroDuration = timer.configuration.pomodoroDuration.minutes;
        final shortBreakDuration = timer.configuration.shortBreakDuration.minutes;
        final longBreakDuration = timer.configuration.longBreakDuration.minutes;
        final longBreakFrequency = timer.configuration.numberOfCompletedPomodorosRequiredForLongBreak;
        var currentActivity = "";
        TimerDuration remainingTime;

        if (activity != null) {
          switch(activity.type) {
            case ActivityType.pomodoro:
              currentActivity = "Pomodoro";
              break;
            case ActivityType.shortBreak:
            case ActivityType.longBreak:
              currentActivity = "Break!";
              break;
          }
          remainingTime = activity.duration;
        }

        final timerInfo = TimerInfo(
            CurrentActivity(_getActivityTypeJsonValue(activity.type),
                timer.isRunning(),
                activity.duration),
            Configuration(pomodoroDuration, shortBreakDuration, longBreakDuration, longBreakFrequency)
        );

        final argument = jsonEncode(timerInfo);

        await methodChannel.invokeMethod("startTimerNotification",
            argument
        );
      }

    void stopTimerNotification() async {
      await methodChannel.invokeMethod("stopTimerNotification");
    }

  /// Just an ugly hack to make up for the lack of methods in enums.
  /// Note that, by default, an enum's toString() returns NameOfTheEnum.theEnumValue
  String _getActivityTypeJsonValue(ActivityType type) {
    return type.toString().split(".")[1];
  }

    @override
    void didChangeAppLifecycleState(AppLifecycleState state) {
      switch(state) {
        case AppLifecycleState.resumed:
            stopTimerNotification();
            break;
          case AppLifecycleState.paused:
            startTimerNotification();
            break;
          default: break;
        }
      }

  /// WidgetsBindingObserver region end

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
      configuration = TimerConfiguration.setUpWithDefaults();
    }
    if (formatter == null) {
      formatter = TimeFormatter();
    }
    _value = TimerValue(duration: configuration.pomodoroDuration);
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

  int getCompletedPomodoroCount() => _completedPomodorosCount;

  void dispose() {
    _streamController.close();
    _currentStatusStreamController.close();
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
      notification.updateExistingNotification(getCurrentActivity());
    });
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
