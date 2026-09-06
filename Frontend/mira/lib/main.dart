import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'design/mira_icons.dart';
import 'dog_room/controllers/dog_controller.dart';
import 'dog_room/services/dog_save_service.dart';
import 'dog_room/screens/dog_room_screen.dart';
import 'memories/memory_page.dart';
import 'privacy/privacy_screen.dart';

void main() => runApp(const MiraApp());
const ink = Color(0xFF263E34),
    violet = Color(0xFF315E50),
    cream = Color(0xFFF7F8F3);

class MiraApp extends StatelessWidget {
  const MiraApp({this.home, super.key});
  final Widget? home;
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'MIRA',
    theme: ThemeData(
      useMaterial3: true,
      splashFactory: InkRipple.splashFactory,
      fontFamily: 'Pretendard',
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 16, height: 1.55, color: ink),
        bodyMedium: TextStyle(fontSize: 15, height: 1.5, color: ink),
        bodySmall: TextStyle(
          fontSize: 13,
          height: 1.45,
          color: Color(0xFF68766D),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: cream,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          textStyle: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          side: const BorderSide(color: Color(0xFFD3DDD3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE3E8DF),
        thickness: 1,
      ),
      scaffoldBackgroundColor: cream,
      colorScheme: ColorScheme.fromSeed(seedColor: violet, surface: cream),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Color(0xFFFFFEFB),
        indicatorColor: Color(0xFFE3EBDF),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(18),
        ),
        contentPadding: const EdgeInsets.all(17),
      ),
    ),
    builder: (context, child) => ColoredBox(
      color: const Color(0xFFE9EEE7),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ClipRect(child: child!),
        ),
      ),
    ),
    home: home ?? const AppFlow(),
  );
}

enum Stage { onboarding, privacy, auth, profile, pet, app }

class AppFlow extends StatefulWidget {
  const AppFlow({super.key});
  @override
  State<AppFlow> createState() => _AppFlowState();
}

class _AppFlowState extends State<AppFlow> {
  Stage stage = Stage.onboarding;
  Future<void> _start() async {
    String? record;
    try {
      record = await SharedPreferencesAsync().getString(privacyKey);
    } catch (_) {
      /* Show the notice if storage is unavailable. */
    }
    if (mounted) {
      setState(
        () => stage = record?.startsWith('$privacyVersion|') == true
            ? Stage.auth
            : Stage.privacy,
      );
    }
  }

  @override
  Widget build(BuildContext context) => switch (stage) {
    Stage.onboarding => Onboarding(onDone: _start),
    Stage.privacy => PrivacyScreen(
      onDone: () => setState(() => stage = Stage.auth),
    ),
    Stage.auth => AuthScreen(
      onDone: () => setState(() => stage = Stage.profile),
    ),
    Stage.profile => ProfileSetup(
      onDone: () => setState(() => stage = Stage.pet),
    ),
    Stage.pet => PetSetup(onDone: () => setState(() => stage = Stage.app)),
    Stage.app => const MainShell(),
  };
}

class Onboarding extends StatefulWidget {
  const Onboarding({required this.onDone, super.key});
  final VoidCallback onDone;
  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final page = PageController();
  int index = 0;
  @override
  void dispose() {
    page.dispose();
    super.dispose();
  }

