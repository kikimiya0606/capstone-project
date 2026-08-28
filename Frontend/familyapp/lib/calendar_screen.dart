import 'package:flutter/material.dart';
import 'schedule_detail_screen.dart';
import 'home_screen.dart';
import 'question_list_screen.dart';
import 'garden_screen.dart';
import 'mypage_screen.dart';
import 'user_session.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime(2026, 5);
  DateTime? _selectedDay = DateTime(2026, 5, 21);

  // 날짜별 이벤트: title, color(역할색 or 공휴일=빨강), role(공휴일이면 null), isHoliday
  Map<String, List<Map<String, Object>>> _events = {
    '2026-05-05': [
      {'title': '어린이날', 'color': Colors.red, 'isHoliday': true}
    ],
    '2026-05-24': [
      {'title': '부처님오신날', 'color': Colors.red, 'isHoliday': true}
    ],
    '2026-05-25': [
      {'title': '대체공휴일', 'color': Colors.red, 'isHoliday': true}
    ],
    '2026-05-21': [
      {
        'title': '저녁 7시 영등포에서 회식',
        'color': Colors.blue,
        'role': '아빠',
        'isHoliday': false,
      }
    ],
    '2026-05-27': [
      {
        'title': '현장체험학습',
        'color': Colors.orange,
        'role': '딸',
        'isHoliday': false,
      }
    ],
  };

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  List<Map<String, Object>> _getEvents(DateTime date) =>
      _events[_dateKey(date)] ?? [];

  void _prevMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthName = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ][_focusedMonth.month];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // 상단 뒤로가기 + 가족 구성원 색상 점
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                    padding: EdgeInsets.zero,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: FamilyRole.roleColors.values.map((color) => Container(
                      margin: const EdgeInsets.only(right: 6),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    )).toList(),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 캘린더 카드
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 월 헤더
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$monthName ${_focusedMonth.year}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF444444),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _prevMonth,
                              icon: const Icon(Icons.chevron_left),
                              padding: EdgeInsets.zero,
                              color: Colors.grey[600],
                            ),
                            IconButton(
                              onPressed: _nextMonth,
                              icon: const Icon(Icons.chevron_right),
                              padding: EdgeInsets.zero,
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 요일 헤더
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
                          .asMap()
                          .entries
                          .map((e) => SizedBox(
                        width: 36,
                        child: Center(
                          child: Text(
                            e.value,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: e.key == 0
                                  ? Colors.red
                                  : e.key == 6
                                  ? const Color(0xFF0048FF)
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      ))
                          .toList(),
                    ),

                    const SizedBox(height: 8),

                    _buildCalendarGrid(),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 이번 달 가족 일정 목록 (날짜순)
              Text(
                '$monthName의 가족 일정',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF444444),
                ),
              ),
              const SizedBox(height: 12),
              _buildMonthEventList(),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      // 하단 네비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QuestionListScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GardenScreen()),
            );
          } else if (index == 3) {
            // 현재 페이지
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyPageScreen()),
            );
          }
        },
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

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final startWeekday = firstDay.weekday % 7;

    List<Widget> dayWidgets = [];

    for (int i = 0; i < startWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 36, height: 48));
    }

    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final isSelected = _selectedDay != null &&
          _selectedDay!.year == date.year &&
          _selectedDay!.month == date.month &&
          _selectedDay!.day == date.day;
      final isSunday = date.weekday % 7 == 0;
      final isSaturday = date.weekday == 6;

      final dayEvents = _getEvents(date);
      final holiday = dayEvents.where((e) => e['isHoliday'] == true).toList();
      final schedules =
      dayEvents.where((e) => e['isHoliday'] != true).toList();

      // 숫자 색: 공휴일이면 빨강, 그게 아니면 그날 첫 일정의 역할 색, 없으면 요일 기본색
      Color numberColor;
      if (isSelected) {
        numberColor = Colors.white;
      } else if (holiday.isNotEmpty) {
        numberColor = Colors.red;
      } else if (schedules.isNotEmpty) {
        numberColor = schedules.first['color'] as Color;
      } else if (isSunday) {
        numberColor = Colors.red;
      } else if (isSaturday) {
        numberColor = const Color(0xFF0048FF);
      } else {
        numberColor = const Color(0xFF444444);
      }

      dayWidgets.add(
        GestureDetector(
          onTap: () async {
            setState(() => _selectedDay = date);
            final updatedSchedules =
            await Navigator.push<List<Map<String, Object>>>(
              context,
              MaterialPageRoute(
                builder: (_) => ScheduleDetailScreen(
                  selectedDay: date,
                  initialEvents: dayEvents,
                ),
              ),
            );
            if (updatedSchedules != null) {
              setState(() {
                _events[_dateKey(date)] = updatedSchedules;
              });
            }
          },
          child: SizedBox(
            width: 36,
            height: 52,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF888888)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: numberColor,
                      ),
                    ),
                  ),
                ),
                if (holiday.isNotEmpty)
                  Text(
                    holiday.first['title'] as String,
                    style: const TextStyle(
                      fontSize: 7,
                      color: Colors.red,
                    ),
                    overflow: TextOverflow.ellipsis,
                  )
                else if (schedules.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: schedules
                        .take(3)
                        .map((e) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: e['color'] as Color,
                        shape: BoxShape.circle,
                      ),
                    ))
                        .toList(),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    List<Widget> rows = [];
    for (int i = 0; i < dayWidgets.length; i += 7) {
      final end = (i + 7 > dayWidgets.length) ? dayWidgets.length : i + 7;
      final rowItems = dayWidgets.sublist(i, end);
      while (rowItems.length < 7) {
        rowItems.add(const SizedBox(width: 36, height: 48));
      }
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: rowItems,
      ));
    }

    return Column(children: rows);
  }

  // 이번 달 가족 일정을 날짜순으로 모아 보여주는 리스트 (공휴일 제외)
  Widget _buildMonthEventList() {
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);

    final List<MapEntry<DateTime, Map<String, Object>>> monthEvents = [];
    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      for (final event in _getEvents(date)) {
        if (event['isHoliday'] != true) {
          monthEvents.add(MapEntry(date, event));
        }
      }
    }

    if (monthEvents.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          '이번 달 등록된 가족 일정이 없습니다.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[400],
          ),
        ),
      );
    }

    return Column(
      children: monthEvents.map((entry) {
        final date = entry.key;
        final event = entry.value;
        final color = event['color'] as Color;
        final role = event['role'] as String?;

        return GestureDetector(
          onTap: () async {
            setState(() => _selectedDay = date);
            final updatedSchedules =
            await Navigator.push<List<Map<String, Object>>>(
              context,
              MaterialPageRoute(
                builder: (_) => ScheduleDetailScreen(
                  selectedDay: date,
                  initialEvents: _getEvents(date),
                ),
              ),
            );
            if (updatedSchedules != null) {
              setState(() {
                _events[_dateKey(date)] = updatedSchedules;
              });
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 46,
                  child: Text(
                    '${date.month}/${date.day}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF888888),
                    ),
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    event['title'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (role != null && role.isNotEmpty)
                  Text(
                    role,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}