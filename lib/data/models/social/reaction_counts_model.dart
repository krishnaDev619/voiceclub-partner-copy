class ReactionCountsModel {
  final int? like;
  final int? love;
  final int? haha;
  final int? heart;
  final int? clap;
  final int? cry;

  ReactionCountsModel({
    this.like,
    this.love,
    this.haha,
    this.heart,
    this.clap,
    this.cry,
  });

  factory ReactionCountsModel.fromJson(Map<String, dynamic> json) {
    return ReactionCountsModel(
      like: json['LIKE'] as int?,
      love: json['LOVE'] as int?,
      haha: json['HAHA'] as int?,
      heart: json['HEART'] as int?,
      clap: json['CLAP'] as int?,
      cry: json['CRY'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'LIKE': like,
      'LOVE': love,
      'HAHA': haha,
      'HEART': heart,
      'CLAP': clap,
      'CRY': cry,
    };
  }

  int? get totalReactions =>
      (like ?? 0) +
      (love ?? 0) +
      (haha ?? 0) +
      (heart ?? 0) +
      (clap ?? 0) +
      (cry ?? 0);
}
