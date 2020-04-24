import 'package:json_annotation/json_annotation.dart';

part 'Configuration.g.dart';

@JsonSerializable(nullable: false)
class Configuration {
  int pomodoroDurationInMin;
  int shortBreakDurationInMin;
  int longBreakDurationInMin;
  int longBreakFrequency;

  Configuration(this.pomodoroDurationInMin, this.shortBreakDurationInMin,
      this.longBreakDurationInMin, this.longBreakFrequency);

  factory Configuration.fromJson(Map<String, dynamic> json) => _$ConfigurationFromJson(json);

  Map<String, dynamic> toJson() => _$ConfigurationToJson(this);

}