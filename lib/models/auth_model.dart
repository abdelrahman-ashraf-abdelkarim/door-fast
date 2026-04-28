enum CaptainStatus { active, nonActive }

class AuthModel {
  final String id;
  final String name;
  final CaptainStatus status;

  const AuthModel({required this.id, required this.name, required this.status});

  AuthModel copyWith({String? id, String? name, CaptainStatus? status}) {
    return AuthModel(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
    );
  }

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      id: json['id'],
      name: json['name'],
      status: json['status'] == 'active'
          ? CaptainStatus.active
          : CaptainStatus.nonActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'status': status.name};
  }
}