  final data = const [
    (
      '가족의 하루가\n하나의 이야기가 되도록',
      '감정과 일상, 함께한 순간을 MIRA가 다정하게 이어드려요.',
      CupertinoIcons.heart_fill,
      Color(0xFFFFD7CF),
    ),
    (
      '말하지 않아도\n놓치지 않는 작은 신호',
      '일기는 안전하게 지키고, 가족에게는 필요한 마음만 전해요.',
      CupertinoIcons.sparkles,
      Color(0xFFDCD8FF),
    ),
    (
      '우리 가족이 함께\n돌보는 새로운 친구',
      '매일 한 사람, 한 번의 참여가 가족의 세계를 키워요.',
      Icons.pets_rounded,
      Color(0xFFD9EFD7),
    ),
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        PageView.builder(
          controller: page,
          itemCount: 3,
          onPageChanged: (v) => setState(() => index = v),
          itemBuilder: (_, i) {
            final d = data[i];
            return SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 130),
                children: [
                  Row(
                    children: [
                      const Text(
                        'MIRA',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 4,
                          color: violet,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: widget.onDone,
                        child: const Text('건너뛰기'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Container(
                    height: 260,
                    decoration: BoxDecoration(
                      color: d.$4.withValues(alpha: .5),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'assets/dog/${['baby_idle', 'child_idle', 'baby_tail_01'][i]}.png',
                          height: 225,
                        ),
                        Positioned(
                          right: 24,
                          top: 24,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              [
                                CupertinoIcons.heart,
                                CupertinoIcons.sparkles,
                                CupertinoIcons.house,
                              ][i],
                              color: violet,
                              size: 25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 38),
                  Text(
                    d.$1,
                    style: const TextStyle(
                      fontSize: 30,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -.9,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    d.$2,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.7,
                      color: Color(0xFF68766D),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        Positioned(
          left: 28,
          right: 28,
          bottom: 34,
          child: Row(
            children: [
              ...List.generate(
                3,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: i == index ? 28 : 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 7),
                  decoration: BoxDecoration(
                    color: i == index ? ink : ink.withValues(alpha: .18),
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
              const Spacer(),
              FloatingActionButton(
                onPressed: () {
                  if (index == 2) {
                    widget.onDone();
                  } else {
                    page.nextPage(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOut,
                    );
                  }
                },
                backgroundColor: ink,
                foregroundColor: Colors.white,
                child: Icon(index == 2 ? Icons.check : Icons.arrow_forward),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({required this.onDone, super.key});
  final VoidCallback onDone;
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool signup = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 42),
            const Text(
              'MIRA',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 36),
            Text(
              signup ? '가족의 첫 페이지를\n만들어 볼까요?' : '다시 만나서\n반가워요',
              style: const TextStyle(
                fontSize: 34,
                height: 1.2,
                fontWeight: FontWeight.w700,
                letterSpacing: -1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              signup ? '가족 프로필을 설정하고 둘러보세요.' : '우리 가족의 오늘을 확인해 보세요.',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            const Text(
              '현재는 체험 화면이에요. 실제 비밀번호를 입력하지 않아도 시작할 수 있어요.',
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Color(0xFF68766D),
              ),
            ),
            const SizedBox(height: 24),
            if (signup) ...[
              const TextField(decoration: InputDecoration(labelText: '이름')),
              const SizedBox(height: 12),
            ],
            const TextField(
              decoration: InputDecoration(
                labelText: '이메일',
                prefixIcon: Icon(CupertinoIcons.envelope),
              ),
            ),
            const SizedBox(height: 12),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: '비밀번호',
                prefixIcon: Icon(CupertinoIcons.lock),
              ),
            ),
            if (signup) ...[
              const SizedBox(height: 12),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(labelText: '비밀번호 확인'),
              ),
            ],
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: widget.onDone,
                style: FilledButton.styleFrom(
                  backgroundColor: ink,
                  padding: const EdgeInsets.all(18),
                ),
                child: Text(signup ? '프로필 만들기 · 체험' : '로그인 · 체험'),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => setState(() => signup = !signup),
                child: Text(signup ? '이미 계정이 있어요 · 로그인' : '처음이신가요? · 회원가입'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class SetupFrame extends StatelessWidget {
  const SetupFrame({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.child,
    super.key,
  });
  final String step, title, subtitle;
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              step,
              style: const TextStyle(
                color: violet,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 32,
                height: 1.2,
                fontWeight: FontWeight.w700,
                letterSpacing: -1.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(subtitle, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 32),
            child,
          ],
        ),
      ),
    ),
  );
}

class ProfileSetup extends StatefulWidget {
  const ProfileSetup({required this.onDone, super.key});
  final VoidCallback onDone;
  @override
  State<ProfileSetup> createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup> {
  String role = '딸';
  @override
  Widget build(BuildContext context) => SetupFrame(
    step: '01 / 02',
    title: '가족에게 나는\n어떤 사람인가요?',
    subtitle: '첫 로그인에 한 번만 설정하면 돼요.',
    child: Column(
      children: [
        Wrap(
          spacing: 8,
          children: ['아빠', '엄마', '아들', '딸']
              .map(
                (e) => ChoiceChip(
                  avatar: Text(
                    {'아빠': '👨', '엄마': '👩', '아들': '👦', '딸': '👧'}[e]!,
                  ),
                  label: Text(e),
                  selected: role == e,
                  onSelected: (_) => setState(() => role = e),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 20),
        const TextField(
          decoration: InputDecoration(labelText: '이름', hintText: '권유진'),
        ),
        const SizedBox(height: 12),
        const TextField(
          readOnly: true,
          decoration: InputDecoration(
            labelText: '생년월일',
            hintText: '2002. 03. 14',
            suffixIcon: Icon(CupertinoIcons.calendar),
          ),
        ),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(
            labelText: '가족 초대 코드',
            hintText: '나중에 입력해도 괜찮아요',
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: widget.onDone,
            style: FilledButton.styleFrom(padding: const EdgeInsets.all(18)),
            child: const Text('반려견 설정으로'),
          ),
        ),
      ],
    ),
  );
}

class PetSetup extends StatefulWidget {
  const PetSetup({required this.onDone, super.key});
  final VoidCallback onDone;
  @override
  State<PetSetup> createState() => _PetSetupState();
}

class _PetSetupState extends State<PetSetup> {
  bool photo = true;
  String personality = '활발함';
  @override
  Widget build(BuildContext context) => SetupFrame(
    step: '02 / 02 · 화면 목업',
    title: '우리 가족의 친구를\n소개해 주세요',
    subtitle: 'AI 생성과 실제 저장은 추후 연동할 예정이에요.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(
              value: true,
              label: Text('사진으로 만들기'),
              icon: Icon(CupertinoIcons.sparkles),
            ),
            ButtonSegment(
              value: false,
              label: Text('직접 꾸미기'),
              icon: Icon(CupertinoIcons.slider_horizontal_3),
            ),
          ],
          selected: {photo},
          onSelectionChanged: (v) => setState(() => photo = v.first),
        ),
        const SizedBox(height: 18),
        if (photo)
          Container(
            height: 165,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9F8),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: violet.withValues(alpha: .25)),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.photo_on_rectangle,
                  size: 44,
                  color: violet,
                ),
                SizedBox(height: 8),
                Text(
                  '강아지 사진 최대 5장',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  'AI 외형 생성 목업',
                  style: TextStyle(color: Colors.black45, fontSize: 12),
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              const TextField(
                decoration: InputDecoration(labelText: '견종', hintText: '토이 푸들'),
              ),
              const SizedBox(height: 12),
              const TextField(
                decoration: InputDecoration(
                  labelText: '털 색상과 특징',
                  hintText: '크림색 · 곱슬',
                ),
              ),
            ],
          ),
        const SizedBox(height: 22),
        const Text('성격', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: ['활발함', '애교쟁이', '호기심', '차분함']
              .map(
                (e) => ChoiceChip(
                  label: Text(e),
                  selected: personality == e,
                  onSelected: (_) => setState(() => personality = e),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 18),
        const TextField(
          decoration: InputDecoration(labelText: '이름', hintText: '보리'),
        ),
        const SizedBox(height: 26),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: widget.onDone,
            style: FilledButton.styleFrom(padding: const EdgeInsets.all(18)),
            child: const Text('MIRA 시작하기'),
          ),
        ),
      ],
    ),
  );
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;
  late final DogController dog = DogController(
    SharedPreferencesDogSaveService(),
  );
  @override
  void dispose() {
    dog.dispose();
    super.dispose();
  }

  Future<void> _clearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('기기에 저장한 데이터를 삭제할까요?'),
        content: const Text(
          '사진·글·댓글·좋아요와 강아지 성장, 안내 확인 기록이 삭제돼요. 원본 사진은 지워지지 않아요.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      final prefs = SharedPreferencesAsync();
      await dog.flush();
      for (final key in [MemoryStore.storageKey, 'dog_state_v1', privacyKey]) {
        await prefs.remove(key);
      }
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const AppFlow()),
          (_) => false,
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('삭제를 완료하지 못했어요. 다시 시도해 주세요.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        onAttendance: _attendance,
        dog: dog,
        active: index == 0,
        onOpenPet: () => setState(() => index = 1),
      ),
      index == 1 ? PetPage(controller: dog) : const SizedBox.shrink(),
      const FamilyPage(),
      const MemoryPage(),
      const AiPage(),
      SettingsPage(onClearData: _clearData),
    ];
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: index, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        height: 76,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: [
          for (final item in const [
            (MiraSymbol.home, '홈'),
            (MiraSymbol.paw, '펫'),
            (MiraSymbol.family, '가족'),
            (MiraSymbol.album, '사진첩'),
            (MiraSymbol.sparkle, 'MIRA'),
            (MiraSymbol.settings, '설정'),
          ])
            NavigationDestination(
              icon: MiraIcon(item.$1),
              selectedIcon: MiraIcon(item.$1, selected: true),
              label: item.$2,
            ),
        ],
      ),
    );
  }

