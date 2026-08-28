import 'package:flutter/material.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
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
              // 상단 뒤로가기 + 로고
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                    padding: EdgeInsets.zero,
                    color: Colors.grey[600],
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'mood',
                        style: TextStyle(
                          fontFamily: 'PalaceScript',
                          fontSize: 28,
                          color: Color(0xFFAAAAAA),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // 뒤로가기 버튼 균형용
                ],
              ),

              const SizedBox(height: 60),

              // 안내 텍스트
              Center(
                child: Text(
                  '가입하신 이메일을 입력해주세요.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // E-MAIL 입력
              Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: Text(
                      'E- MAIL',
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
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'E-MAIL',
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
                        suffixIcon: Icon(
                          Icons.send,
                          size: 18,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // CODE 입력
              Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: Text(
                      'CODE',
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
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'CODE',
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

              // VERIFICATION 버튼
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: 인증 로직
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
                    'VERIFICATION',
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