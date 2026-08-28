import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'question_list_screen.dart';
import 'garden_screen.dart';
import 'calendar_screen.dart';
import 'mypage_screen.dart';

class AnswerDetailScreen extends StatelessWidget {
  final String myAnswer;
  final List<Map<String, dynamic>> familyAnswers;
  final String questionText;
  final int questionNumber;
  final String answerDate;

  const AnswerDetailScreen({
    super.key,
    required this.myAnswer,
    this.familyAnswers = const [
      {'name': '엄마', 'answer': null},
      {'name': '아빠', 'answer': null},
      {'name': '아들', 'answer': null},
    ],
    this.questionText =
    '최근에 가족들에게 쑥스러워서 말하지 못했던\n고마운 순간이나 미안했던 일이 있다면?',
    this.questionNumber = 1,
    this.answerDate = '2026.05.26',
  });

  @override
  Widget build(BuildContext context) {
    // 나를 포함해 모든 가족이 답변했는지 확인
    final bool allAnswered =
    familyAnswers.every((member) => member['answer'] != null);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                    padding: EdgeInsets.zero,
                    color: Colors.grey[600],
                  ),
                  Column(
                    children: [
                      const Text(
                        'mood',
                        style: TextStyle(
                          fontFamily: 'PalaceScript',
                          fontSize: 28,
                          color: Color(0xFFAAAAAA),
                        ),
                      ),
                      Text(
                        '나의 기록 일기',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[400],
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 48),
                ],
              ),

              const SizedBox(height: 24),

              Text(
                questionText,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF444444),
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                '#$questionNumber번째 질문  $answerDate',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[400],
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '나',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        myAnswer,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.7,
                        ),
                      ),

                      const SizedBox(height: 24),

                      ...familyAnswers.map((member) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member['name'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 12),
                          member['answer'] != null
                              ? Text(
                            member['answer'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.7,
                            ),
                          )
                              : Center(
                            child: Text(
                              '아직 답변하지 않았어요.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      )),

                      // 모두 답변 완료했을 때만 잠금 안내 문구 숨김 처리(선택)
                      if (!allAnswered)
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock_outline,
                                size: 14,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '모두가 답변해야 볼 수 있어요.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
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