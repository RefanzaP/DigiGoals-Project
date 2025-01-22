class LoginResponse {
  final String? accessToken;

  LoginResponse({this.accessToken});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'],
    );
  }
}
