class GetKYCResponseModel {
  final String? pan;
  final String? panPhoto;
  final bool? kycVerified;
  final String? bankName;
  final String? ifsc;
  final String? accountNumber;
  final String? signedDocumentPath;
  final String? selfieImagePath;

  GetKYCResponseModel({
    this.pan,
    this.panPhoto,
    this.kycVerified,
    this.bankName,
    this.ifsc,
    this.accountNumber,
    this.signedDocumentPath,
    this.selfieImagePath,
  });

  GetKYCResponseModel.fromJson(Map<String, dynamic> json)
    : pan = json['pan'] as String?,
      panPhoto = json['pan_photo'] as String?,
      kycVerified = json['kyc_verified'] as bool?,
      bankName = json['bank_name'] as String?,
      ifsc = json['ifsc'] as String?,
      accountNumber = json['account_number'] as String?,
      signedDocumentPath = json['signed_document_path'] as String?,
      selfieImagePath = json['selfie_image_path'] as String?;

  Map<String, dynamic> toJson() => {
    'pan': pan,
    'pan_photo': panPhoto,
    'kyc_verified': kycVerified,
    'bank_name': bankName,
    'ifsc': ifsc,
    'account_number': accountNumber,
    'signed_document_path': signedDocumentPath,
    'selfie_image_path': selfieImagePath,
  };
}
