import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'question_list_screen.dart';
import 'calendar_screen.dart';
import 'mypage_screen.dart';
import 'garden_state.dart';

class GardenScreen extends StatefulWidget {
  const GardenScreen({super.key});

  @override
  State<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends State<GardenScreen>
    with SingleTickerProviderStateMixin {
  double _progress = 0.1;

  // 레벨업 팝업 표시 여부 + 애니메이션 컨트롤러
  bool _showLevelUp = false;
  late final AnimationController _levelUpController;
  late final Animation<double> _levelUpScale;
  late final Animation<double> _levelUpOpacity;

  int _lastLevel = 10; // 레벨업 감지를 위한 이전 레벨 저장

  // 코인(쿠키) 개수는 GardenState에서 가져옴
  int get _coins => GardenState.instance.cookieCount.value;

  int get _level {
    if (_progress >= 1.0) return 100;
    if (_progress >= 0.8) return 80;
    if (_progress >= 0.6) return 60;
    if (_progress >= 0.3) return 30;
    return 10;
  }

  String get _gardenImage {
    if (_progress >= 1.0) return 'assets/images/garden_100.png';
    if (_progress >= 0.8) return 'assets/images/garden_80.png';
    if (_progress >= 0.6) return 'assets/images/garden_60.png';
    if (_progress >= 0.3) return 'assets/images/garden_30.png';
    return 'assets/images/garden_10.png';
  }

  @override
  void initState() {
    super.initState();
    _lastLevel = _level;

    // GardenState의 쿠키 개수가 바뀔 때마다 화면 갱신
    GardenState.instance.cookieCount.addListener(_onCookieChanged);

    _levelUpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _levelUpScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.4, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
    ]).animate(_levelUpController);

    _levelUpOpacity = CurvedAnimation(
      parent: _levelUpController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      reverseCurve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    );
  }

  void _onCookieChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    GardenState.instance.cookieCount.removeListener(_onCookieChanged);
    _levelUpController.dispose();
    super.dispose();
  }

  void _doAction() {
    if (_coins <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '쿠키가 부족해요! 🍪',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF888888),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() {
      if (_progress < 1.0) {
        _progress = (_progress + 0.02).clamp(0.0, 1.0);
      }
    });
    // 쿠키 1개 소비 (GardenState의 리스너가 setState를 다시 호출해줌)
    GardenState.instance.cookieCount.value -= 1;

    // 레벨이 실제로 올랐는지 확인 후 레벨업 연출 실행
    final newLevel = _level;
    if (newLevel != _lastLevel) {
      _lastLevel = newLevel;
      _playLevelUpAnimation();
    }
  }

  Future<void> _playLevelUpAnimation() async {
    setState(() => _showLevelUp = true);
    await _levelUpController.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    await _levelUpController.reverse();
    if (!mounted) return;
    setState(() => _showLevelUp = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // 상단 바
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                    padding: EdgeInsets.zero,
                    color: Colors.grey[600],
                  ),
                  Row(
                    children: [
                      const Text('🍪', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 4),
                      // 코인 숫자가 바뀔 때 살짝 튀는 느낌 추가
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, anim) => ScaleTransition(
                          scale: anim,
                          child: child,
                        ),
                        child: Text(
                          '$_coins',
                          key: ValueKey<int>(_coins),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _coins <= 0
                                ? Colors.red
                                : const Color(0xFF666666),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              const Text(
                '하루하루 자라나는 가족 정원 🍀',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF444444),
                ),
              ),

              const SizedBox(height: 12),

              // 레벨 뱃지: 레벨이 바뀔 때 크기가 튀는 애니메이션
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: CurvedAnimation(
                    parent: anim,
                    curve: Curves.easeOutBack,
                  ),
                  child: child,
                ),
                child: Container(
                  key: ValueKey<int>(_level),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'LEVEL $_level',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // 진행률 바: 값이 바뀔 때 순간이동이 아니라 부드럽게 차오름
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: _progress),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return LinearProgressIndicator(
                      value: value,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFBBA98A),
                      ),
                      minHeight: 6,
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 정원 이미지: 레벨이 바뀔 때 페이드 + 스케일로 크로스페이드
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 600),
                          switchInCurve: Curves.easeOutBack,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, anim) {
                            return FadeTransition(
                              opacity: anim,
                              child: ScaleTransition(
                                scale: Tween<double>(begin: 0.92, end: 1.0)
                                    .animate(anim),
                                child: child,
                              ),
                            );
                          },
                          layoutBuilder: (currentChild, previousChildren) {
                            return Stack(
                              fit: StackFit.expand,
                              alignment: Alignment.center,
                              children: [
                                ...previousChildren,
                                if (currentChild != null) currentChild,
                              ],
                            );
                          },
                          child: Image.asset(
                            _gardenImage,
                            key: ValueKey<String>(_gardenImage),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                    ),

                    // 레벨업 팝업 오버레이
                    if (_showLevelUp)
                      IgnorePointer(
                        child: FadeTransition(
                          opacity: _levelUpOpacity,
                          child: ScaleTransition(
                            scale: _levelUpScale,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                    Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                'LEVEL UP! 🎉',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF7A9D54),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(
                    emoji: '💧',
                    label: '물 주기',
                    onTap: _doAction,
                    disabled: _coins <= 0,
                  ),
                  _ActionButton(
                    emoji: '☀️',
                    label: '햇빛 주기',
                    onTap: _doAction,
                    disabled: _coins <= 0,
                  ),
                  _ActionButton(
                    emoji: '🎵',
                    label: '연주 하기',
                    onTap: _doAction,
                    disabled: _coins <= 0,
                  ),
                  _ActionButton(
                    emoji: '🩷',
                    label: '사랑 주기',
                    onTap: _doAction,
                    disabled: _coins <= 0,
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
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
            // 현재 페이지
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
          BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.eco_outlined), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.all_inclusive_outlined), label: ''),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;
  final bool disabled;

  const _ActionButton({
    required this.emoji,
    required this.label,
    required this.onTap,
    this.disabled = false,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.disabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.disabled ? null : (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      // 눌렀을 때 살짝 눌리는 느낌
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: 76,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: widget.disabled ? Colors.grey[100] : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.disabled
                  ? Colors.grey[300]!
                  : const Color(0xFFEEE5D8),
              width: 1.5,
            ),
            boxShadow: widget.disabled
                ? []
                : [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                widget.emoji,
                style: TextStyle(
                  fontSize: 24,
                  color: widget.disabled ? Colors.grey[400] : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 11,
                  color: widget.disabled ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}