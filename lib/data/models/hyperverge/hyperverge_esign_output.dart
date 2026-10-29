import 'package:voiceclub_partner/core/constants/enums.dart';

class HypervergeEsignOutputResponse {
  final String? status;
  final int? statusCode;
  final EsignResult? result;

  HypervergeEsignOutputResponse({this.status, this.statusCode, this.result});

  HypervergeEsignOutputResponse.fromJson(Map<String, dynamic> json)
    : status = json['status'] as String?,
      statusCode = json['statusCode'] as int?,
      result =
          (json['result'] as Map<String, dynamic>?) != null
              ? EsignResult.fromJson(json['result'] as Map<String, dynamic>)
              : null;

  Map<String, dynamic> toJson() => {
    'status': status,
    'statusCode': statusCode,
    'result': result?.toJson(),
  };

  KYCStatus get kycStatus =>
      result?.status == "needs_review"
          ? KYCStatus.needsReview
          : (result?.status == "manually_approved" ||
              result?.status == "auto_approved")
          ? KYCStatus.approved
          : KYCStatus.rejected;
}

class EsignResult {
  final List<dynamic>? flags;
  final HypervergeEsignUserDetails? userDetails;
  final String? status;
  final String? transactionId;

  EsignResult({this.flags, this.userDetails, this.status, this.transactionId});

  EsignResult.fromJson(Map<String, dynamic> json)
    : flags = json['flags'] as List?,
      userDetails =
          (json['userDetails'] as Map<String, dynamic>?) != null
              ? HypervergeEsignUserDetails.fromJson(
                json['userDetails'] as Map<String, dynamic>,
              )
              : null,
      status = json['status'] as String?,
      transactionId = json['transactionId'] as String?;

  Map<String, dynamic> toJson() => {
    'flags': flags,
    'userDetails': userDetails?.toJson(),
    'status': status,
    'transactionId': transactionId,
  };
}

class HypervergeEsignUserDetails {
  final String? documentId;
  final String? aadhaarNumber;
  final String? pincode;
  final String? gender;
  final String? signingStatus;
  final String? name;
  final String? state;
  final String? yob;
  final String? documentUrl;
  final String? ifsc;
  final String? accountNumber;
  final String? upi;
  final String? upiAccountExists;

  HypervergeEsignUserDetails({
    this.documentId,
    this.aadhaarNumber,
    this.pincode,
    this.gender,
    this.signingStatus,
    this.name,
    this.state,
    this.yob,
    this.documentUrl,
    this.ifsc,
    this.accountNumber,
    this.upi,
    this.upiAccountExists,
  });

  HypervergeEsignUserDetails.fromJson(Map<String, dynamic> json)
    : documentId = json['documentId'] as String?,
      aadhaarNumber = json['aadhaarNumber'] as String?,
      pincode = json['pincode'] as String?,
      gender = json['gender'] as String?,
      signingStatus = json['signingStatus'] as String?,
      name = json['name'] as String?,
      state = json['state'] as String?,
      yob = json['yob'] as String?,
      documentUrl = json['documentUrl'] as String?,
      ifsc = json['ifsc'] as String?,
      accountNumber = json['accountNumber'] as String?,
      upi = json['upi'] as String?,
      upiAccountExists = json['upiAccountExists'] as String?;

  Map<String, dynamic> toJson() => {
    'documentId': documentId,
    'aadhaarNumber': aadhaarNumber,
    'pincode': pincode,
    'gender': gender,
    'signingStatus': signingStatus,
    'name': name,
    'state': state,
    'yob': yob,
    'documentUrl': documentUrl,
    'ifsc': ifsc,
    'accountNumber': accountNumber,
    'upi': upi,
    'upiAccountExists': upiAccountExists,
  };
}
