class MoreDetailsModel {
  final String? title;
  final String? description;
  final String? image;
  final String? link;
  final int? status;

  MoreDetailsModel({
    this.title,
    this.description,
    this.image,
    this.link,
    this.status,
  });

  MoreDetailsModel.fromJson(Map<String, dynamic> json)
    : title = json['title'] as String?,
      description = json['description'] as String?,
      image = json['image'] as String?,
      link = json['link'] as String?,
      status = json['status'] as int?;

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'image': image,
    'link': link,
    'status': status,
  };
}
