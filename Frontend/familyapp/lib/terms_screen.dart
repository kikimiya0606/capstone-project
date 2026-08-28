import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F0EB),
        elevation: 0,
        foregroundColor: Colors.grey[800],
        title: const Text(
          '이용약관',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _TermsSection(
                title: '제1조 (목적)',
                body:
                '이 약관은 mood(이하 "서비스")가 제공하는 서비스의 이용과 관련하여 '
                    '서비스와 이용자 간의 권리, 의무 및 책임사항, 기타 필요한 사항을 규정함을 목적으로 합니다.',
              ),
              _TermsSection(
                title: '제2조 (정의)',
                body:
                '1. "회원"이란 본 약관에 동의하고 서비스에 가입하여 이용자 아이디를 부여받은 자를 말합니다.\n'
                    '2. "아이디(ID)"란 회원의 식별과 서비스 이용을 위하여 회원이 정하고 서비스가 승인하는 문자와 숫자의 조합을 말합니다.',
              ),
              _TermsSection(
                title: '제3조 (약관의 효력 및 변경)',
                body:
                '1. 본 약관은 서비스 화면에 게시하거나 기타의 방법으로 회원에게 공지함으로써 효력을 발생합니다.\n'
                    '2. 서비스는 관련 법령을 위배하지 않는 범위에서 본 약관을 변경할 수 있으며, 변경 시 사전에 공지합니다.',
              ),
              _TermsSection(
                title: '제4조 (회원가입)',
                body:
                '이용자는 서비스가 정한 가입 양식에 따라 회원정보를 기입한 후 본 약관에 동의한다는 의사표시를 함으로써 '
                    '회원가입을 신청하며, 서비스는 이를 승낙함으로써 회원가입이 완료됩니다.',
              ),
              _TermsSection(
                title: '제5조 (회원의 의무)',
                body:
                '회원은 관계 법령, 본 약관의 규정, 이용안내 및 서비스와 관련하여 공지한 주의사항을 준수하여야 하며, '
                    '기타 서비스의 업무에 방해되는 행위를 하여서는 안 됩니다.',
              ),
              SizedBox(height: 24),
              Text(
                '※ 본 문서는 예시용 템플릿입니다. 실제 서비스 운영 전 법무 검토를 거친 약관으로 교체해주세요.',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TermsSection extends StatelessWidget {
  final String title;
  final String body;

  const _TermsSection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}