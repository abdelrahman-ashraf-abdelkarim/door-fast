enum CaptainStatus { active, nonActive }

enum ShiftStatus { active, nonActive }

enum DeliveryType { delivery, reserve }

class AuthModel {
  final String id;
  final String name;
  final String code;
  final String phone;
  final CaptainStatus status;
  final ShiftStatus shiftStatus;
  final DateTime? loginAt;
  final DeliveryType role;

  const AuthModel({
    required this.id,
    required this.name,
    required this.code,
    required this.phone,
    required this.status,
    this.shiftStatus = ShiftStatus.nonActive,
    this.loginAt,
    this.role = DeliveryType.delivery,
  });

  AuthModel copyWith({
    String? id,
    String? name,
    String? code,
    String? phone,
    CaptainStatus? status,
    ShiftStatus? shiftStatus,
    DateTime? loginAt,
    DeliveryType? role,
  }) {
    return AuthModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      shiftStatus: shiftStatus ?? this.shiftStatus,
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
      status: (user['status'] ?? 'active') == 'active'
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
  final ShiftModel? shift;

  AuthResponse({
    required this.success,
    required this.token,
    required this.user,
    this.shift,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final loginData = json['login'] as Map<String, dynamic>;
    final statusData = json['status'] as Map<String, dynamic>;
    final timesData =
        (json['times'] as Map<String, dynamic>)['data'] as Map<String, dynamic>;

    final userJson = loginData['user'] as Map<String, dynamic>;
    final hasActiveShift = statusData['shift_active'] ?? false;
    final shiftStartRaw = timesData['shift_start'] as String?;
    final shiftStart = shiftStartRaw != null
        ? DateTime.tryParse(shiftStartRaw)
        : null;

    return AuthResponse(
      success: loginData['success'],
      token: loginData['token'],
      user: AuthModel.fromJson(userJson).copyWith(
        status: statusData['shift_active'] == true
            ? CaptainStatus.active
            : CaptainStatus.nonActive,
        shiftStatus: hasActiveShift
            ? ShiftStatus.active
            : ShiftStatus.nonActive,
        loginAt: shiftStart,
      ),
      shift: ShiftModel(
        hasActiveShift: hasActiveShift,
        shiftStart: shiftStart,
        shiftEnd: timesData['shift_end'] != null
            ? DateTime.tryParse(timesData['shift_end'])
            : null,
        durationMinutes: timesData['duration_minutes'] ?? 0,
      ),
    );
  }
}

class ShiftModel {
  final bool hasActiveShift;
  final DateTime? shiftStart;
  final DateTime? shiftEnd;
  final int durationMinutes;

  const ShiftModel({
    required this.hasActiveShift,
    this.shiftStart,
    this.shiftEnd,
    required this.durationMinutes,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      hasActiveShift: json['has_active_shift'] ?? false,
      shiftStart: json['shift_start'] != null
          ? DateTime.tryParse(json['shift_start'])
          : null,
      shiftEnd: json['shift_end'] != null
          ? DateTime.tryParse(json['shift_end'])
          : null,
      durationMinutes: json['duration_minutes'] ?? 0,
    );
  }
}
