import 'package:flutter/material.dart';
import 'answer_detail_screen.dart';
import 'home_screen.dart';
import 'question_list_screen.dart';
import 'garden_screen.dart';
import 'calendar_screen.dart';
import 'mypage_screen.dart';
import 'garden_state.dart';

class AnswerScreen extends StatefulWidget {
  const AnswerScreen({super.key});

  @override
  State<AnswerScreen> createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {
  final _answerController = TextEditingController();
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _answerController.addListener(() {
      setState(() {
        _charCount = _answerController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _handleSubmitAnswer() {
    if (_answerController.text.isNotEmpty) {
      // 정원 성장 쿠키 +1
      GardenState.instance.addCookie();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AnswerDetailScreen(
            myAnswer: _answerController.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                  IconButton(
                    onPressed: _handleSubmitAnswer,
                    icon: Icon(Icons.check, color: Colors.grey[600], size: 22),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              const Text(
                '최근에 가족들에게 쑥스러워서 말하지 못했던\n고마운 순간이나 미안했던 일이 있다면?',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF444444),
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                '#1번째 질문  2026.05.26',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[400],
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: Stack(
                  children: [
                    TextField(
                      controller: _answerController,
                      maxLines: null,
                      maxLength: 200,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF555555),
                        height: 1.7,
                      ),
                      decoration: InputDecoration(
                        hintText: '답변을 입력해 주세요.',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        counterText: '',
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 0,
                      child: Text(
                        '$_charCount / 200',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ],
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