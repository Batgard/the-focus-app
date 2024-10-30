// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'TimerDuration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimerDuration _$TimerDurationFromJson(Map<String, dynamic> json) {
  return TimerDuration(
    minutes: json['minutes'] as int,
    seconds: json['seconds'] as int,
  );
}

Map<String, dynamic> _$TimerDurationToJson(TimerDuration instance) =>
    <String, dynamic>{
      'minutes': instance.minutes,
      'seconds': instance.seconds,
    };
