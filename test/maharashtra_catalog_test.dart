import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar_app/models/maharashtra_districts.dart';
import 'package:vanrozgar_app/services/village_catalog_service.dart';

void main() {
  test('district selector covers all 36 Maharashtra districts', () {
    expect(MaharashtraDataCatalog.districts, hasLength(36));
  });

  test('sample village catalog is not restricted to Nagpur', () {
    final districts = VillageCatalogService()
        .buildCatalog()
        .map((village) => village.district)
        .toSet();

    expect(districts, contains('Gadchiroli'));
    expect(districts, contains('Nandurbar'));
    expect(districts, contains('Palghar'));
  });
}
