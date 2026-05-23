import 'package:localservicemarket/domain/entities/time_slot.dart';

class TimeSlotModel extends TimeSlot {
  const TimeSlotModel({
    required super.slotId,
    required super.providerId,
    required super.startTime,
    required super.endTime,
    super.isAvailable,
  });

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotModel(
      slotId: json['slotId'] as String,
      providerId: json['providerId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'slotId': slotId,
        'providerId': providerId,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'isAvailable': isAvailable,
      };
}
