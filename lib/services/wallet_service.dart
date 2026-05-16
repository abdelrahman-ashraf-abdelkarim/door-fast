import 'package:captain_app/api/api.dart';
import 'package:captain_app/models/wallet_model.dart';

class WalletService {
  final Api _api;
  WalletService({required Api api}) : _api = api;

  Future<WalletModel> fetchWalletStatement(
    String token, {
    int page = 1,
    String? from,
    String? to,
  }) async {
    final queryParams = {
      'page': page.toString(),
      if (from != null) 'from': from,
      if (to != null) 'to': to,
    };

    final uri = Uri.parse(
      '${_api.baseUrl}/wallet/statement',
    ).replace(queryParameters: queryParams);

    final data = await _api.get(url: uri.toString(), token: token);
    return WalletModel.fromJson(data);
  }
}
