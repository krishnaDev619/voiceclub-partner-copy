class GetKycTransactionIdResponseModel {
  final String? transactionId;
  final String? message;

  GetKycTransactionIdResponseModel({this.transactionId, this.message});

  GetKycTransactionIdResponseModel.fromJson(Map<String, dynamic> json)
    : transactionId = json['transaction_id'] as String?,
      message = json['message'] as String?;

  Map<String, dynamic> toJson() => {
    'transaction_id': transactionId,
    'message': message,
  };
}
