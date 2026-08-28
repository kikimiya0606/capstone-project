import 'package:flutter/material.dart';
import 'answer_screen.dart';
import 'answer_detail_screen.dart';
import 'home_screen.dart';
import 'garden_screen.dart';
import 'calendar_screen.dart';
import 'mypage_screen.dart';

class QuestionListScreen extends StatelessWidget {
  const QuestionListScreen({super.key});

  // question: 질문 내용, answered: 답변 완료 여부
  final List<Map<String, dynamic>> _questions = const [
    {
      'question': '최근에 가족들에게 쑥스러워서 말하지 못했던 고마운 순간이나 미안했던 일이 있다면?',
      'answered': true, // 1번 질문만 답변 완료 상태
    },
    {
      'question': '오늘 하루 가장 기억에 남는 순간은 무엇인가요?',
      'answered': false,
    },
    {
      'question': '가족에게 꼭 전하고 싶은 말이 있다면?',
      'answered': false,
    },
    {
      'question': '요즘 가장 행복했던 순간을 공유해주세요.',
      'answered': false,
    },
    {
      'question': '최근에 힘들었던 일이 있다면 나눠주세요.',
      'answered': false,
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
                      '질문 리스트',
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
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                reverse: true,
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  final questionData = _questions[index];
                  final String questionText = questionData['question'];
                  final bool isAnswered = questionData['answered'];

                  return GestureDetector(
                    onTap: () {
                      if (isAnswered) {
                        // 답변 완료된 질문 -> 전체 답변 확인 화면으로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AnswerDetailScreen(
                              myAnswer:
                              '수요일 아침 아들이 깨워주려 했을 때 잠결에 짜증을 내서 하루 종일 마음이 무거웠어. 요즘 졸업 작품 준비에 예민하다는 핑계로 가족들에게 살갑게 굴지 못한 것 같아 미안했어. 그래도 늦은 밤 내 방 앞에 슬그머니 간식을 챙겨두고 가는 가족들 덕분에 위로가 되어서, 항상 미안하고 고마워.',
                              familyAnswers: [
                                {
                                  'name': '엄마',
                                  'answer':
                                  '어제 아빠가 퇴근길에 내가 제일 좋아하는 빵집 들러서 단팥빵이랑 크림빵을 가득 사 왔더라. 요즘 갱년기라 감정이 부쩍 우울하고 짜증도 자주 냈는데, 아무 말 없이 내 기분 맞춰주려는 남편 마음 같아서 눈물 날 뻔했고 고마웠어.',
                                },
                                {
                                  'name': '아빠',
                                  'answer':
                                  '요즘 회사에서 명예퇴직 신호가 잦아서 마음이 많이 뒤숭숭한데도, 집에서 한숨을 자주 쉬었나 봐. 어쩌다 거실에서 멍하니 앉아 있는데 아들이 슬그머니 와서 어깨를 꾹꾹 주물러 주더라. 다 자란 자식한테 위로를 받는 게 고마우면서도, 가장으로서 든든한 모습을 보여주지 못해 미안했어.',
                                },
                                {
                                  'name': '아들',
                                  'answer':
                                  '저번에 누나가 숙제를 도와줘서 친구들 사이에서 완전 똑똑한 애가 됐어요. 고마웠어요. 앞으로도 집에서 티격태격해도 우리 가족 다 아프지 말고 건강하게 오래오래 지냈으면 좋겠음~',
                                },
                              ],
                              questionText: questionText,
                              questionNumber: index + 1,
                              answerDate: '2026.05.26',
                            ),
                          ),
                        );
                      } else {
                        // 미답변 질문 -> 답변 입력 화면으로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AnswerScreen()),
                        );
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '#${index + 1} ',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFBBA98A),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              questionText,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                height: 1.5,
                              ),
                            ),
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
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
            );
          } else if (index == 1) {
            // 현재 페이지
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