class KYCDataModel {
  final String panNumber;
  final String panImageUrl;
  final String accountName;
  final String accountNumber;
  final String ifsc;
  String? panImageFilename;

  KYCDataModel({
    required this.panNumber,
    required this.panImageUrl,
    required this.accountName,
    required this.accountNumber,
    required this.ifsc,
  });

  // Method to update the panImageFilename
  void updatePanImageFilename(String filename) {
    panImageFilename = filename;
  }
}
