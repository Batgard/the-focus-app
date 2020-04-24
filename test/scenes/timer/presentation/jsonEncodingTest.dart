import 'dart:convert';

import 'package:test/test.dart';
import 'package:thefocusapp/scenes/timer/data/ActivityType.dart';
import 'package:thefocusapp/scenes/timer/data/TimerDuration.dart';
import 'package:thefocusapp/scenes/timer/framework/Activity.dart';
import 'package:thefocusapp/scenes/timer/framework/Configuration.dart';
import 'package:thefocusapp/scenes/timer/framework/timerinfo.dart';

void main() {
  test("Serialization", () {
    final timerInfo = TimerInfo(
        CurrentActivity(
            'pomodoro', false, TimerDuration.noNamedArguments(0, 30)),
        Configuration(1, 1, 1, 1));

    final actualEncodedTimerInfo = jsonEncode(timerInfo);

    expect(actualEncodedTimerInfo,
        '''{"currentActivity":{"type":"pomodoro","running":false,"remainingTime":{"minutes":0,"seconds":30}},"configuration":{"pomodoroDurationInMin":1,"shortBreakDurationInMin":1,"longBreakDurationInMin":1,"longBreakFrequency":1}}''');
  });

  test("Weird enum toString()", () {
    final activityType = ActivityType.pomodoro;

    expect(activityType, "ActivityType.pomodoro");
  });
}
