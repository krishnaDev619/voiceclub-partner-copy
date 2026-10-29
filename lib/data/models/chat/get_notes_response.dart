import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/data/models/chat/note_model.dart';

class GetNotesResponseModel {
  final int? age;
  final Profession? profession;
  final MaritalStatus? relationship;
  final List<Note>? notes;

  GetNotesResponseModel({
    this.age,
    this.profession,
    this.relationship,
    this.notes,
  });

  GetNotesResponseModel.fromJson(Map<String, dynamic> json)
    : age = json['age'] as int?,
      profession =
          json['profession'] != null
              ? ProfessionExtension.fromString(
                (json['profession'] as String?) ?? "",
              )
              : null,
      relationship =
          json['relationship'] != null
              ? (json['relationship'] as String?)?.toMaritalStatus()
              : null,
      notes =
          (json['notes'] as List?)
              ?.map((dynamic e) => Note.fromJson(e as Map<String, dynamic>))
              .toList();

  Map<String, dynamic> toJson() => {
    'age': age,
    'profession': profession,
    'relationship': relationship,
    'notes': notes?.map((e) => e.toJson()).toList(),
  };
}
