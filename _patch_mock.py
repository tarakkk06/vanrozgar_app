from pathlib import Path

p = Path(r"c:\Users\TARAK\OneDrive\Documents\vanrozgar_app\lib\services\mock_data_service.dart")
text = p.read_text(encoding="utf-8")
start = text.find("  List<Village> getVillages() {")
end = text.find("  List<ResourceItem> getResourcesForVillage(String villageId) {")
if start < 0 or end < 0:
    raise SystemExit(f"markers not found {start} {end}")
new_fn = """  List<Village> getVillages() {
    return VillageCatalogService().buildCatalog();
  }

"""
text = text[:start] + new_fn + text[end:]
text = text.replace(
    """  List<ResourceItem> getResourcesForVillage(String villageId) {
    return [
      ResourceItem(
        id: 'res_check_dam_1',
        villageId: villageId,
        name: 'Talavade Nala Check Dam',
        marathiName: 'तळवडे नाला सिमेंट बंधारा',
        type: ResourceType.checkDam,
        latitude: 18.5674,
        longitude: 73.9123,""",
    """  List<ResourceItem> getResourcesForVillage(Village village) {
    final villageId = village.id;
    final lat = village.latitude;
    final lon = village.longitude;
    final vName = village.name;
    return [
      ResourceItem(
        id: '${villageId}_check_dam',
        villageId: villageId,
        name: '$vName Nala Check Dam',
        marathiName: '$vName नाला सिमेंट बंधारा',
        type: ResourceType.checkDam,
        latitude: lat + 0.006,
        longitude: lon - 0.004,""",
    1,
)
pairs = [
    ("name: 'Gaon Talao (Perennial Pond)',", "name: '$vName Gaon Talao (Perennial Pond)',"),
    ("latitude: 18.5690,", "latitude: lat + 0.002,"),
    ("longitude: 73.9145,", "longitude: lon + 0.003,"),
    ("latitude: 18.5640,", "latitude: lat - 0.005,"),
    ("longitude: 73.9100,", "longitude: lon - 0.007,"),
    ("latitude: 18.5720,", "latitude: lat + 0.008,"),
    ("longitude: 73.9180,", "longitude: lon + 0.006,"),
    ("latitude: 18.5610,", "latitude: lat - 0.008,"),
    ("longitude: 73.9050,", "longitude: lon - 0.010,"),
    ("latitude: 18.5680,", "latitude: lat + 0.001,"),
    ("longitude: 73.9160,", "longitude: lon + 0.004,"),
    (
        "locationDescription: 'Eastern boundary joining Ramtek canal network',",
        "locationDescription: 'Eastern boundary joining local canal network',",
    ),
    ("latitude: 18.5740,", "latitude: lat + 0.010,"),
    ("longitude: 73.9210,", "longitude: lon + 0.008,"),
    ("latitude: 18.5600,", "latitude: lat - 0.009,"),
    ("longitude: 73.9020,", "longitude: lon - 0.012,"),
    ("holder712Name: 'Gram Sabha Talavade (CFR Title Holder)',", "holder712Name: 'Gram Sabha $vName (CFR Title Holder)',"),
    ("holder712Name: 'Gram Sabha Talavade (FRA Sec 3(1)(i))',", "holder712Name: 'Gram Sabha $vName (FRA Sec 3(1)(i))',"),
    ("id: 'res_pond_1',", "id: '${villageId}_pond',"),
    ("id: 'res_bamboo_1',", "id: '${villageId}_bamboo',"),
    ("id: 'res_grazing_1',", "id: '${villageId}_grazing',"),
    ("id: 'res_medicinal_1',", "id: '${villageId}_medicinal',"),
    ("id: 'res_well_1',", "id: '${villageId}_well',"),
    ("id: 'res_canal_1',", "id: '${villageId}_canal',"),
    ("id: 'res_sacred_grove_1',", "id: '${villageId}_sacred',"),
]
for a, b in pairs:
    text = text.replace(a, b, 1)
text = text.replace("holder712Name: 'Gram Sabha Talavade',", "holder712Name: 'Gram Sabha $vName',")
p.write_text(text, encoding="utf-8")
print("ok")
