import 'package:json_annotation/json_annotation.dart';

part 'TimerDuration.g.dart';

@JsonSerializable(nullable: false)
class TimerDuration {
  final int minutes;
  final int seconds;


  TimerDuration({this.minutes, this.seconds});

  TimerDuration.noNamedArguments(this.minutes, this.seconds);

  factory TimerDuration.fromJson(Map<String, dynamic> json) => _$TimerDurationFromJson(json);

  Map<String, dynamic> toJson() => _$TimerDurationToJson(this);
}