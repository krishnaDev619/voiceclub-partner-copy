class VerifyGenderResponseModel {
  final String? value;
  final double? confidence;

  VerifyGenderResponseModel({this.value, this.confidence});

  VerifyGenderResponseModel.fromJson(Map<String, dynamic> json)
    : value = json['Value'] as String?,
      confidence = json['Confidence'] as double?;

  Map<String, dynamic> toJson() => {'Value': value, 'Confidence': confidence};
}
