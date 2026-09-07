import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

// dog_room의 실제 돌봄 버튼(밥 주기/목욕/놀기/재우기)과 맞춤.
const careActions = ['🍚 밥 주기', '🛁 목욕', '🎾 놀기', '😴 재우기'];

String careDate([DateTime? now]) => (now ?? DateTime.now())
    .toUtc()
    .add(const Duration(hours: 1))
    .toIso8601String()
    .substring(0, 10);

class DailyCareService {
  DailyCareService._();
  static final instance = DailyCareService._();

  final _firestore = FirebaseFirestore.instance;

  Stream<Map<String, dynamic>> watchToday(String familyId) {
    late StreamController<Map<String, dynamic>> controller;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? subscription;
    Timer? timer;
    String? date;
    bool loading = false;
    bool closed = false;
    Future<void> refresh() async {
      if (closed || loading || date == careDate()) return;
      loading = true;
      try {
        final result = await FirebaseFunctions.instance
            .httpsCallable('ensureDailyCare')
            .call({'familyId': familyId});
        if (closed) return;
        final nextDate = result.data['dateId'] as String;
        await subscription?.cancel();
        if (closed) return;
        date = nextDate;
        controller.add({});
        subscription = _firestore
            .collection('families')
            .doc(familyId)
            .collection('dailyCare')
            .doc(nextDate)
            .snapshots()
            .listen(
              (doc) => controller.add({...?doc.data(), '_dateId': nextDate}),
              onError: (Object error, StackTrace stack) {
                date = null;
                controller.addError(error, stack);
              },
            );
      } catch (error, stack) {
        if (!closed) controller.addError(error, stack);
      } finally {
        loading = false;
      }
    }

    controller = StreamController<Map<String, dynamic>>(
      onListen: () {
        refresh();
        timer = Timer.periodic(const Duration(minutes: 1), (_) => refresh());
      },
      onCancel: () async {
        closed = true;
        timer?.cancel();
        await subscription?.cancel();
      },
    );
    return controller.stream;
  }

  Future<void> completeSelectedAction({
    required String familyId,
    required String uid,
    required String action,
  }) async {
    await FirebaseFunctions.instance.httpsCallable('completeDailyCare').call({
      'familyId': familyId,
      'action': action,
    });
  }
}