  void _attendance() => showDialog(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('오늘의 돌봄을 정할게요'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CareLine('👩 엄마', '🍪 간식 주기'),
          CareLine('👨 아빠', '🎾 공놀이'),
          CareLine('👧 나', '🦮 산책하기'),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(c),
          child: const Text('출석하고 시작하기'),
        ),
      ],
    ),
  );
}

class AppPage extends StatelessWidget {
  const AppPage({
    required this.title,
    required this.child,
    this.actions,
    super.key,
  });
  final String title;
  final Widget child;
  final List<Widget>? actions;
  @override
  Widget build(BuildContext context) => CustomScrollView(
    slivers: [
      SliverAppBar(
        floating: true,
        backgroundColor: cream,
        surfaceTintColor: Colors.transparent,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: -.7,
          ),
        ),
        actions: actions,
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 35),
        sliver: SliverToBoxAdapter(child: child),
      ),
    ],
  );
}

class HomePage extends StatelessWidget {
  const HomePage({
    required this.onAttendance,
    required this.dog,
    required this.active,
    required this.onOpenPet,
    super.key,
  });
  final DogController dog;
  final bool active;
  final VoidCallback onOpenPet;
  final VoidCallback onAttendance;
  @override
  Widget build(BuildContext context) => AppPage(
    title: 'MIRA',
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 18),
        child: Chip(
          avatar: const Icon(
            CupertinoIcons.leaf_arrow_circlepath,
            size: 16,
            color: violet,
          ),
          label: const Text('우리 가족의 하루'),
          side: BorderSide.none,
          backgroundColor: const Color(0xFFE7EDE2),
        ),
      ),
    ],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${DateTime.now().month}월 ${DateTime.now().day}일 · 오늘도 함께',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: Color(0xFF9C9891),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '함께라서 좋은 하루예요.',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.1,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(
              child: Text(
                '우리 집 작은 친구',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            TextButton.icon(
              onPressed: onOpenPet,
              icon: const Icon(
                CupertinoIcons.arrow_up_left_arrow_down_right,
                size: 16,
              ),
              label: const Text('크게 보기'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: SizedBox(
            height: 590,
            child: active
                ? DogRoomScreen(controller: dog)
                : const SizedBox.shrink(),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onAttendance,
            icon: const Icon(CupertinoIcons.sun_max),
            label: const Text(
              '오늘의 출석 체크  →',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: ink,
              padding: const EdgeInsets.all(19),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Section('가족 퀘스트', '오늘 1 / 2'),
        const SizedBox(height: 12),
        const QuestCard(
          icon: '🍽️',
          title: '저녁 식탁에서 오늘 일 하나씩',
          detail: '가족 모두 참여 · Family Energy +40',
          progress: .66,
          color: Color(0xFFFFE8CF),
        ),
        const SizedBox(height: 12),
        const QuestCard(
          icon: '📷',
          title: '우리 가족 오늘 한 컷',
          detail: '사진 1장을 추억에 남겨 보세요',
          progress: 0,
          color: Color(0xFFDDECE3),
        ),
        const SizedBox(height: 28),
        const Section('나의 일일 퀘스트', '2 / 3 완료'),
        const SizedBox(height: 12),
        const DailyQuest(icon: '🦮', title: '보리와 15분 산책', done: true),
        const SizedBox(height: 8),
        const DailyQuest(icon: '✍️', title: '오늘의 감정 한 줄 기록', done: true),
        const SizedBox(height: 8),
        const DailyQuest(icon: '💬', title: '가족 일기에 반응 남기기', done: false),
        const SizedBox(height: 28),
        const Section('오늘의 가족 돌봄', '2 / 3 완료'),
        const SizedBox(height: 12),
        const Card(
          child: Column(
            children: [
              CareLine('👩 엄마', '🍪 간식 · 완료'),
              CareLine('👧 나', '🦮 산책 · 완료'),
              CareLine('👨 아빠', '🎾 공놀이 · 대기'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Row(
          children: [
            Expanded(child: Metric('☀️', 'Family Mood', '82')),
            SizedBox(width: 10),
            Expanded(child: Metric('⚡', 'Family Energy', '680')),
          ],
        ),
      ],
    ),
  );
}

class PetPage extends StatelessWidget {
  const PetPage({required this.controller, super.key});
  final DogController controller;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final minimumHeight =
          600.0 + (MediaQuery.textScalerOf(context).scale(14) - 14) * 5;
      if (constraints.maxHeight >= minimumHeight) {
        return DogRoomScreen(controller: controller);
      }
      return SingleChildScrollView(
        child: SizedBox(
          height: minimumHeight,
          child: DogRoomScreen(controller: controller),
        ),
      );
    },
  );
}

class FamilyPage extends StatefulWidget {
  const FamilyPage({super.key});
  @override
  State<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  int likes = 12;
  @override
  Widget build(BuildContext context) => AppPage(
    title: '가족 이야기',
    actions: [
      IconButton(
        onPressed: () => _write(context),
        icon: const Icon(Icons.edit_square),
      ),
    ],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Section('오늘의 가족 마음', '공개 범위 설정'),
        const SizedBox(height: 12),
        DiaryCard(
          name: '엄마',
          mood: '조금 지쳤지만 괜찮아요',
          body: '퇴근길 하늘이 예뻐서 잠깐 멈춰 봤어. 다들 오늘 하루도 고생했어.',
          likes: likes,
          onLike: () => setState(() => likes++),
          comments: 3,
        ),
        const SizedBox(height: 14),
        const DiaryCard(
          name: '나',
          mood: '뿌듯해요',
          body: '미뤄두었던 과제를 끝냈다. 저녁에는 보리랑 산책도 해야지!',
          likes: 8,
          comments: 2,
        ),
        const SizedBox(height: 22),
        const Section('가족 상호작용', '최근 7일 +18%'),
        const SizedBox(height: 10),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(18),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: .78,
                  minHeight: 9,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                SizedBox(height: 12),
                Text(
                  '댓글 14 · 좋아요 31 · 함께한 활동 5',
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
  void _write(BuildContext context) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (c) => Padding(
      padding: EdgeInsets.fromLTRB(
        22,
        5,
        22,
        MediaQuery.viewInsetsOf(c).bottom + 25,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '오늘의 마음 기록',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 15),
          const TextField(
            maxLines: 5,
            decoration: InputDecoration(hintText: '가족과 나누고 싶은 이야기를 적어보세요.'),
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 8,
            children: [
              Chip(label: Text('가족 공개')),
              Chip(label: Text('댓글 허용')),
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('기록하기'),
            ),
          ),
        ],
      ),
    ),
  );
}

class DiaryCard extends StatelessWidget {
  const DiaryCard({
    required this.name,
    required this.mood,
    required this.body,
    required this.likes,
    required this.comments,
    this.onLike,
    super.key,
  });
  final String name, mood, body;
  final int likes, comments;
  final VoidCallback? onLike;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(child: Text('👩')),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    mood,
                    style: const TextStyle(fontSize: 12, color: violet),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(body, style: const TextStyle(height: 1.6)),
          const Divider(height: 28),
          Row(
            children: [
              TextButton.icon(
                onPressed: onLike,
                icon: const Icon(CupertinoIcons.heart, size: 19),
                label: Text('$likes'),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(CupertinoIcons.chat_bubble, size: 18),
                label: Text('$comments'),
              ),
              const Spacer(),
              const Icon(Icons.more_horiz),
            ],
          ),
        ],
      ),
    ),
  );
}

