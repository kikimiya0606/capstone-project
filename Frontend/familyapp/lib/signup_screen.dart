import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'terms_screen.dart';
import 'privacy_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _emailController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _birthController = TextEditingController();

  // 약관 동의 관련 state
  bool _agreeAll = false;
  bool _agreeTerms = false; // 필수: 이용약관
  bool _agreePrivacy = false; // 필수: 개인정보 제3자 제공
  bool _expanded = false;

  final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _emailController.dispose();
    _nicknameController.dispose();
    _birthController.dispose();
    super.dispose();
  }

  void _toggleAll(bool? value) {
    setState(() {
      _agreeAll = value ?? false;
      _agreeTerms = _agreeAll;
      _agreePrivacy = _agreeAll;
    });
  }

  void _syncAllState() {
    setState(() {
      _agreeAll = _agreeTerms && _agreePrivacy;
    });
  }

  void _handleSignUp() {
    // 1. 입력값 검증 (이메일 형식, 비밀번호 확인 등)
    final isFormValid = _formKey.currentState?.validate() ?? false;

    // 2. 필수 약관 동의 검증
    final isAgreementValid = _agreeTerms && _agreePrivacy;

    if (!isFormValid) {
      return; // TextFormField 자체 에러 메시지가 표시됨
    }

    if (!isAgreementValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('필수 약관에 모두 동의해주세요.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // 모든 검증 통과 시 로그인 화면으로 이동
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Form(
            key: _formKey,
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

                const SizedBox(height: 40),

                // 입력 필드들
                _InputRow(
                  label: 'ID',
                  controller: _idController,
                  hint: 'ID',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'ID를 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _InputRow(
                  label: 'PASSWORD',
                  controller: _passwordController,
                  hint: 'PASSWORD',
                  obscure: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력해주세요';
                    }
                    if (value.length < 6) {
                      return '비밀번호는 6자 이상이어야 합니다';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _InputRow(
                  label: 'PASSWORD\nCHECK',
                  controller: _passwordConfirmController,
                  hint: 'PASSWORD 재확인',
                  obscure: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 다시 입력해주세요';
                    }
                    if (value != _passwordController.text) {
                      return '비밀번호가 일치하지 않습니다';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _InputRow(
                  label: 'E-MAIL',
                  controller: _emailController,
                  hint: 'E-MAIL',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '이메일을 입력해주세요';
                    }
                    if (!_emailRegex.hasMatch(value.trim())) {
                      return '올바른 이메일 형식이 아닙니다';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _InputRow(
                  label: '닉네임',
                  controller: _nicknameController,
                  hint: '닉네임',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '닉네임을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _InputRow(
                  label: '생년월일',
                  controller: _birthController,
                  hint: '생년월일 8자리',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '생년월일을 입력해주세요';
                    }
                    if (value.trim().length != 8) {
                      return '생년월일 8자리를 입력해주세요 (예: 19990101)';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // SIGN UP 버튼
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBBBBBB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'SIGN UP',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 개인정보 수집 관련 동의
                _AgreementSection(
                  agreeAll: _agreeAll,
                  agreeTerms: _agreeTerms,
                  agreePrivacy: _agreePrivacy,
                  expanded: _expanded,
                  onToggleAll: _toggleAll,
                  onToggleExpanded: () {
                    setState(() => _expanded = !_expanded);
                  },
                  onToggleTerms: (value) {
                    setState(() => _agreeTerms = value ?? false);
                    _syncAllState();
                  },
                  onTogglePrivacy: (value) {
                    setState(() => _agreePrivacy = value ?? false);
                    _syncAllState();
                  },
                  onViewTerms: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TermsScreen()),
                    );
                  },
                  onViewPrivacy: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PrivacyScreen()),
                    );
                  },
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 라벨 + 입력창 공통 위젯 (validator 지원)
class _InputRow extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _InputRow({
    required this.label,
    required this.hint,
    required this.controller,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        Expanded(
          child: TextFormField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 13),
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 13,
              ),
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
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.redAccent),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.redAccent),
              ),
              errorStyle: const TextStyle(fontSize: 11),
            ),
          ),
        ),
      ],
    );
  }
}

// 개인정보 수집 관련 동의 위젯 (이미지 예시 스타일)
class _AgreementSection extends StatelessWidget {
  final bool agreeAll;
  final bool agreeTerms;
  final bool agreePrivacy;
  final bool expanded;
  final ValueChanged<bool?> onToggleAll;
  final VoidCallback onToggleExpanded;
  final ValueChanged<bool?> onToggleTerms;
  final ValueChanged<bool?> onTogglePrivacy;
  final VoidCallback onViewTerms;
  final VoidCallback onViewPrivacy;

  const _AgreementSection({
    required this.agreeAll,
    required this.agreeTerms,
    required this.agreePrivacy,
    required this.expanded,
    required this.onToggleAll,
    required this.onToggleExpanded,
    required this.onToggleTerms,
    required this.onTogglePrivacy,
    required this.onViewTerms,
    required this.onViewPrivacy,
  });

  @override
  Widget build(BuildContext context) {
    final isAllRequiredChecked = agreeTerms && agreePrivacy;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 전체 동의 행
          InkWell(
            onTap: onToggleExpanded,
            child: Row(
              children: [
                Checkbox(
                  value: agreeAll,
                  onChanged: onToggleAll,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '[필수] 이용약관 및 개인정보 수집 관련 동의, 개인정보 제3자 제공 동의',
                    style: TextStyle(
                      fontSize: 12,
                      color: isAllRequiredChecked
                          ? Colors.grey[800]
                          : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: Colors.grey[500],
                ),
              ],
            ),
          ),

          // 하위 세부 항목 (펼쳐졌을 때만 표시)
          if (expanded) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Row(
                children: [
                  SizedBox(
                    height: 32,
                    width: 32,
                    child: Checkbox(
                      value: agreeTerms,
                      onChanged: onToggleTerms,
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize:
                      MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '[필수] 이용약관',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ),
                  TextButton(
                    onPressed: onViewTerms,
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      '보기',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Row(
                children: [
                  SizedBox(
                    height: 32,
                    width: 32,
                    child: Checkbox(
                      value: agreePrivacy,
                      onChanged: onTogglePrivacy,
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize:
                      MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '[필수] 개인정보 제3자 제공 동의서',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ),
                  TextButton(
                    onPressed: onViewPrivacy,
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      '보기',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}