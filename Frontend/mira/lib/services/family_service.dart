import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

const familyRoles = ['아빠', '엄마', '아들', '딸'];

class FamilyService {
  FamilyService._();
  static final instance = FamilyService._();

  final _functions = FirebaseFunctions.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<String?> fetchMyFamilyId(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data()?['familyId'] as String?;
  }

  Future<Map<String, dynamic>> createFamily(String role) async {
    final result = await _functions.httpsCallable('createFamily').call({'role': role});
    return Map<String, dynamic>.from(result.data as Map);
  }

  Future<Map<String, dynamic>> joinFamily(String inviteCode, String role) async {
    final result = await _functions.httpsCallable('joinFamily').call({
      'inviteCode': inviteCode,
      'role': role,
    });
    return Map<String, dynamic>.from(result.data as Map);
  }

  String messageFor(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'not-found':
        return '유효하지 않은 초대 코드예요.';
      case 'failed-precondition':
        return e.message ?? '가족에 참여할 수 없어요.';
      case 'unauthenticated':
        return '로그인이 필요해요.';
      default:
        return '오류가 발생했어요: ${e.message ?? e.code}';
    }
  }
}
