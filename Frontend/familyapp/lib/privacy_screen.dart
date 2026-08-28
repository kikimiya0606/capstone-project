import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F0EB),
        elevation: 0,
        foregroundColor: Colors.grey[800],
        title: const Text(
          '개인정보 제3자 제공 동의서',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'mood는 아래와 같이 개인정보를 제3자에게 제공하고 있습니다. '
                    '내용을 자세히 읽으신 후 동의 여부를 결정해주세요.',
                style: TextStyle(fontSize: 13, height: 1.6),
              ),
              const SizedBox(height: 24),
              _InfoTable(
                rows: const [
                  ['제공받는 자', '서비스 운영 및 데이터 처리 위탁업체'],
                  ['제공 목적', '회원 인증, 서비스 이용 기록 관리, 고객 지원'],
                  ['제공 항목', 'ID, 닉네임, 이메일, 생년월일'],
                  ['보유 및 이용 기간', '회원 탈퇴 시 또는 위탁 계약 종료 시까지'],
                ],
              ),
              const SizedBox(height: 24),
              Text(
                '동의를 거부할 권리 안내',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '이용자는 개인정보의 제3자 제공에 대한 동의를 거부할 권리가 있습니다. '
                    '다만, 동의를 거부할 경우 서비스 이용(회원가입)이 제한될 수 있습니다.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '※ 본 문서는 예시용 템플릿입니다. 실제 서비스 운영 전 법무 검토를 거친 동의서로 교체해주세요.',
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

class _InfoTable extends StatelessWidget {
  final List<List<String>> rows;

  const _InfoTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBE3),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: rows
            .map(
              (row) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    row[0],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    row[1],
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
            .toList(),
      ),
    );
  }
}