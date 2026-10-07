import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar_app/services/mahabhumi_api_service.dart';

void main() {
  test('does not invent a 7/12 record without an authorized endpoint',
      () async {
    final service = MahabhumiApiService();
    expect(service.isConfigured, isFalse);

    final record = await service.fetch712Record(
      district: 'Nagpur',
      taluka: 'Ramtek',
      village: 'Talavade',
      surveyNumber: '14',
    );

    expect(record, isNull);
  });
}
