import 'package:equatable/equatable.dart';

class TimeSlot extends Equatable {
  const TimeSlot({
    required this.slotId,
    required this.providerId,
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
  });

  final String slotId;
  final String providerId;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;

  TimeSlot copyWith({
    String? slotId,
    String? providerId,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAvailable,
  }) {
    return TimeSlot(
      slotId: slotId ?? this.slotId,
      providerId: providerId ?? this.providerId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  @override
  List<Object?> get props =>
      [slotId, providerId, startTime, endTime, isAvailable];
}
