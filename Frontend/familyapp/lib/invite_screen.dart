import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'role_select_screen.dart';

class InviteScreen extends StatefulWidget {
  const InviteScreen({super.key});

  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  final _familyCodeController = TextEditingController();
  final String _myCode = 'ABC123XY'; // 임시 코드
  bool _canProceed = false; // 가족 코드 입력 여부

  @override
  void initState() {
    super.initState();
    _familyCodeController.addListener(() {
      final hasText = _familyCodeController.text.trim().isNotEmpty;
      if (hasText != _canProceed) {
        setState(() => _canProceed = hasText);
      }
    });
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: _myCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('코드가 복사되었습니다!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _goNext() {
    if (_familyCodeController.text.trim().isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
      );
    }
  }

  @override
  void dispose() {
    _familyCodeController.dispose();
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
                  const SizedBox(width: 40),
                ],
              ),

              const SizedBox(height: 48),

              // 타이틀
              const Center(
                child: Text(
                  '가족을 초대해 보세요!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF444444),
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // 나의 코드 섹션
              Text(
                '나의 코드',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _copyCode,
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EBE3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _myCode,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                            letterSpacing: 2,
                          ),
                        ),
                        Icon(
                          Icons.copy,
                          size: 18,
                          color: Colors.grey[500],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '코드를 눌러 복사하세요',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),

              // 구분선
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Divider(color: Colors.grey[300], thickness: 1),
              ),

              // 가족 코드 섹션
              Text(
                '가족의 코드를 알고있다면',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _familyCodeController,
                style: const TextStyle(fontSize: 14),
                onSubmitted: (_) => _goNext(),
                decoration: InputDecoration(
                  hintText: '가족 코드 입력',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF0EBE3),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 다음 버튼
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _canProceed ? _goNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canProceed
                        ? const Color(0xFF444444)
                        : const Color(0xFFDDDDDD),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFDDDDDD),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '다음',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
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