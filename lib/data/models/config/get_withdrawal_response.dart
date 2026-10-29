class GetWithdrawalResponseModel {
  final String? message;
  final String? optionName;
  final bool? value;

  GetWithdrawalResponseModel({this.message, this.optionName, this.value});

  GetWithdrawalResponseModel.fromJson(Map<String, dynamic> json)
    : message = json['message'] as String?,
      optionName = json['option_name'] as String?,
      value = json['value'] as bool?;

  Map<String, dynamic> toJson() => {
    'message': message,
    'option_name': optionName,
    'value': value,
  };
}
