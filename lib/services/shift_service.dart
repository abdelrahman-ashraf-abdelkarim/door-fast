import 'package:captain_app/api/api.dart';
import 'package:captain_app/core/constants.dart';

class ShiftTimesResult {
  final bool hasActiveShift;
  final DateTime? shiftStart;

  ShiftTimesResult({required this.hasActiveShift, this.shiftStart});
}

class ShiftService {
  final Api _api;

  ShiftService({required Api api}) : _api = api;

  Future<ShiftTimesResult> fetchShiftTimes(String token) async {
    final data = await _api.get(
      url: '${AppConstants.baseUrl}/shift/times',
      token: token,
    );

    final hasActive = data['data']['has_active_shift'] == true;
    final raw = data['data']['shift_start'] as String?;
    return ShiftTimesResult(
      hasActiveShift: hasActive,
      shiftStart: raw != null ? DateTime.tryParse(raw) : null,
    );
  }
}
