// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrentActivity _$ActivityFromJson(Map<String, dynamic> json) {
  return CurrentActivity(
    json['type'] as String,
    json['running'] as bool,
    TimerDuration.fromJson(json['remainingTime'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$ActivityToJson(CurrentActivity instance) => <String, dynamic>{
      'type': instance.type,
      'running': instance.running,
      'remainingTime': instance.remainingTime,
    };
