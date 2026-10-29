class PlaceCallResponseModel {
  final String? channelId;
  final String? message;
  final String? token;
  final String? snackbarTitle;
  final String? snackbarMessage;
  final bool? isFree;

  PlaceCallResponseModel({
    this.channelId,
    this.message,
    this.token,
    this.snackbarTitle,
    this.snackbarMessage,
    this.isFree,
  });

  PlaceCallResponseModel.fromJson(Map<String, dynamic> json)
    : channelId = json['channel_id'] as String?,
      message = json['message'] as String?,
      token = json['token'] as String?,
      isFree = json['is_free'] as bool?,
      snackbarTitle = json['snackbar_title'] as String?,
      snackbarMessage = json['snackbar_message'] as String?;

  Map<String, dynamic> toJson() => {
    'channel_id': channelId,
    'message': message,
    'token': token,
    'snackbar_message': snackbarMessage,
    'snackbar_title': snackbarTitle,
  };
}
