import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'question_list_screen.dart';
import 'garden_screen.dart';
import 'calendar_screen.dart';
import 'mypage_screen.dart';
import 'login_screen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _screenLockOn = false;
  bool _vibrationOn = false;
  bool _notificationOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 28),
                    _buildSectionLabel('시스템 설정'),
                    const SizedBox(height: 12),
                    _buildToggleItem(
                      title: '화면 잠금',
                      value: _screenLockOn,
                      onChanged: (value) {
                        setState(() => _screenLockOn = value);
                      },
                    ),
                    _buildDivider(),
                    _buildToggleItem(
                      title: '진동',
                      value: _vibrationOn,
                      onChanged: (value) {
                        setState(() => _vibrationOn = value);
                      },
                    ),
                    _buildDivider(),
                    _buildToggleItem(
                      title: '알림',
                      value: _notificationOn,
                      onChanged: (value) {
                        setState(() => _notificationOn = value);
                      },
                    ),
                    const SizedBox(height: 32),
                    _buildSectionLabel('개인/보안'),
                    const SizedBox(height: 12),
                    _buildMenuItem(title: '가족 연결', onTap: () {}),
                    _buildDivider(),
                    _buildMenuItem(
                      title: '로그아웃',
                      onTap: () => _showLogoutDialog(context),
                    ),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  size: 18, color: Color(0xFF2D2D2D)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Text(
            '설정',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D2D2D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2D2D2D),
      ),
    );
  }

  // 화살표(>)가 있는 기존 메뉴 항목 (가족 연결, 로그아웃)
  Widget _buildMenuItem({required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 15, color: Color(0xFF2D2D2D)),
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: Color(0xFFAAAAAA)),
          ],
        ),
      ),
    );
  }

  // 온/오프 스위치가 있는 메뉴 항목 (화면 잠금, 진동, 알림)
  Widget _buildToggleItem({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 15, color: Color(0xFF2D2D2D)),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFFBBA98A),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFE0E0E0),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFE8E0D8));
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '로그아웃 확인',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '로그아웃 하시겠습니까?',
                style: TextStyle(fontSize: 14, color: Color(0xFF888888)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: const BorderSide(color: Color(0xFFE0E0E0)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    '로그아웃',
                    style: TextStyle(fontSize: 15, color: Color(0xFF2D2D2D)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: const BorderSide(color: Color(0xFFE0E0E0)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    '취소',
                    style: TextStyle(fontSize: 15, color: Color(0xFF2D2D2D)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
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
    );
  }
} 