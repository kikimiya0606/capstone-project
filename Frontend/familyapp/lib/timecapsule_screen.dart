import 'package:flutter/material.dart';
import 'timecapsule_detail_screen.dart';
import 'home_screen.dart';
import 'question_list_screen.dart';
import 'garden_screen.dart';
import 'calendar_screen.dart';
import 'mypage_screen.dart';

class TimeCapsuleScreen extends StatelessWidget {
  const TimeCapsuleScreen({super.key});

  final List<Map<String, String>> _memories = const [
    {'date': '2025-12-25', 'title': '크리스마스'},
    {'date': '2025-05-08', 'title': '어버이날'},
    {'date': '2025-05-05', 'title': '어린이날'},
    {'date': '2025-03-19', 'title': '아빠 생일'},
    {'date': '2025-02-10', 'title': '서아 졸업식'},
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
                      '타임캡슐',
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

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '작년의 오늘을 기억하시나요?',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF444444),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '소중했던 그날의 추억이 다시 찾아왔어요 🎁',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text('📅', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    '1년 전 오늘',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Divider(color: Colors.grey[300], thickness: 1),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _memories.length,
                separatorBuilder: (context, index) => Divider(
                  color: Colors.grey[200],
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final memory = _memories[index];
                  return GestureDetector(
                    onTap: () {
                      if (memory['date'] == '2025-05-05') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TimeCapsuleDetailScreen(
                              date: memory['date']!,
                              title: memory['title']!,
                            ),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${memory['date']} ${memory['title']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4,
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CalendarScreen()),
            );
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
}