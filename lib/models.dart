class UserRequest {
  int? userid;
  String title;
  String body;
  int? id;

  UserRequest({
    required this.title,
    required this.body,
    required this.userid,
    required this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'userid': userid,
    };
  }

  factory UserRequest.fromMap(Map<String, dynamic> map) {
    return UserRequest(
      userid: map['userid'] ?? 0,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      id: map['id'] ?? 0,
    );
  }
}
