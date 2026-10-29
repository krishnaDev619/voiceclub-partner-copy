import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/data/models/hyperverge/kyc_data_model.dart';
import 'package:voiceclub_partner/data/models/hyperverge/result.dart';

class HypervergeOutputAPIResponseModel {
  final String? status;
  final int? statusCode;
  final Result? result;

  HypervergeOutputAPIResponseModel({this.status, this.statusCode, this.result});

  HypervergeOutputAPIResponseModel.fromJson(Map<String, dynamic> json)
    : status = json['status'] as String?,
      statusCode = json['statusCode'] as int?,
      result =
          (json['result'] as Map<String, dynamic>?) != null
              ? Result.fromJson(json['result'] as Map<String, dynamic>)
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

  String? get panNumber => result?.userDetails?.panCardUploadIDNumberFront;

  String? get panImageUrl => result?.userDetails?.panCardUrl;

  String? get accountName => result?.userDetails?.pennyDropNameHolder;

  String? get accountNumber =>
      result?.userDetails?.bankDetailsAccountNumberValue;

  String? get ifsc => result?.userDetails?.bankDetailsIFSCCodeValue;

  int? get age => result?.userDetails?.age?.toInt().ceil();

  KYCDataModel? get kycDataModel {
    if (panNumber == null ||
        panImageUrl == null ||
        accountName == null ||
        accountNumber == null ||
        ifsc == null) {
      return null;
    } else {
      return KYCDataModel(
        panNumber: panNumber!,
        panImageUrl: panImageUrl!,
        accountName: accountName!,
        accountNumber: accountNumber!,
        ifsc: ifsc!,
      );
    }
  }
}
