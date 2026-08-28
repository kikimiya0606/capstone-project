import 'package:flutter/material.dart';
import 'invite_screen.dart';

class IdLoginScreen extends StatefulWidget {
  const IdLoginScreen({super.key});

  @override
  State<IdLoginScreen> createState() => _IdLoginScreenState();
}

class _IdLoginScreenState extends State<IdLoginScreen> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 뒤로가기
              const SizedBox(height: 16),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios, size: 20),
                padding: EdgeInsets.zero,
                color: Colors.grey[600],
              ),

              const SizedBox(height: 32),

              // 로고 + 서브타이틀
              Center(
                child: Column(
                  children: [
                    Text(
                      'mood',
                      style: TextStyle(
                        fontFamily: 'PalaceScript',
                        fontSize: 52,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '우리 가족의 비밀 공간',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // ID 입력
              Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      'ID',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _idController,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'ID',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFFF0EBE3),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // PASSWORD 입력
              Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      'PASSWORD',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'PASSWORD',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFFF0EBE3),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // LOG IN 버튼
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const InviteScreen()),
                          (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBBBBBB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'LOG IN',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}