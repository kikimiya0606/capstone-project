/// 알림 종류
enum NotificationType {
  schedule, // 일정 알림 (예: 내일 아빠 생일)
  todayQuestion, // 오늘의 질문 답변 안내
  familyAnswer, // 가족이 오늘의 질문에 답변함
}

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final String timeLabel; // 예: '방금 전', '3시간 전', '어제'
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timeLabel,
    this.isRead = false,
  });
}