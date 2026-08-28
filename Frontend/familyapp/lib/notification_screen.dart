import 'package:flutter/material.dart';
import 'notification_item.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  // TODO: 실제로는 서버/로컬 알림 데이터로 교체하세요.
  static final List<NotificationItem> _notifications = [
    NotificationItem(
      id: 'n1',
      type: NotificationType.familyAnswer,
      title: '아빠가 답장했어요',
      message: '오늘의 질문에 아빠가 답변을 남겼어요. 지금 확인해보세요!',
      timeLabel: '방금 전',
      isRead: false,
    ),
    NotificationItem(
      id: 'n2',
      type: NotificationType.todayQuestion,
      title: '오늘의 질문이 도착했어요',
      message: '"최근에 가족들에게 쑥스러워서 말하지 못했던 고마운 순간이나 미안했던 일이 있다면?"',
      timeLabel: '3시간 전',
      isRead: false,
    ),
    NotificationItem(
      id: 'n3',
      type: NotificationType.schedule,
      title: '다가오는 일정이 있어요',
      message: '5월 21일 목요일, 아빠의 일정이 있어요.',
      timeLabel: '어제',
      isRead: true,
    ),
    NotificationItem(
      id: 'n4',
      type: NotificationType.familyAnswer,
      title: '엄마가 답장했어요',
      message: '오늘의 질문에 엄마가 답변을 남겼어요. 지금 확인해보세요!',
      timeLabel: '2일 전',
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  padding: const EdgeInsets.only(left: 16),
                  color: Colors.grey[600],
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      '알림',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            Expanded(
              child: _notifications.isEmpty
                  ? Center(
                child: Text(
                  '아직 도착한 알림이 없어요.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[400],
                  ),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  return _NotificationTile(item: _notifications[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem item;
  const _NotificationTile({required this.item});

  ({IconData icon, Color color}) get _iconStyle {
    switch (item.type) {
      case NotificationType.schedule:
        return (icon: Icons.calendar_today_outlined, color: const Color(0xFF7EA6D8));
      case NotificationType.todayQuestion:
        return (icon: Icons.chat_bubble_outline, color: const Color(0xFFBBA98A));
      case NotificationType.familyAnswer:
        return (icon: Icons.favorite_outline, color: const Color(0xFFD98A8A));
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _iconStyle;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.isRead ? Colors.white : const Color(0xFFFDF6F2),
        borderRadius: BorderRadius.circular(12),
        border: item.isRead
            ? null
            : Border.all(color: const Color(0xFFF0DCCF), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: style.color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(style.icon, size: 18, color: style.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    if (!item.isRead)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD98A8A),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.message,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.timeLabel,
                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}