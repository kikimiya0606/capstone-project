import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'timecapsule_screen.dart';
import 'setting_screen.dart';
import 'profile_edit_screen.dart';
import 'home_screen.dart';
import 'question_list_screen.dart';
import 'garden_screen.dart';
import 'calendar_screen.dart';


class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  bool _notificationEnabled = true;

  String userName = "김서아";
  String userBirthday = "2011/03/02";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 14),
                    _buildNotificationCard(),
                    const SizedBox(height: 14),
                    _buildProfileCard(),
                    const SizedBox(height: 22),
                    _buildSectionLabel('더 많은 콘텐츠'),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      emoji: '👨‍👩‍👧',
                      title: '가족관리',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      emoji: '💌',
                      title: '타임캡슐',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const TimeCapsuleScreen()),
                        );
                      },
                    ),
                    _buildMenuItem(
                      emoji: '⚙️',
                      title: '설정',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SettingScreen()),
                        );
                      },
                    ),
                    _buildMenuItem(
                      emoji: '📊',
                      title: '개인 활동 통계',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      emoji: '💎',
                      title: '감정 분석 리포트 확인',
                      onTap: () {},
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: const Text(
        '마이페이지',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2D2D2D),
        ),
      ),
    );
  }

  Widget _buildNotificationCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                    fontSize: 13, color: Color(0xFF555555), height: 1.4),
                children: [
                  TextSpan(text: '매일 오전 10시 '),
                  TextSpan(
                    text: "'오늘의 질문'",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D2D2D)),
                  ),
                  TextSpan(text: ' 알림 받기'),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          CupertinoSwitch(
            value: _notificationEnabled,
            onChanged: (val) => setState(() => _notificationEnabled = val),
            activeColor: const Color(0xFF5C5C5C),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFEDD9B8),
            ),
            child: ClipOval(
              child: Image.network(
                'https://i.pravatar.cc/150?img=47',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.person,
                  color: Color(0xFF8B6914),
                  size: 30,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              '$userName 님',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D2D2D),
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push<Map<String, String>>(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileEditScreen(
                    currentName: userName,
                    currentBirthday: userBirthday,
                  ),
                ),
              );

              if (result != null) {
                setState(() {
                  userName = result['name'] ?? userName;
                  userBirthday = result['birthday'] ?? userBirthday;
                });
              }
            },
            child: const Icon(
              Icons.edit_outlined,
              size: 18,
              color: Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFF888888),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String emoji,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF2D2D2D),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 다른 화면들(home/question_list/answer_detail)과 동일한 표준 BottomNavigationBar
  Widget _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 4, // 마이페이지는 마지막(무한대 아이콘) 위치
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
          // 현재 페이지
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
    );
  }
}