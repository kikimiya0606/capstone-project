import 'package:flutter/material.dart';
import 'answer_screen.dart';
import 'question_list_screen.dart';
import 'calendar_screen.dart';
import 'garden_screen.dart';
import 'mypage_screen.dart';
import 'notification_screen.dart';
import 'garden_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String? _selectedMood;
  late final TextEditingController _moodTextController;

  // TODO: 실제로는 알림 데이터의 안읽음 개수로 교체하세요.
  final bool _hasUnreadNotification = true;

  final List<Map<String, dynamic>> _moods = [
    {'label': '#기쁨', 'emoji': '☀️'},
    {'label': '#화남', 'emoji': '💢'},
    {'label': '#슬픔', 'emoji': '💧'},
    {'label': '#쏘쏘', 'emoji': '🙂'},
    {'label': '#걱정', 'emoji': '🌀'},
    {'label': '#피곤', 'emoji': '💤'},
  ];

  @override
  void initState() {
    super.initState();
    // 이전에 저장해둔 무드 상태 복원
    _moodTextController =
        TextEditingController(text: GardenState.instance.moodText);
    _selectedMood = GardenState.instance.selectedMood;
  }

  @override
  void dispose() {
    _moodTextController.dispose();
    super.dispose();
  }

  void _handleSaveMood() {
    final hasMoodText = _moodTextController.text.trim().isNotEmpty;
    final hasMoodSelected = _selectedMood != null;

    if (!hasMoodText && !hasMoodSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '오늘의 기분을 입력하거나 선택해 주세요!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF888888),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // 무드 상태를 전역에 저장 (다른 페이지 갔다와도 유지됨)
    GardenState.instance.saveMood(
      moodText: _moodTextController.text,
      selectedMood: _selectedMood,
    );

    // 정원 성장 쿠키 +1
    GardenState.instance.addCookie();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          '저장되었습니다!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF888888),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // 상단 타이틀 + 알림
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '우리 가족의 기록이 쌓인 지\n1일 째 ✨',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF444444),
                      height: 1.6,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NotificationScreen()),
                      );
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(Icons.notifications_none,
                            color: Colors.grey[600], size: 26),
                        if (_hasUnreadNotification)
                          Positioned(
                            top: -1,
                            right: -1,
                            child: Container(
                              width: 9,
                              height: 9,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD98A8A),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 오늘의 질문 카드
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      '오늘의 질문이 도착했습니다!',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '" 최근에 가족들에게 쑥스러워서 말하지 못했던\n고마운 순간이나 미안했던 일이 있다면? "',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 지금 답변하러 가기 버튼
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AnswerScreen()),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F0EB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '지금 답변하러 가기',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 오늘 나의 #mood 카드
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF3EC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEEE5D8), width: 1),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '오늘 나의 #mood',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF555555),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 한 줄 텍스트 입력 박스
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFFE8E0D5), width: 1),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: TextField(
                        controller: _moodTextController,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        decoration: InputDecoration(
                          hintText: '오늘 나의 기분을 한 줄로 표현해 주세요',
                          hintStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                          const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 무드 그리드
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.1,
                      physics: const NeverScrollableScrollPhysics(),
                      children: _moods.map((mood) {
                        final isSelected = _selectedMood == mood['label'];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMood = mood['label'];
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFEEE5D8)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(
                                color: const Color(0xFF888888),
                                width: 1.5,
                              )
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  mood['emoji'],
                                  style: const TextStyle(fontSize: 28),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  mood['label'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 12),

                    // 저장 버튼
                    GestureDetector(
                      onTap: _handleSaveMood,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8E0D5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '저장',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Center(
                      child: Text(
                        '오늘의 무드를 선택하고 가족 정원을 성장시켜 보세요 🌱',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      // 하단 네비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 1) {
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
          BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.eco_outlined), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.all_inclusive_outlined), label: ''),
        ],
      ),
    );
  }
}