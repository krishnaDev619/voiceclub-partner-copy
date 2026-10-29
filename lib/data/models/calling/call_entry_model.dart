import 'package:equatable/equatable.dart';

class CallEntryModel extends Equatable {
  final String? channelId;

  const CallEntryModel({required this.channelId});

  factory CallEntryModel.fromFirestore(Map<String, dynamic> data) {
    return CallEntryModel(channelId: data['channel_id'] as String?);
  }

  @override
  List<Object?> get props => [channelId];
}
