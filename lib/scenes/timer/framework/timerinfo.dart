import 'package:thefocusapp/scenes/timer/framework/Activity.dart';
import 'package:thefocusapp/scenes/timer/framework/Configuration.dart';
import 'package:json_annotation/json_annotation.dart';

part 'timerinfo.g.dart';

@JsonSerializable(nullable: false)
class TimerInfo {

  CurrentActivity currentActivity;
  Configuration configuration;

  TimerInfo(this.currentActivity, this.configuration);

  Map<String, dynamic> toJson() => _$TimerInfoToJson(this);
}