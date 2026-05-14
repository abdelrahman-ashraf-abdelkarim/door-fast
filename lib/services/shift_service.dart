import 'package:captain_app/api/api.dart';
import 'package:captain_app/core/constants.dart';

class ShiftService {
  final Api _api;
  ShiftService({required Api api}) : _api = api;

  Future<DateTime?> fetchShiftStartTime(String token) async {
    final data = await _api.get(
      url: '${AppConstants.baseUrl}/shift/times',
      token: token,
    );
    if (data['success'] == true && data['data']['has_active_shift'] == true) {
      final raw = data['data']['shift_start'] as String?;
      return raw != null ? DateTime.tryParse(raw) : null;
    }
    return null;
  }

  Future<DateTime?> fetchDashboardData(String token) async {
    final data = await _api.get(
      url: '${AppConstants.baseUrl}/dashboard',
      token: token,
    );
    if (data['success'] == true && data['data']['has_active_shift'] == true) {
      final raw = data['data']['shift_start'] as String?;
      return raw != null ? DateTime.tryParse(raw) : null;
    }
    return null;
  }
}