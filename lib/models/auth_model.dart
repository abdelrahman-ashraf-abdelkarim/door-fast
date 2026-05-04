enum CaptainStatus { active, nonActive }

class AuthModel {
  final String id;
  final String name;
  final String code;
  final String phone;
  final CaptainStatus status;

  const AuthModel({required this.id, required this.name, required this.code, required this.phone, required this.status});

  AuthModel copyWith({String? id, String? name, String? code, String? phone, CaptainStatus? status}) {
    return AuthModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      phone: phone ?? this.phone,
      status: status ?? this.status,
    );
  }

 factory AuthModel.fromJson(Map<String, dynamic> json) {
  final user = json['user'];

  return AuthModel(
    id: user['id'].toString(),
    name: user['name'],
    code: user['code'],
    phone: user['phone'],
    status: CaptainStatus.active, // default مؤقت
  );
}
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'code': code, 'phone': phone, 'status': status.name};
  }
}


class AuthResponse {
  final bool success;
  final String token;
  final AuthModel user;

  AuthResponse({
    required this.success,
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'],
      token: json['token'],
      user: AuthModel(
        id: json['user']['id'].toString(),
        name: json['user']['name'],
        code: json['user']['code'],
        phone: json['user']['phone'],
        status: CaptainStatus.active,
      ),
    );
  }
}
