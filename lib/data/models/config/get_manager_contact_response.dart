class GetManagerContactResponseModel {
  final String? contact;

  GetManagerContactResponseModel({this.contact});

  GetManagerContactResponseModel.fromJson(Map<String, dynamic> json)
    : contact = json['contact'] as String?;

  Map<String, dynamic> toJson() => {'contact': contact};
}
