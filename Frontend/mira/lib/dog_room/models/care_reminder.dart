import '../../services/daily_care_service.dart';

class CareReminder {
  const CareReminder(this.uid, this.role, this.action, this.date);
  final String uid;
  final String role;
  final String action;
  final String date;
  String get key => '$date:$uid:$action';
  String get message => '$role 기다리는 중! 오늘 $action 함께 해줄래?';
}

CareReminder? pendingCare(
  Map<String, dynamic> care,
  Map<String, dynamic> members,
  DateTime now,
) {
  if (care['_dateId'] != null && care['_dateId'] != careDate(now)) return null;
  final hour = now.toUtc().add(const Duration(hours: 9)).hour;
  // Don't wake the household overnight. Actions have separate due times.
  if (hour < 8) return null;
  const deadlines = [12, 18, 18, 21];
  for (var i = 0; i < careActions.length; i++) {
    if (hour < deadlines[i]) continue;
    for (final uid in members.keys.toList()..sort()) {
      final record = care[uid];
      if (record is Map &&
          record['action'] == careActions[i] &&
          record['completedAt'] == null) {
        return CareReminder(
          uid,
          members[uid] as String,
          careActions[i],
          careDate(now),
        );
      }
    }
  }
  return null;
}
