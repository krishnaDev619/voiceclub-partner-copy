class HypervergeUserDetails {
  final String? bankDetailsAccountNumberValue;
  final String? bankDetailsIFSCCodeValue;
  final String? panCardUploadIDNumberFront;
  final String? pennyDropNameHolder;
  final String? panCardUrl;
  final String? selfieImageUrl;
  final num? age;

  HypervergeUserDetails({
    this.bankDetailsAccountNumberValue,
    this.bankDetailsIFSCCodeValue,
    this.panCardUploadIDNumberFront,
    this.pennyDropNameHolder,
    this.panCardUrl,
    this.selfieImageUrl,
    this.age,
  });

  HypervergeUserDetails.fromJson(Map<String, dynamic> json)
    : bankDetailsAccountNumberValue =
          json['Bank_Details_Account_Number_value'] as String?,
      bankDetailsIFSCCodeValue =
          json['Bank_Details_IFSC_code_value'] as String?,
      panCardUploadIDNumberFront =
          json['PAN_Card_Upload_ID_Number_-_Front'] as String?,
      pennyDropNameHolder = json['Penny_Drop_NameHolder'] as String?,
      panCardUrl = json['PAN_Card_URL'] as String?,
      selfieImageUrl = json['Selfie_Image_URL_(S3_URL)'] as String?,
      age = json['Age_verification_age'] as num?;

  Map<String, dynamic> toJson() => {
    'Bank_Details_Account_Number_value': bankDetailsAccountNumberValue,
    'Bank_Details_IFSC_code_value': bankDetailsIFSCCodeValue,
    'PAN_Card_Upload_ID_Number_-_Front': panCardUploadIDNumberFront,
    'Penny_Drop_NameHolder': pennyDropNameHolder,
    'PAN_Card_URL': panCardUrl,
    'Selfie_Image_URL_(S3_URL)': selfieImageUrl,
    'Age_verification_age': age,
  };
}
