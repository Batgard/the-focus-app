// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Configuration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Configuration _$ConfigurationFromJson(Map<String, dynamic> json) {
  return Configuration(
    json['pomodoroDurationInMin'] as int,
    json['shortBreakDurationInMin'] as int,
    json['longBreakDurationInMin'] as int,
    json['longBreakFrequency'] as int,
  );
}

Map<String, dynamic> _$ConfigurationToJson(Configuration instance) =>
    <String, dynamic>{
      'pomodoroDurationInMin': instance.pomodoroDurationInMin,
      'shortBreakDurationInMin': instance.shortBreakDurationInMin,
      'longBreakDurationInMin': instance.longBreakDurationInMin,
      'longBreakFrequency': instance.longBreakFrequency,
    };
