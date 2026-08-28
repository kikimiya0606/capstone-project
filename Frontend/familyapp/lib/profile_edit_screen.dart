import 'package:flutter/material.dart';
import 'name_edit_screen.dart';
import 'birthday_edit_screen.dart';
import 'role_select_screen.dart';
import 'user_session.dart';
import 'home_screen.dart';
import 'question_list_screen.dart';
import 'garden_screen.dart';
import 'calendar_screen.dart';
import 'mypage_screen.dart';

class ProfileEditScreen extends StatefulWidget {
  final String currentName;
  final String currentBirthday;

  const ProfileEditScreen({
    super.key,
    required this.currentName,
    required this.currentBirthday,
  });

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late String name;
  late String birthday;

  @override
  void initState() {
    super.initState();
    name = widget.currentName;
    birthday = widget.currentBirthday;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 28),
                    _buildProfileImage(),
                    const SizedBox(height: 40),
                    _buildInfoTable(context),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                size: 18,
                color: Color(0xFF2D2D2D),
              ),
              onPressed: () {
                Navigator.pop(context, {
                  'name': name,
                  'birthday': birthday,
                });
              },
            ),
          ),
          const Text(
            '프로필 편집',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D2D2D),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {},
                child: const Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: Color(0xFF9E9E9E),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFEDD9B8),
            border: Border.all(
              color: const Color(0xFFE8C9A0),
              width: 2,
            ),
          ),
          child: ClipOval(
            child: Image.network(
              'https://i.pravatar.cc/150?img=47',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.person,
                color: Color(0xFF8B6914),
                size: 44,
              ),
            ),
          ),
        ),
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFE0D8D0),
            ),
          ),
          child: const Icon(
            Icons.camera_alt_outlined,
            size: 14,
            color: Color(0xFF888888),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTable(BuildContext context) {
    return Column(
      children: [
        _buildInfoRow(
          label: '이름',
          value: name,
          onTap: () async {
            final result = await Navigator.push<String>(
              context,
              MaterialPageRoute(
                builder: (_) => NameEditScreen(
                  currentName: name,
                ),
              ),
            );

            if (result != null && result.isNotEmpty) {
              setState(() {
                name = result;
              });
            }
          },
        ),
        _buildDivider(),
        _buildInfoRow(
          label: '사용자 역할',
          value: UserSession.currentRole ?? '미설정',
          valueColor: UserSession.currentColor,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const RoleSelectScreen(isEditMode: true),
              ),
            );
            // 가족 구성원 설정 화면에서 돌아오면 바뀐 역할을 다시 반영
            setState(() {});
          },
        ),
        _buildDivider(),
        _buildInfoRow(
          label: '생년월일',
          value: birthday,
          onTap: () async {
            final result = await Navigator.push<String>(
              context,
              MaterialPageRoute(
                builder: (_) => BirthdayEditScreen(
                  currentBirthday: birthday,
                ),
              ),
            );

            if (result != null && result.isNotEmpty) {
              setState(() {
                birthday = result;
              });
            }
          },
        ),
        _buildDivider(),
        _buildInfoRowNoEdit(
          label: '아이디',
          value: 'seo_a1234',
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required VoidCallback onTap,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF888888),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: valueColor ?? const Color(0xFF2D2D2D),
                fontWeight: valueColor != null ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onTap,
            child: const Icon(
              Icons.edit_outlined,
              size: 15,
              color: Color(0xFFAAAAAA),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowNoEdit({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF888888),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2D2D2D),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFE8E0D8),
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
            MaterialPageRoute(
              builder: (_) => const QuestionListScreen(),
            ),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const GardenScreen(),
            ),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CalendarScreen(),
            ),
          );
        } else if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MyPageScreen(),
            ),
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
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_outlined),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.eco_outlined),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.all_inclusive_outlined),
          label: '',
        ),
      ],
    );
  }
}