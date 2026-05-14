enum CaptainStatus { active, nonActive }

class AuthModel {
  final String id;
  final String name;
  final String code;
  final String phone;
  final CaptainStatus status;
  final DateTime? loginAt;

  const AuthModel({
    required this.id,
    required this.name,
    required this.code,
    required this.phone,
    required this.status,
    this.loginAt,
  });

  AuthModel copyWith({
    String? id,
    String? name,
    String? code,
    String? phone,
    CaptainStatus? status,
    DateTime? loginAt,
  }) {
    return AuthModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      loginAt: loginAt ?? this.loginAt,
    );
  }

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    final user = json.containsKey('user') ? json['user'] : json;

    return AuthModel(
      id: user['id'].toString(),
      name: user['name'],
      code: user['code'],
      phone: user['phone'],
      status: user['status'] == 'has_active_shift'
          ? CaptainStatus.active
          : CaptainStatus.nonActive,
      loginAt: user['login_at'] != null
          ? DateTime.tryParse(user['login_at'])
          : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'phone': phone,
      'status': status.name,
      'login_at': loginAt?.toIso8601String(),
    };
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
        status: json['user']['status'] == 'has_active_shift'
            ? CaptainStatus.active
            : CaptainStatus.active,
        loginAt: json['user']['login_at'] != null
            ? DateTime.tryParse(json['user']['login_at'])
            : null,
      ),
    );
  }
}
