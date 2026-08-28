import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'user_session.dart';

class RoleSelectScreen extends StatefulWidget {
  /// true면 마이페이지/프로필 편집에서 들어온 것으로 보고
  /// 완료 시 홈으로 이동하지 않고 이전 화면으로 돌아갑니다.
  final bool isEditMode;

  const RoleSelectScreen({super.key, this.isEditMode = false});

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    // 수정 모드면 현재 역할을 미리 선택해서 보여줌
    if (widget.isEditMode) {
      _selectedRole = UserSession.currentRole;
    }
  }

  final List<Map<String, dynamic>> _roles = [
    {'label': '아빠', 'image': 'assets/images/dad.png'},
    {'label': '엄마', 'image': 'assets/images/mom.png'},
    {'label': '아들', 'image': 'assets/images/son.png'},
    {'label': '딸', 'image': 'assets/images/daughter.png'},
  ];

  Color get _selectedColor => FamilyRole.colorOf(_selectedRole);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
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
                  const SizedBox(width: 40),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                '가족 구성원 설정',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF444444),
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 0,
                  childAspectRatio: 1.0,
                  physics: const NeverScrollableScrollPhysics(),
                  children: _roles.map((role) {
                    final label = role['label'] as String;
                    final isSelected = _selectedRole == label;
                    final roleColor = FamilyRole.colorOf(label);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedRole = label;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFE8E0D5),
                              border: isSelected
                                  ? Border.all(
                                color: roleColor,
                                width: 3,
                              )
                                  : Border.all(
                                color: Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                role['image'] as String,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected ? roleColor : Colors.grey[600],
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  child: ElevatedButton(
                    onPressed: _selectedRole == null
                        ? null
                        : () {
                      UserSession.setRole(_selectedRole!);
                      if (widget.isEditMode) {
                        // 프로필 편집에서 온 경우: 이전 화면으로 돌아감
                        Navigator.pop(context);
                      } else {
                        // 최초 가입 플로우: 홈으로 이동
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const HomeScreen()),
                              (route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedRole == null
                          ? const Color(0xFFCCCCCC)
                          : _selectedColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFCCCCCC),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.isEditMode ? '저장' : '함께 시작하기',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}