import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:thefocusapp/scenes/timer/data/TimerDuration.dart';

part 'Activity.g.dart';

@JsonSerializable(nullable: false)
class CurrentActivity {
  String type;
  bool running;
  TimerDuration remainingTime;

  CurrentActivity(this.type, this.running, this.remainingTime);

  factory CurrentActivity.fromJson(Map<String, dynamic> json) => _$ActivityFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityToJson(this);
}