import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'id_login_screen.dart';
import 'email_verification_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              const Spacer(flex: 3),

              // 로고 + 서브타이틀
              Column(
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

              const Spacer(flex: 3),

              // 구글 버튼
              _LoginButton(
                onTap: () {},
                backgroundColor: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/google_logo.png',
                      height: 22,
                      width: 22,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '구글로 계속하기',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 카카오 버튼
              _LoginButton(
                onTap: () {},
                backgroundColor: const Color(0xFFFFE812),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/kakao_logo.png',
                      height: 22,
                      width: 22,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '카카오톡으로 계속하기',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 아이디 버튼
              _LoginButton(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const IdLoginScreen()),
                  );
                },
                backgroundColor: const Color(0xFFE8E8E8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, color: Colors.grey[600], size: 24),
                    const SizedBox(width: 12),
                    Text(
                      '아이디로 계속하기',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 회원가입 | 아이디/비밀번호 찾기
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      );
                    },
                    child: Text(
                      '회원가입',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '|',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const EmailVerificationScreen()),
                      );
                    },
                    child: Text(
                      '아이디/비밀번호 찾기',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

// 버튼 공통 위젯
class _LoginButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color backgroundColor;
  final Widget child;

  const _LoginButton({
    required this.onTap,
    required this.backgroundColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: child),
      ),
    );
  }
}