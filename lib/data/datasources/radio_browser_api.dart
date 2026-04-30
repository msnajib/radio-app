import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../models/station.dart';

class RadioBrowserApi {
  final http.Client _client;

  RadioBrowserApi({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Station>> fetchByCountry(String country) async {
    final uri = Uri.parse(
      '${AppConstants.radioBrowserBaseUrl}/json/stations/bycountry/$country',
    );
    final response = await _client.get(uri, headers: _headers);
    _checkStatus(response);
    final List<dynamic> json = jsonDecode(response.body) as List<dynamic>;
    return json
        .map((e) => Station.fromJson(e as Map<String, dynamic>))
        .where((s) => s.streamUrl.isNotEmpty)
        .toList();
  }

  Future<List<Station>> searchByUuid(String uuid) async {
    final uri = Uri.parse(
      '${AppConstants.radioBrowserBaseUrl}/json/stations/byuuid/$uuid',
    );
    final response = await _client.get(uri, headers: _headers);
    _checkStatus(response);
    final List<dynamic> json = jsonDecode(response.body) as List<dynamic>;
    return json
        .map((e) => Station.fromJson(e as Map<String, dynamic>))
        .where((s) => s.streamUrl.isNotEmpty)
        .toList();
  }

  Future<List<Station>> search(String query) async {
    final uri = Uri.parse(
      '${AppConstants.radioBrowserBaseUrl}/json/stations/byname/${Uri.encodeComponent(query)}',
    );
    final response = await _client.get(uri, headers: _headers);
    _checkStatus(response);
    final List<dynamic> json = jsonDecode(response.body) as List<dynamic>;
    return json
        .map((e) => Station.fromJson(e as Map<String, dynamic>))
        .where((s) => s.streamUrl.isNotEmpty)
        .toList();
  }

  static const Map<String, String> _headers = {
    'User-Agent': 'RadioApp/1.0',
    'Accept': 'application/json',
  };

  void _checkStatus(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception('Radio Browser API error: ${response.statusCode}');
    }
  }

  void dispose() => _client.close();
}
