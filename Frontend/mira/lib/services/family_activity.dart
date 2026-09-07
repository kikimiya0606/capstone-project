import 'package:cloud_firestore/cloud_firestore.dart';

DateTime koreaNow([DateTime? value]) =>
    (value ?? DateTime.now()).toUtc().add(const Duration(hours: 9));
DateTime weekStart(DateTime now) {
  final day = DateTime.utc(now.year, now.month, now.day);
  return day.subtract(Duration(days: day.weekday - 1));
}

DateTime? activityTime(dynamic value) =>
    value is Timestamp ? koreaNow(value.toDate()) : null;

class FamilyActivity {
  FamilyActivity({
    required this.members,
    required this.moments,
    required this.photos,
    required this.moods,
    required this.care,
    required this.now,
  });
  final List<Map<String, dynamic>> members, moments, photos, moods, care;
  final DateTime now;
  bool inWeek(Map<String, dynamic> d) {
    final t = activityTime(d['createdAt']);
    return t != null &&
        !t.isBefore(weekStart(now)) &&
        t.isBefore(weekStart(now).add(const Duration(days: 7)));
  }

  List<Map<String, dynamic>> get weekMoments => moments.where(inWeek).toList();
  List<Map<String, dynamic>> get weekPhotos => photos.where(inWeek).toList();
  int get participants {
    final ids = weekMoments.map((m) => m['authorUid']).toSet();
    return members.where((m) => ids.contains(m['uid'])).length;
  }

  bool get storyDone => members.isNotEmpty && participants == members.length;
  bool get photoDone => weekPhotos.isNotEmpty;
  int get questsDone => (storyDone ? 1 : 0) + (photoDone ? 1 : 0);
  int get likes => [
    ...weekMoments,
    ...weekPhotos,
  ].fold(0, (n, d) => n + ((d['likedBy'] as List?)?.length ?? 0));
  int get careCount => care.fold(
    0,
    (n, d) =>
        n +
        d.values.whereType<Map>().fold<int>(0, (total, record) {
          final values = [record['completedAt']];
          return total +
              values.where((value) {
                final time = activityTime(value);
                return time != null &&
                    !time.isBefore(weekStart(now)) &&
                    time.isBefore(weekStart(now).add(const Duration(days: 7)));
              }).length;
        }),
  );
  int get energy =>
      (weekMoments.length + weekPhotos.length) * 10 +
      likes * 2 +
      careCount * 5 +
      questsDone * 40;
  Map<String, Map<String, dynamic>> get todayMoods {
    final result = <String, Map<String, dynamic>>{};
    for (final m in moods) {
      final t = activityTime(m['createdAt']);
      final uid = m['userId'];
      if (uid is! String ||
          t == null ||
          t.year != now.year ||
          t.month != now.month ||
          t.day != now.day) {
        continue;
      }
      if (!members.any((member) => member['uid'] == uid)) continue;
      final old = result[uid];
      if (old == null || t.isAfter(activityTime(old['createdAt'])!)) {
        result[uid] = m;
      }
    }
    return result;
  }

  int? get moodPercent => todayMoods.isEmpty
      ? null
      : (todayMoods.values.where((m) => m['moodTag'] == '기쁨').length *
                100 /
                todayMoods.length)
            .round();
  String contextText() {
    String short(dynamic s, int max) {
      final text = '$s';
      return text.length > max ? text.substring(0, max) : text;
    }

    final ordered = [...moments]
      ..sort(
        (a, b) => (activityTime(b['createdAt']) ?? DateTime(2000)).compareTo(
          activityTime(a['createdAt']) ?? DateTime(2000),
        ),
      );
    return [
      '현재 날짜: ${now.toIso8601String().substring(0, 10)}',
      '가족 구성원:',
      ...members.map(
        (m) =>
            '${short(m['name'] ?? '이름 미설정', 80)} (${m['role'] ?? ''}), '
            '등록 생일: ${short(m['birthday'] ?? '미등록', 20)}, '
            '본인이 적은 소개/취향: ${short(m['bio'] ?? m['interests'] ?? '미등록', 300)}',
      ),
      '이번 주: 공유 글 ${weekMoments.length}, 사진 ${weekPhotos.length}, 좋아요 $likes, 돌봄 $careCount, 퀘스트 $questsDone/2',
      '최근 가족에게 공개한 글:',
      ...ordered
          .take(12)
          .map(
            (m) =>
                '${short(m['authorName'] ?? '이름 미설정', 80)}: ${short(m['body'] ?? '', 500)}',
          ),
    ].join('\n');
  }
}
