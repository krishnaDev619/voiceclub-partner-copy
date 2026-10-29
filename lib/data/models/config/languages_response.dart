import 'package:voiceclub_partner/data/models/config/language_info.dart';

class LanguagesResponseModel {
  final List<LanguageInfo>? languages;

  LanguagesResponseModel({this.languages});

  LanguagesResponseModel.fromJson(Map<String, dynamic> json)
    : languages =
          (json['languages'] as List?)
              ?.map(
                (dynamic e) => LanguageInfo.fromJson(e as Map<String, dynamic>),
              )
              .toList();

  Map<String, dynamic> toJson() => {
    'languages': languages?.map((e) => e.toJson()).toList(),
  };
}
