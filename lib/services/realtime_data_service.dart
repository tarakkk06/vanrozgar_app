import 'package:cloud_firestore/cloud_firestore.dart';

class RealtimeDataService {
  CollectionReference<Map<String, dynamic>> _resourceCollection(
    String villageId,
  ) {
    return FirebaseFirestore.instance
        .collection('villages')
        .doc(villageId)
        .collection('resources');
  }

  Stream<List<Map<String, dynamic>>> watchResourceVerifications(
    String villageId,
  ) {
    return _resourceCollection(villageId).snapshots().map(
          (snapshot) => snapshot.docs
              .map((document) => <String, dynamic>{
                    'id': document.id,
                    ...document.data(),
                  })
              .toList(),
        );
  }

  Future<void> saveResourceVerification({
    required String villageId,
    required String resourceId,
    required double availability,
    required double condition,
    required double seasonality,
    required double reach,
    required String reason,
    required String verifiedBy,
    required String note,
    required String status,
  }) {
    return _resourceCollection(villageId).doc(resourceId).set(
      {
        'availabilityA': availability,
        'conditionC': condition,
        'seasonalityS': seasonality,
        'reachR': reach,
        'reason': reason,
        'verifiedBy': verifiedBy,
        'verificationNote': note,
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
