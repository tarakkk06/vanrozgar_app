class CropRecordItem {
  final String season; // Kharif, Rabi, Perennial (हंगाम)
  final String cropName; // भात, सोयाबीन, बांबू, गवत
  final double areaHa; // लागवडीखालील क्षेत्र
  final String irrigationSource; // विहीर, कालवा, पाऊस, तलाव
  final String year;

  const CropRecordItem({
    required this.season,
    required this.cropName,
    required this.areaHa,
    required this.irrigationSource,
    required this.year,
  });
}

class LandRecord712 {
  final String district;
  final String taluka;
  final String village;
  final String surveyGatNumber; // सर्व्हे / गट क्रमांक
  final String hissaNumber; // हिस्सा क्रमांक
  final String khataNumber; // खाते क्रमांक
  final List<String> khatedarNames; // भूधारकाचे नाव
  final double totalAreaHa; // एकूण क्षेत्र (हेक्टर.आर)
  final double potkharabaAreaHa; // पोटखराब क्षेत्र (अकृषक/नाले/पडीक)
  final double cultivableAreaHa; // लागवडयोग्य क्षेत्र
  final double jumaAakarniRs; // जुमा आकारणी (रु. पैसे)
  final String landType; // जिरायत, बागायत, वनजमीन, शासकीय
  final String tenureType; // भोगवटादार वर्ग १ / वर्ग २ / CFR सामुदायिक हक्क
  final List<CropRecordItem> cropRecords; // पिक पाहणी नोंद
  final List<String>
      otherRightsAndNotes; // इतर हक्क, बोजा व वन हक्क प्रमाणपत्र नोंद
  final String digitalSignStatus; // डिजिटल स्वाक्षरी प्रमाणित
  final String extractDate;
  final bool fetchedFromLiveApi;
  final String apiSource;

  const LandRecord712({
    required this.district,
    required this.taluka,
    required this.village,
    required this.surveyGatNumber,
    required this.hissaNumber,
    required this.khataNumber,
    required this.khatedarNames,
    required this.totalAreaHa,
    required this.potkharabaAreaHa,
    required this.cultivableAreaHa,
    required this.jumaAakarniRs,
    required this.landType,
    required this.tenureType,
    required this.cropRecords,
    required this.otherRightsAndNotes,
    this.digitalSignStatus = 'Digitally Signed by Revenue Dept (e-Mahabhumi)',
    required this.extractDate,
    this.fetchedFromLiveApi = false,
    this.apiSource = 'Not fetched from an authorized service',
  });

  bool get isCfrCommunityLand {
    return tenureType.contains('CFR') ||
        otherRightsAndNotes
            .any((n) => n.contains('वन हक्क कायदा') || n.contains('FRA'));
  }
}
