class PenalyWithdrawalExperimentModel {
  final String? cohort;

  PenalyWithdrawalExperimentModel({this.cohort});

  PenalyWithdrawalExperimentModel.fromJson(Map<String, dynamic> json)
    : cohort = json['cohort'] as String?;

  Map<String, dynamic> toJson() => {'cohort': cohort};

  bool get isWithdrawalAllowed => cohort == 'WITHDRAWAL_ALLOWED';
}
