import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'question_list_screen.dart';
import 'garden_screen.dart';
import 'calendar_screen.dart';
import 'mypage_screen.dart';

class TimeCapsuleDetailScreen extends StatelessWidget {
  final String date;
  final String title;

  const TimeCapsuleDetailScreen({
    super.key,
    required this.date,
    required this.title,
  });

  final List<Map<String, dynamic>> _familyMemories = const [
    {
      'role': '아빠',
      'mood': '#피곤',
      'moodColor': Color(0xFF9DB8E8),
      'content': '너희 어릴때 놀이공원 가서 하루 종일 놀았던 어린이날이 아직도 기억난다. 그때 너희가 정말 신나 했었지.',
    },
    {
      'role': '엄마',
      'mood': '#기쁨',
      'moodColor': Color(0xFFE8C49D),
      'content': '너희가 직접 손 편지랑 카네이션을 줬던 어린이날이 제일 기억나. 아직도 서랍에 잘 보관하고 있어.',
    },
    {
      'role': '아들',
      'mood': '#피곤',
      'moodColor': Color(0xFF9DB8E8),
      'content': '어린이날에 자전거 선물 받고 가족이랑 공원에서 탔던 날! 집에 가기 싫을 정도로 재밌었어.',
    },
    {
      'role': '딸',
      'mood': '#기쁨',
      'moodColor': Color(0xFFE8C49D),
      'content': '초등학교때 가족이랑 바다 놀러 갔던 어린이날! 사진도 엄청 찍고 진짜 재밌었어.',
    },
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

            // 상단 바
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

            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF444444),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('🌸', style: TextStyle(fontSize: 16)),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '" 우리 가족과 함께했던 어린이날 중 가장 기억에 남는 날은 언제인가요? "',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.7,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
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

                    const SizedBox(height: 16),

                    ..._familyMemories.map((memory) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            memory['role'],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            memory['content'],
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: (memory['moodColor'] as Color)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              memory['mood'],
                              style: TextStyle(
                                fontSize: 11,
                                color: memory['moodColor'] as Color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Divider(color: Colors.grey[200], height: 1),
                        ],
                      ),
                    )),

                    const SizedBox(height: 40),
                  ],
                ),
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