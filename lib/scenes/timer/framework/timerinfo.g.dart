// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timerinfo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimerInfo _$TimerInfoFromJson(Map<String, dynamic> json) {
  return TimerInfo(
    CurrentActivity.fromJson(json['currentActivity'] as Map<String, dynamic>),
    Configuration.fromJson(json['configuration'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$TimerInfoToJson(TimerInfo instance) => <String, dynamic>{
      'currentActivity': instance.currentActivity,
      'configuration': instance.configuration,
    };
