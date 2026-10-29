class OnlineDuration {
  final num? monday;
  final num? tuesday;
  final num? wednesday;
  final num? thursday;
  final num? friday;
  final num? saturday;
  final num? sunday;

  OnlineDuration({
    this.monday,
    this.tuesday,
    this.wednesday,
    this.thursday,
    this.friday,
    this.saturday,
    this.sunday,
  });

  OnlineDuration.fromJson(Map<String, dynamic> json)
    : monday = json['monday'] as num?,
      tuesday = json['tuesday'] as num?,
      wednesday = json['wednesday'] as num?,
      thursday = json['thursday'] as num?,
      friday = json['friday'] as num?,
      saturday = json['saturday'] as num?,
      sunday = json['sunday'] as num?;

  Map<String, dynamic> toJson() => {
    'monday': monday,
    'tuesday': tuesday,
    'wednesday': wednesday,
    'thursday': thursday,
    'friday': friday,
    'saturday': saturday,
    'sunday': sunday,
  };

  int getTotalOnlineDuration() =>
      (((monday ?? 0) +
                  (tuesday ?? 0) +
                  (wednesday ?? 0) +
                  (thursday ?? 0) +
                  (friday ?? 0) +
                  (saturday ?? 0) +
                  (sunday ?? 0)) *
              3600)
          .floor();
}
