import 'package:flutter/material.dart';
import 'add_schedule_screen.dart';
import 'home_screen.dart';
import 'question_list_screen.dart';
import 'garden_screen.dart';
import 'calendar_screen.dart';
import 'mypage_screen.dart';

class ScheduleDetailScreen extends StatefulWidget {
  final DateTime selectedDay;
  final List<Map<String, Object>> initialEvents;

  const ScheduleDetailScreen({
    super.key,
    required this.selectedDay,
    this.initialEvents = const [],
  });

  @override
  State<ScheduleDetailScreen> createState() => _ScheduleDetailScreenState();
}

class _ScheduleDetailScreenState extends State<ScheduleDetailScreen> {
  late List<Map<String, Object>> _schedules;

  @override
  void initState() {
    super.initState();
    _schedules = List<Map<String, Object>>.from(
      widget.initialEvents.map((e) => Map<String, Object>.from(e)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final day = widget.selectedDay;
    final weekday = ['', '월', '화', '수', '목', '금', '토', '일'][day.weekday];

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _schedules);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F0EB),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                IconButton(
                  onPressed: () => Navigator.pop(context, _schedules),
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  padding: EdgeInsets.zero,
                  color: Colors.grey[600],
                ),

                const SizedBox(height: 24),

                Text(
                  '${day.month}월 ${day.day}일 $weekday',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF444444),
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Stack(
                      children: [
                        _schedules.isEmpty
                            ? Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            '이 날의 일정이 없습니다.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[400],
                            ),
                          ),
                        )
                            : ListView.builder(
                          itemCount: _schedules.length,
                          itemBuilder: (context, index) {
                            final event = _schedules[index];
                            final color =
                                event['color'] as Color? ?? const Color(0xFFBBA98A);
                            final role = event['role'] as String?;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
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
                                      event['title'] as String? ?? '',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                  if (role != null && role.isNotEmpty) ...[
                                    Text(
                                      role,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: color,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _schedules.removeAt(index);
                                      });
                                    },
                                    child: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push<Map<String, Object>>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddScheduleScreen(
                                    selectedDay: widget.selectedDay,
                                  ),
                                ),
                              );
                              if (result != null) {
                                setState(() {
                                  _schedules.add(result);
                                });
                              }
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8E0D5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 22,
                                color: Color(0xFF888888),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

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
              Navigator.pop(context, _schedules);
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
      ),
    );
  }
}