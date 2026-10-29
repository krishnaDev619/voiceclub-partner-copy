class Slab {
  final int? start;
  final int? end;
  final num? ratio;

  Slab({this.start, this.end, this.ratio});

  Slab.fromJson(Map<String, dynamic> json)
    : start = json['start'] as int?,
      end = json['end'] as int?,
      ratio = json['ratio'] as num?;

  Map<String, dynamic> toJson() => {'start': start, 'end': end, 'ratio': ratio};

  String get split {
    if (ratio == null) {
      return '';
    } else {
      return '₹${(ratio!).toStringAsFixed(1)}/min';
    }
  }

  String get percentage {
    if (ratio == null) {
      return '';
    } else {
      return '${(ratio! * 100).toStringAsFixed(0)}%';
    }
  }

  String get duration {
    if (start != null && end != null) {
      int startMinutes = (start! ~/ 60);
      int endMinutes = (end! ~/ 60);
      if (startMinutes == endMinutes) {
        return 'Above ${endMinutes.toStringAsFixed(0)} min';
      }
      return '${startMinutes.toStringAsFixed(0)} - ${endMinutes.toStringAsFixed(0)} min';
    } else {
      return "";
    }
  }
}
