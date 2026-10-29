class GetEventDataResponseModel {
  final Map<String, dynamic>? data;

  GetEventDataResponseModel({this.data});

  GetEventDataResponseModel.fromJson(Map<String, dynamic> json)
    : data = json['data'];

  Map<String, dynamic> toJson() => {'data': data};

  int? get eventId => data?['eventId'] as int?;
}
