import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';

class CallStateModel extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? callOnlySeconds;
  final RingState? ringState;
  final CallState? callState;

  const CallStateModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.callOnlySeconds,
    required this.ringState,
    required this.callState,
  });

  factory CallStateModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return CallStateModel(
      id: documentId,
      createdAt: (data['CreatedAt'] as Timestamp).toDate(),
      callOnlySeconds: data['CallOnlySeconds'] as int?,
      ringState: ((data['RingState'] as String?) ?? '').toRingState(),
      callState: ((data['State'] as String?) ?? '').toCallState(),
      updatedAt: (data['UpdatedAt'] as Timestamp).toDate(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    callOnlySeconds,
    callState,
    ringState,
    createdAt,
    updatedAt,
  ];
}
