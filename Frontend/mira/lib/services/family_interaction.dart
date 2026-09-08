import 'package:cloud_firestore/cloud_firestore.dart';

import 'family_activity.dart';

/// 가족 구성원 간 댓글/좋아요 교류 횟수를 [from][to] 형태로 담는다.
/// 방향은 "누가 남의 글에 반응했는지" 기준 (from이 to의 글에 반응한 횟수).
class InteractionMatrix {
  InteractionMatrix(this._counts);
  final Map<String, Map<String, int>> _counts;

  /// 두 사람 사이의 교류 총합 (양방향 합산).
  int between(String a, String b) =>
      (_counts[a]?[b] ?? 0) + (_counts[b]?[a] ?? 0);

  /// 글을 하나 이상 올린 구성원들 중, 서로 교류가 가장 적은 순으로 정렬한 조합.
  List<(Map<String, dynamic>, Map<String, dynamic>, int)> weakestPairs(
    List<Map<String, dynamic>> members,
  ) {
    final pairs = <(Map<String, dynamic>, Map<String, dynamic>, int)>[];
    for (var i = 0; i < members.length; i++) {
      for (var j = i + 1; j < members.length; j++) {
        final a = members[i]['uid'], b = members[j]['uid'];
        if (a is! String || b is! String) continue;
        pairs.add((members[i], members[j], between(a, b)));
      }
    }
    pairs.sort((x, y) => x.$3.compareTo(y.$3));
    return pairs;
  }

  String summaryText(List<Map<String, dynamic>> members) {
    String label(Map<String, dynamic> m) =>
        '${m['name'] ?? '이름 미설정'}(${m['role'] ?? ''})';
    return weakestPairs(members)
        .map((p) => '${label(p.$1)} - ${label(p.$2)}: 교류 ${p.$3}회')
        .join('\n');
  }
}

/// moments/photos는 이미 실시간으로 구독 중이라 여기서는 그 문서들의 comments
/// 서브컬렉션만 한 번씩 읽어서 집계한다 (스트림으로 두기엔 글 개수만큼 구독이
/// 늘어나 비용이 커서, 인사이트 탭을 열 때 한 번 계산하는 걸로 충분하다).
class FamilyInteractionService {
  FamilyInteractionService._();
  static final instance = FamilyInteractionService._();

  final _firestore = FirebaseFirestore.instance;

  Future<InteractionMatrix> build({
    required String familyId,
    required List<Map<String, dynamic>> moments,
    required List<Map<String, dynamic>> photos,
    required DateTime since,
  }) async {
    final counts = <String, Map<String, int>>{};
    void add(String from, String to) {
      if (from == to || from.isEmpty || to.isEmpty) return;
      final row = counts.putIfAbsent(from, () => {});
      row[to] = (row[to] ?? 0) + 1;
    }

    final posts = [
      for (final m in moments) ('moments', m),
      for (final p in photos) ('photos', p),
    ];

    for (final (collection, post) in posts) {
      final createdAt = activityTime(post['createdAt']);
      if (createdAt != null && createdAt.isBefore(since)) continue;
      final authorUid = post['authorUid'];
      final postId = post['uid'];
      if (authorUid is! String || postId is! String) continue;

      for (final uid in (post['likedBy'] as List?) ?? const []) {
        if (uid is String) add(uid, authorUid);
      }

      final comments = await _firestore
          .collection('families')
          .doc(familyId)
          .collection(collection)
          .doc(postId)
          .collection('comments')
          .get();
      for (final doc in comments.docs) {
        final from = doc.data()['authorUid'];
        if (from is String) add(from, authorUid);
      }
    }

    return InteractionMatrix(counts);
  }
}
