enum CaptainStatus { active, nonActive }

enum DeliveryType { delivery, reserve }

class AuthModel {
  final String id;
  final String name;
  final String code;
  final String phone;
  final CaptainStatus status;
  final DateTime? loginAt;
  final DeliveryType role;

  const AuthModel({
    required this.id,
    required this.name,
    required this.code,
    required this.phone,
    required this.status,
    this.loginAt,
    this.role = DeliveryType.delivery,
  });

  AuthModel copyWith({
    String? id,
    String? name,
    String? code,
    String? phone,
    CaptainStatus? status,
    DateTime? loginAt,
    DeliveryType? role,
  }) {
    return AuthModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      loginAt: loginAt ?? this.loginAt,
      role: role ?? this.role,
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
      role: (user['role'] as String?) == 'reserve'
          ? DeliveryType.reserve
          : DeliveryType.delivery,
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
      'role': role == DeliveryType.reserve ? 'reserve' : 'delivery',
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

  factory AuthResponse.fromJson(
    Map<String, dynamic> json, {
    DeliveryType role = DeliveryType.delivery,
  }) {
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
        role: role,
      ),
    );
  }
}
