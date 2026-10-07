import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../models/land_record_7_12.dart';

class MahabhumiApiService {
  static const _endpoint = String.fromEnvironment('MAHABHUMI_712_API_URL');
  static final MahabhumiApiService _instance = MahabhumiApiService._internal();
  factory MahabhumiApiService() => _instance;
  MahabhumiApiService._internal();

  bool get isConfigured => _endpoint.isNotEmpty;

  Future<LandRecord712?> fetch712Record({
    required String district,
    required String taluka,
    required String village,
    required String surveyNumber,
  }) async {
    if (_endpoint.isEmpty) return null;

    final endpoint = Uri.parse(_endpoint);
    if (endpoint.scheme != 'https') {
      throw ArgumentError('The authorized 7/12 endpoint must use HTTPS.');
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Sign in before requesting an authorized 7/12 record.');
    }
    final token = await user.getIdToken();
    final uri = endpoint.replace(queryParameters: {
      ...endpoint.queryParameters,
      'district': district,
      'taluka': taluka,
      'village': village,
      'surveyNumber': surveyNumber,
    });
    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    }).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw HttpException(
        'The authorized 7/12 service returned HTTP ${response.statusCode}.',
        uri: uri,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
          'The 7/12 service returned an invalid response.');
    }
    return _parseResponse(decoded);
  }

  LandRecord712 _parseResponse(Map<String, dynamic> data) {
    final cropRecords = data['cropRecords'];
    final otherRights = data['otherRightsAndNotes'];
    if (cropRecords is! List || otherRights is! List) {
      throw const FormatException(
        'The 7/12 response must include cropRecords and otherRightsAndNotes lists.',
      );
    }

    return LandRecord712(
      district: _requiredString(data, 'district'),
      taluka: _requiredString(data, 'taluka'),
      village: _requiredString(data, 'village'),
      surveyGatNumber: _requiredString(data, 'surveyGatNumber'),
      hissaNumber: _requiredString(data, 'hissaNumber'),
      khataNumber: _requiredString(data, 'khataNumber'),
      khatedarNames: _requiredStringList(data, 'khatedarNames'),
      totalAreaHa: _requiredNumber(data, 'totalAreaHa'),
      potkharabaAreaHa: _requiredNumber(data, 'potkharabaAreaHa'),
      cultivableAreaHa: _requiredNumber(data, 'cultivableAreaHa'),
      jumaAakarniRs: _requiredNumber(data, 'jumaAakarniRs'),
      landType: _requiredString(data, 'landType'),
      tenureType: _requiredString(data, 'tenureType'),
      cropRecords: cropRecords.map((record) {
        if (record is! Map<String, dynamic>) {
          throw const FormatException('A crop record is malformed.');
        }
        return CropRecordItem(
          season: _requiredString(record, 'season'),
          cropName: _requiredString(record, 'cropName'),
          areaHa: _requiredNumber(record, 'areaHa'),
          irrigationSource: _requiredString(record, 'irrigationSource'),
          year: _requiredString(record, 'year'),
        );
      }).toList(),
      otherRightsAndNotes: otherRights.map((item) {
        if (item is! String) {
          throw const FormatException('An other-rights entry is malformed.');
        }
        return item;
      }).toList(),
      digitalSignStatus: _requiredString(data, 'digitalSignStatus'),
      extractDate: _requiredString(data, 'extractDate'),
      fetchedFromLiveApi: true,
      apiSource: 'Authorized Mahabhulekh API',
    );
  }

  String _requiredString(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('The 7/12 response is missing "$key".');
    }
    return value;
  }

  double _requiredNumber(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is! num || !value.isFinite) {
      throw FormatException('The 7/12 response is missing a valid "$key".');
    }
    return value.toDouble();
  }

  List<String> _requiredStringList(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is! List || value.any((item) => item is! String)) {
      throw FormatException(
          'The 7/12 response is missing a valid "$key" list.');
    }
    return value.cast<String>();
  }
}
