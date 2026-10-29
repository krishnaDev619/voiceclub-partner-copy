import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/kyc_file/upload_kyc_file_response.dart';
import 'package:voiceclub_partner/domain/repository/kyc_file_repository.dart';

class UploadKYCFileUsecase
    implements UseCase<DataState<UploadKYCFileResponseModel>, Params> {
  final KYCFileRepository _kycFileRepository;
  UploadKYCFileUsecase(this._kycFileRepository);

  @override
  Future<DataState<UploadKYCFileResponseModel>> call(Params params) {
    return _kycFileRepository.uploadKYCFile(
      file: params.file,
      extension: params.extension,
    );
  }
}

class Params extends Equatable {
  final File file;
  final String extension;
  const Params({required this.file, required this.extension});

  @override
  List<Object> get props => [file, extension];
}
