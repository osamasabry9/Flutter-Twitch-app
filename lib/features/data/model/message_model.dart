class MessageModel {
  late String username;
  late String uId;
  late String startedAt;
  late String message;
  late String commentId;

  MessageModel({
    required this.username,
    required this.uId,
    required this.startedAt,
    required this.message,
        required this.commentId,

  });

  MessageModel.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    uId = json['uId'];
    startedAt = json['startedAt'];
    message = json['message'];
     commentId = json['commentId'];
        

  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'uId': uId,
      'startedAt': startedAt,
      'message': message,
      'commentId': commentId,
    };
  }
}