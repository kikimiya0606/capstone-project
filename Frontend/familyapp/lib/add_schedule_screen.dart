import 'package:flutter/material.dart';
import 'user_session.dart';

class AddScheduleScreen extends StatefulWidget {
  final DateTime selectedDay;

  const AddScheduleScreen({super.key, required this.selectedDay});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final _titleController = TextEditingController();
  final _memoController = TextEditingController();
  String _selectedAlarm = '이벤트 당일 (오전 9시)';

  final List<String> _alarmOptions = [
    '알림 없음',
    '이벤트 당일 (오전 9시)',
    '1일 전 (오전 9시)',
    '2일 전 (오전 9시)',
    '1주일 전 (오전 9시)',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final day = widget.selectedDay;
    final weekday = ['', '월', '화', '수', '목', '금', '토', '일'][day.weekday];
    final roleColor = UserSession.currentColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // 뒤로가기
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios, size: 20),
                padding: EdgeInsets.zero,
                color: Colors.grey[600],
              ),

              const SizedBox(height: 24),

              // 날짜 타이틀 + 작성자(역할) 색상 표시
              Row(
                children: [
                  Text(
                    '${day.month}월 ${day.day}일 $weekday',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF444444),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: roleColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (UserSession.currentRole != null) ...[
                    const SizedBox(width: 6),
                    Text(
                      UserSession.currentRole!,
                      style: TextStyle(
                        fontSize: 12,
                        color: roleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              // 입력 카드
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 일정 제목
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF444444),
                      ),
                      decoration: InputDecoration(
                        hintText: '일정 제목',
                        hintStyle: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[400],
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      ),
                    ),

                    Divider(color: Colors.grey[200], height: 24),

                    // 메모
                    TextField(
                      controller: _memoController,
                      maxLines: 4,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      decoration: InputDecoration(
                        hintText: '메모',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[400],
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),

                    Divider(color: Colors.grey[200], height: 24),

                    // 알림
                    GestureDetector(
                      onTap: () => _showAlarmPicker(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '알림',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedAlarm,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // 저장 버튼
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (_titleController.text.isNotEmpty) {
                      Navigator.pop(context, <String, Object>{
                        'title': _titleController.text,
                        'memo': _memoController.text,
                        'alarm': _selectedAlarm,
                        'color': roleColor,
                        'role': UserSession.currentRole ?? '',
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: roleColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '저장',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      // 하단 네비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF888888),
        unselectedItemColor: Colors.grey[400],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.eco_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.all_inclusive_outlined), label: ''),
        ],
      ),
    );
  }

  void _showAlarmPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF5F0EB),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _alarmOptions.map((option) => ListTile(
            title: Text(
              option,
              style: TextStyle(
                fontSize: 14,
                color: _selectedAlarm == option
                    ? const Color(0xFF888888)
                    : Colors.grey[600],
                fontWeight: _selectedAlarm == option
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
            trailing: _selectedAlarm == option
                ? const Icon(Icons.check, color: Color(0xFF888888), size: 18)
                : null,
            onTap: () {
              setState(() => _selectedAlarm = option);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }
}