class GetAvailableSlotsResponse {
  final List<Slots>? slots;

  GetAvailableSlotsResponse({this.slots});

  GetAvailableSlotsResponse.fromJson(Map<String, dynamic> json)
    : slots =
          (json['slots'] as List?)
              ?.map((dynamic e) => Slots.fromJson(e as Map<String, dynamic>))
              .toList();

  Map<String, dynamic> toJson() => {
    'slots': slots?.map((e) => e.toJson()).toList(),
  };
}

class Slots {
  final int? id;
  final DateTime? startTime;
  final DateTime? endTime;
  final int? slotNumber;
  final String? status;
  final bool? isBooked;
  final int? maxUsage;
  final bool? isAvailable;
  final int? amount;

  Slots({
    this.id,
    this.startTime,
    this.endTime,
    this.slotNumber,
    this.status,
    this.isBooked,
    this.maxUsage,
    this.isAvailable,
    this.amount,
  });

  Slots.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int?,
      startTime = DateTime.tryParse(json['start_time'] as String? ?? ''),
      endTime = DateTime.tryParse(json['end_time'] as String? ?? ''),
      slotNumber = json['slot_number'] as int?,
      status = json['status'] as String?,
      isBooked = json['is_booked'] as bool?,
      maxUsage = json['max_usage'] as int?,
      isAvailable = json['is_available'] as bool?,
      amount = json['amount'] as int?;

  Map<String, dynamic> toJson() => {
    'id': id,
    'start_time': startTime,
    'end_time': endTime,
    'slot_number': slotNumber,
    'status': status,
    'is_booked': isBooked,
    'max_usage': maxUsage,
    'is_available': isAvailable,
    'amount': amount,
  };
}
