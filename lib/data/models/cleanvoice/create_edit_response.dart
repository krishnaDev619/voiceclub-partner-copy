class CreateEditResponse {
  final String id;

  CreateEditResponse({required this.id});

  CreateEditResponse.fromJson(Map<String, dynamic> json) : id = json['id'];

  Map<String, dynamic> toJson() => {'id': id};
}
