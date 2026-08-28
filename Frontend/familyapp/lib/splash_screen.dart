import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  } // ← 여기 } 가 빠져 있었음

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: const Text(
            'mood',
            style: const TextStyle(
              fontFamily: 'PalaceScript',
              fontSize: 72,  // 48 → 72 로 변경
              fontWeight: FontWeight.w400,
              color: Color(0xFF999999),  // 살짝 더 진하게
              letterSpacing: 3,  // 2 → 3 으로 변경
            ),
          ),
        ),
      ),
    );
  }
}