class AiPage extends StatelessWidget {
  const AiPage({super.key});
  @override
  Widget build(BuildContext context) => AppPage(
    title: 'MIRA 인사이트',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: ink,
            borderRadius: BorderRadius.circular(28),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(CupertinoIcons.sparkles, color: Color(0xFFDCD8FF), size: 30),
              SizedBox(height: 24),
              Text(
                '이번 주, 우리 가족은\n조금 더 가까워졌어요.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '긍정적인 직접 상호작용이 18% 늘었어요.',
                style: TextStyle(color: Colors.white60),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Section('살펴볼 신호', '최근 14일'),
        const SizedBox(height: 10),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Insight('대화', '↑ 18%', '댓글과 답장이 늘었어요'),
                Divider(height: 28),
                Insight('함께한 활동', '→ 유지', '주말 산책을 이어가 보세요'),
                Divider(height: 28),
                Insight('아빠 ↔ 나', '↓ 8%', '짧은 안부 대화를 추천해요'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        const TextField(
          decoration: InputDecoration(
            hintText: 'MIRA에게 우리 가족에 대해 물어보세요',
            suffixIcon: Icon(Icons.arrow_upward_rounded),
          ),
        ),
      ],
    ),
  );
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({required this.onClearData, super.key});
  final VoidCallback onClearData;
  @override
  Widget build(BuildContext context) => AppPage(
    title: '설정',
    child: Column(
      children: [
        const Card(
          child: ListTile(
            leading: CircleAvatar(child: Text('👧')),
            title: Text('권유진', style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text('우리 가족 · 딸'),
            trailing: Icon(CupertinoIcons.chevron_right),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Column(
            children: [
              setting(CupertinoIcons.person_2, '가족 관리', '초대 코드 · 구성원'),
              setting(CupertinoIcons.paw, '반려견 설정', '프로필 · 커스터마이징'),
              setting(CupertinoIcons.bell, '알림', '돌봄 · 댓글 · 일정'),
              ListTile(
                leading: const Icon(CupertinoIcons.lock_shield),
                title: const Text('개인정보 처리방침'),
                subtitle: const Text('저장하는 정보 · 사진 접근 · 삭제'),
                trailing: const Icon(CupertinoIcons.chevron_right, size: 18),
                onTap: () => showPrivacyDocument(context),
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.doc_text),
                title: const Text('이용 안내'),
                trailing: const Icon(CupertinoIcons.chevron_right, size: 18),
                onTap: () => showPrivacyDocument(context, terms: true),
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.trash),
                title: const Text('기기에 저장한 데이터 삭제'),
                subtitle: const Text('사진첩 · 강아지 성장 · 안내 확인 기록'),
                onTap: onClearData,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Column(
            children: [
              setting(CupertinoIcons.paintbrush, '화면 설정', '테마 · 글자 크기'),
              setting(CupertinoIcons.question_circle, '도움말', '자주 묻는 질문'),
              setting(CupertinoIcons.info_circle, '앱 정보', 'MIRA 1.0.0'),
            ],
          ),
        ),
      ],
    ),
  );
  static Widget setting(IconData icon, String title, String sub) => ListTile(
    leading: Icon(icon),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
    subtitle: Text(sub),
    trailing: const Icon(CupertinoIcons.chevron_right),
  );
}

class QuestCard extends StatelessWidget {
  const QuestCard({
    required this.icon,
    required this.title,
    required this.detail,
    required this.progress,
    required this.color,
    super.key,
  });
  final String icon, title, detail;
  final double progress;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(19),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(26),
    ),
    child: Row(
      children: [
        Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .7),
            borderRadius: BorderRadius.circular(17),
          ),
          child: Text(icon, style: const TextStyle(fontSize: 25)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.3,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                detail,
                style: const TextStyle(fontSize: 11, color: Color(0xFF77716A)),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  backgroundColor: Colors.white.withValues(alpha: .65),
                  color: ink,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      ],
    ),
  );
}

