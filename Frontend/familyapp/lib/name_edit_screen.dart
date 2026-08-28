import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'question_list_screen.dart';
import 'garden_screen.dart';
import 'calendar_screen.dart';
import 'mypage_screen.dart';

class NameEditScreen extends StatefulWidget {
  final String currentName;

  const NameEditScreen({
    super.key,
    required this.currentName,
  });

  @override
  State<NameEditScreen> createState() => _NameEditScreenState();
}

class _NameEditScreenState extends State<NameEditScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.currentName;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveName() {
    final name = _controller.text.trim();

    if (name.isEmpty) return;

    Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildTextField(hint: '이름'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
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
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Text(
            '이름',
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
              child: TextButton(
                onPressed: _saveName,
                child: const Text(
                  '저장',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2D2D2D),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required String hint}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        autofocus: true,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF2D2D2D),
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFFCCCCCC),
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
            icon: const Icon(
              Icons.cancel,
              size: 16,
              color: Color(0xFFCCCCCC),
            ),
            onPressed: () {
              setState(() {
                _controller.clear();
              });
            },
          )
              : null,
        ),
        onChanged: (_) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildBottomNavBar() {
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
              builder: (_) => const MyPageScreen(),
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