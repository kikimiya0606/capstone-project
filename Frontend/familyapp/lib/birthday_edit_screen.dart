import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'question_list_screen.dart';
import 'garden_screen.dart';
import 'calendar_screen.dart';
import 'mypage_screen.dart';


class BirthdayEditScreen extends StatefulWidget {
  final String currentBirthday;

  const BirthdayEditScreen({
    super.key,
    required this.currentBirthday,
  });

  @override
  State<BirthdayEditScreen> createState() => _BirthdayEditScreenState();
}

class _BirthdayEditScreenState extends State<BirthdayEditScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentBirthday);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                  _buildTextField(),
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
              icon: const Icon(Icons.arrow_back_ios,
                  size: 18, color: Color(0xFF2D2D2D)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Text(
            '생년월일',
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
                onPressed: () {
                  Navigator.pop(context, _controller.text);
                },
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

  Widget _buildTextField() {
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
        keyboardType: TextInputType.datetime,
        style: const TextStyle(fontSize: 14, color: Color(0xFF2D2D2D)),
        decoration: InputDecoration(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          border: InputBorder.none,
          hintText: 'ex) 1999/03/02',
          hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFCCCCCC)),
          labelText: '생년월일',
          labelStyle: const TextStyle(fontSize: 12, color: Color(0xFFAAAAAA)),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.cancel,
                size: 16, color: Color(0xFFCCCCCC)),
            onPressed: () => setState(() => _controller.clear()),
          )
              : null,
        ),
        onChanged: (_) => setState(() {}),
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