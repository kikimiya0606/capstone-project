import 'package:flutter_test/flutter_test.dart';
import 'package:mira/dog_room/models/care_reminder.dart';
import 'package:mira/services/daily_care_service.dart';

void main() {
  test('resuming on a later day does not announce stale assignments', () {
    expect(
      pendingCare(
        {
          '_dateId': '2026-09-06',
          'a': {'action': careActions[0], 'completedAt': null},
        },
        {'a': '아빠'},
        DateTime.parse('2026-09-07T12:00:00+09:00'),
      ),
      isNull,
    );
  });
  test(
    'care date resets at 8 AM Korea time, independent of device timezone',
    () {
      expect(
        careDate(DateTime.parse('2026-01-01T07:59:59+09:00')),
        '2025-12-31',
      );
      expect(
        careDate(DateTime.parse('2026-01-01T08:00:00+09:00')),
        '2026-01-01',
      );
    },
  );

  test(
    'feeding reminder uses actual assignee and disappears on completion',
    () {
      final care = {
        'a': {'action': careActions[0], 'completedAt': null},
      };
      final now = DateTime.parse('2026-09-07T12:00:00+09:00');
      expect(pendingCare(care, {'a': '엄마'}, now)?.role, '엄마');
      expect(
        pendingCare(care, {
          'a': '엄마',
        }, now.subtract(const Duration(seconds: 1))),
        isNull,
      );
      care['a']!['completedAt'] = 'saved';
      expect(pendingCare(care, {'a': '엄마'}, now), isNull);
    },
  );

  test('departed members and overnight do not trigger reminders', () {
    final care = {
      'a': {'action': careActions[0], 'completedAt': null},
    };
    expect(
      pendingCare(care, {}, DateTime.parse('2026-09-07T12:00:00+09:00')),
      isNull,
    );
    expect(
      pendingCare(care, {
        'a': '아빠',
      }, DateTime.parse('2026-09-07T01:00:00+09:00')),
      isNull,
    );
  });

  test('sleep has a later deadline than feeding', () {
    final care = {
      'a': {'action': careActions[3], 'completedAt': null},
    };
    expect(
      pendingCare(care, {
        'a': '아빠',
      }, DateTime.parse('2026-09-07T20:59:59+09:00')),
      isNull,
    );
    expect(
      pendingCare(care, {
        'a': '아빠',
      }, DateTime.parse('2026-09-07T21:00:00+09:00')),
      isNotNull,
    );
  });
}
