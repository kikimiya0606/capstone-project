import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mira/services/family_activity.dart';

void main() {
  final monday = DateTime.utc(2026, 9, 7);
  Timestamp stamp(DateTime koreanTime) =>
      Timestamp.fromDate(koreanTime.subtract(const Duration(hours: 9)));
  FamilyActivity make({
    List<Map<String, dynamic>> moments = const [],
    List<Map<String, dynamic>> photos = const [],
    List<Map<String, dynamic>> moods = const [],
    DateTime? now,
  }) => FamilyActivity(
    familyId: 'f1',
    members: [
      {'uid': 'a'},
      {'uid': 'b'},
    ],
    moments: moments,
    photos: photos,
    moods: moods,
    care: [],
    now: now ?? monday,
  );
  test('No fake scores or completed quests before activity', () {
    final data = make();
    expect(data.energy, 0);
    expect(data.moodPercent, isNull);
    expect(data.questsDone, 0);
  });
  test(
    'Weekly participation deduplicates people and resets on Korean Monday',
    () {
      final docs = [
        {'authorUid': 'a', 'createdAt': stamp(monday)},
        {'authorUid': 'a', 'createdAt': stamp(monday)},
        {'authorUid': 'b', 'createdAt': stamp(monday)},
        {
          'authorUid': 'b',
          'createdAt': stamp(monday.subtract(const Duration(seconds: 1))),
        },
      ];
      final photos = [
        {'createdAt': stamp(monday)},
      ];
      final data = make(moments: docs, photos: photos);
      expect(data.participants, 2);
      expect(data.questsDone, 2);
      expect(data.energy, 120);
      expect(
        make(
          moments: docs,
          photos: photos,
          now: monday.add(const Duration(days: 7)),
        ).energy,
        0,
      );
      expect(
        make(
          moments: docs.where((d) => d['authorUid'] == 'a').toList(),
        ).storyDone,
        false,
      );
    },
  );
  test('Mood uses each member latest self-reported mood today', () {
    final data = make(
      moods: [
        {'userId': 'a', 'moodTag': '슬픔', 'createdAt': stamp(monday)},
        {
          'userId': 'a',
          'moodTag': '기쁨',
          'createdAt': stamp(monday.add(const Duration(hours: 1))),
        },
        {'userId': 'b', 'moodTag': '불안', 'createdAt': stamp(monday)},
        {'userId': 'outsider', 'moodTag': '기쁨', 'createdAt': stamp(monday)},
      ],
    );
    expect(data.todayMoods.length, 2);
    expect(data.moodPercent, 50);
  });
  test('Insight context excludes private diary and image bytes', () {
    final data = make(
      moods: [
        {'moodText': 'private diary'},
      ],
      photos: [
        {'photo': 'secret image bytes'},
      ],
    );
    expect(data.contextText(), isNot(contains('private diary')));
    expect(data.contextText(), isNot(contains('secret image bytes')));
  });
}
