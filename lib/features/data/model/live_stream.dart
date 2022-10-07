class LiveStream {
  final String title;
  final String image;
  final String uId;
  final String username;
  final String startedAt;
  final int viewers;
  final String channelId;

  LiveStream({
    required this.title,
    required this.image,
    required this.uId,
    required this.username,
    required this.startedAt,
    required this.viewers,
    required this.channelId,
  });
    factory LiveStream.fromJson(Map<String, dynamic> json) {
    return LiveStream(
      uId: json['uId'] ?? '',
      username: json['username'] ?? '',
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      startedAt: json['startedAt'] ?? '',
      channelId: json['channelId'] ?? '',
      viewers: json['viewers']?.toInt() ?? 0,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'uId': uId,
      'title': title,
      'image': image,
      'startedAt': startedAt,
      'channelId': channelId,
      'viewers': viewers,
    };
  }
}
