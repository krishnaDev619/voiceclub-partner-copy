import 'package:voiceclub_partner/data/models/hyperverge/hyperverge_user_details.dart';

class Result {
  final List<dynamic>? flags;
  final HypervergeUserDetails? userDetails;
  final String? status;
  final String? transactionId;

  Result({this.flags, this.userDetails, this.status, this.transactionId});

  Result.fromJson(Map<String, dynamic> json)
    : flags = json['flags'] as List?,
      userDetails =
          (json['userDetails'] as Map<String, dynamic>?) != null
              ? HypervergeUserDetails.fromJson(
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