class DailyQuest extends StatelessWidget {
  const DailyQuest({
    required this.icon,
    required this.title,
    required this.done,
    super.key,
  });
  final String icon, title;
  final bool done;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFEAE6DF)),
    ),
    child: Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 21)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: done ? const Color(0xFF928E87) : ink,
              decoration: done ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? ink : Colors.transparent,
            border: Border.all(
              color: done ? ink : const Color(0xFFD7D2CA),
              width: 1.5,
            ),
          ),
          child: done
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : null,
        ),
      ],
    ),
  );
}

class CareLine extends StatelessWidget {
  const CareLine(this.who, this.action, {super.key});
  final String who, action;
  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(who, style: const TextStyle(fontWeight: FontWeight.w700)),
    trailing: Text(action),
  );
}

class Metric extends StatelessWidget {
  const Metric(this.icon, this.label, this.value, {super.key});
  final String icon, label, value;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$icon  $label',
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    ),
  );
}

class Section extends StatelessWidget {
  const Section(this.title, this.tail, {super.key});
  final String title, tail;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
      const Spacer(),
      Text(
        tail,
        style: const TextStyle(
          fontSize: 11,
          color: violet,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class Insight extends StatelessWidget {
  const Insight(this.label, this.value, this.desc, {super.key});
  final String label, value, desc;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              desc,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
      Text(
        value,
        style: const TextStyle(color: violet, fontWeight: FontWeight.w700),
      ),
    ],
  );
}
