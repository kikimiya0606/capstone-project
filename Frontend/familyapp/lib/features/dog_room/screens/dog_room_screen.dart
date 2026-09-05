import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../controllers/dog_controller.dart';
import '../models/dog_state.dart';
import '../widgets/care_action_bar.dart';
import '../widgets/dog_status_panel.dart';

class DogRoomScreen extends StatefulWidget {
  const DogRoomScreen({super.key, required this.controller});
  final DogController controller;

  @override
  State<DogRoomScreen> createState() => _DogRoomScreenState();
}

class _DogRoomScreenState extends State<DogRoomScreen>
    with TickerProviderStateMixin {
  final Random _random = Random();
  Timer? _moveTimer;
  Timer? _actionTimer;
  Timer? _frameTimer;
  double _dogX = 80;
  double _dogY = 100;
  bool _isMoving = false;
  bool _isFacingRight = true;
  bool _didPrecacheImages = false;
  bool _didSetInitialPosition = false;
  bool _isCareTransition = false;
  CareAction? _activeAction;
  int _walkFrame = 0;
  late final AnimationController _breathingController;
  late final AnimationController _tapController;
  late final AnimationController _careController;
  Size _roomViewport = Size.zero;
  Duration _moveDuration = const Duration(seconds: 3);

  static const _babyWalkFrames = [
    'assets/dog_room/dog/baby_walk_01.png',
    'assets/dog_room/dog/baby_walk_02.png',
    'assets/dog_room/dog/baby_walk_03.png',
    'assets/dog_room/dog/baby_walk_04.png',
  ];

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _careController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 460),
    );
    widget.controller.addListener(_refresh);
    widget.controller.initialize();
    _moveTimer = Timer(const Duration(seconds: 1), _moveDog);
    _frameTimer = Timer.periodic(const Duration(milliseconds: 125), (_) {
      if (!mounted || !_isMoving) {
        return;
      }
      setState(() => _walkFrame = (_walkFrame + 1) % _babyWalkFrames.length);
    });
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didSetInitialPosition) {
      _didSetInitialPosition = true;
      final roomHeight = max(260.0, MediaQuery.sizeOf(context).height - 270);
      _dogY = roomHeight * .58;
    }
    if (_didPrecacheImages) return;
    _didPrecacheImages = true;
    for (final stage in GrowthStage.values) {
      precacheImage(AssetImage(stage.assetPath), context);
    }
    for (final frame in _babyWalkFrames) {
      precacheImage(AssetImage(frame), context);
    }
    precacheImage(
      const AssetImage('assets/dog_room/dog/baby_sleep.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/dog_room/room/room_background.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/dog_room/furniture/bed.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/dog_room/furniture/food_bowl.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/dog_room/furniture/bathtub.png'),
      context,
    );
  }

  void _moveDog() {
    if (!mounted || _activeAction != null || _isCareTransition) return;
    final size = _roomViewport == Size.zero
        ? MediaQuery.sizeOf(context)
        : _roomViewport;
    const dogSize = 140.0;
    final maxX = max(20.0, size.width - dogSize - 20);
    final roomHeight = _roomViewport == Size.zero
        ? max(260.0, size.height - 270)
        : size.height;
    final minY = roomHeight * .46;
    final maxY = max(minY, roomHeight - dogSize - 8);
    var nextX = _dogX;
    var nextY = _dogY;
    for (var attempt = 0; attempt < 16; attempt++) {
      final candidateX = 20 + _random.nextDouble() * max(0, maxX - 20);
      final candidateY = minY + _random.nextDouble() * max(0, maxY - minY);
      if (!_isRoamingPositionBlocked(candidateX, candidateY, size)) {
        nextX = candidateX;
        nextY = candidateY;
        break;
      }
    }
    setState(() {
      _moveDuration = const Duration(seconds: 3);
      if ((nextX - _dogX).abs() > 1) {
        _isFacingRight = nextX > _dogX;
      }
      _dogX = nextX;
      _dogY = nextY;
      _isMoving = true;
    });
    _moveTimer?.cancel();
    _moveTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _isMoving = false);
      _walkFrame = 0;
      _moveTimer = Timer(Duration(seconds: 2 + _random.nextInt(4)), _moveDog);
    });
  }

  bool _isRoamingPositionBlocked(double x, double y, Size roomSize) {
    final dogFeet = Rect.fromLTWH(x + 22, y + 88, 96, 44);
    final bedZone = Rect.fromLTWH(
      max(0, roomSize.width - 184),
      max(0, roomSize.height - 202),
      176,
      132,
    );
    final bowlZone = Rect.fromLTWH(6, max(0, roomSize.height - 92), 102, 82);
    final bathtubZone = Rect.fromLTWH(
      4,
      max(0, roomSize.height - 258),
      184,
      164,
    );
    return dogFeet.overlaps(bedZone) ||
        dogFeet.overlaps(bowlZone) ||
        dogFeet.overlaps(bathtubZone);
  }

  Future<void> _handleDogTap() async {
    if (_isMoving ||
        _activeAction != null ||
        _isCareTransition ||
        _tapController.isAnimating) {
      return;
    }
    _moveTimer?.cancel();
    setState(() {
      _isMoving = false;
      _walkFrame = 0;
    });
    await _tapController.forward(from: 0);
    if (!mounted) return;
    _moveTimer = Timer(const Duration(milliseconds: 900), _moveDog);
  }

  Future<void> _performCare(CareAction action) async {
    if (_activeAction != null || _isCareTransition) return;
    _moveTimer?.cancel();
    if (action == CareAction.feed ||
        action == CareAction.wash ||
        action == CareAction.sleep) {
      final targetX = switch (action) {
        CareAction.feed => 68.0,
        CareAction.wash => 24.0,
        CareAction.sleep => max(12.0, _roomViewport.width - 166),
        CareAction.play => _dogX,
      };
      final targetY = switch (action) {
        CareAction.wash => max(72.0, _roomViewport.height - 220),
        CareAction.sleep => max(72.0, _roomViewport.height - 225),
        _ => max(72.0, _roomViewport.height - 154),
      };
      setState(() {
        _isCareTransition = true;
        _moveDuration = const Duration(milliseconds: 900);
        _isFacingRight = targetX > _dogX;
        _dogX = targetX;
        _dogY = targetY;
        _isMoving = true;
      });
      await Future<void>.delayed(const Duration(milliseconds: 950));
      if (!mounted) return;
    }
    final previousStage = widget.controller.state.stage;
    final previousLevel = widget.controller.state.level;
    final succeeded = await widget.controller.care(action);
    if (!mounted) return;
    if (!succeeded) {
      setState(() {
        _isCareTransition = false;
        _isMoving = false;
      });
      _moveTimer = Timer(const Duration(seconds: 1), _moveDog);
      return;
    }

    _moveTimer?.cancel();
    setState(() {
      _isCareTransition = false;
      _activeAction = action;
      _isMoving = false;
      if (action == CareAction.feed) _isFacingRight = false;
      if (action == CareAction.wash) _isFacingRight = true;
    });
    if (action == CareAction.sleep) {
      _careController.duration = const Duration(milliseconds: 650);
      _careController.forward(from: 0);
    } else if (action == CareAction.feed ||
        action == CareAction.wash ||
        action == CareAction.play) {
      _careController.duration = const Duration(milliseconds: 460);
      _careController.repeat();
    }
    _actionTimer?.cancel();
    _actionTimer = Timer(const Duration(milliseconds: 1700), () {
      if (!mounted) return;
      _careController.stop();
      _careController.reset();
      setState(() => _activeAction = null);
      _moveTimer = Timer(const Duration(milliseconds: 700), _moveDog);
    });

    final newStage = widget.controller.state.stage;
    final newLevel = widget.controller.state.level;
    if (newStage != previousStage) {
      await _showGrowthDialog(newStage);
    } else if (newStage == GrowthStage.adult && newLevel > previousLevel) {
      await _showAdultRewardDialog(newLevel);
    }
  }

  Future<void> _addDebugExperience() async {
    final previousStage = widget.controller.state.stage;
    final previousLevel = widget.controller.state.level;
    await widget.controller.addDebugExperience();
    if (!mounted) return;
    final newStage = widget.controller.state.stage;
    final newLevel = widget.controller.state.level;
    if (newStage != previousStage) {
      await _showGrowthDialog(newStage);
    } else if (newStage == GrowthStage.adult && newLevel > previousLevel) {
      await _showAdultRewardDialog(newLevel);
    }
  }

  Future<void> _showAdultRewardDialog(int level) {
    final reward = AdultReward.values[(level - 32) % AdultReward.values.length];
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.card_giftcard,
          color: Color(0xFFF2A65A),
          size: 44,
        ),
        title: Text('Lv.$level 달성!'),
        content: Text(
          '${reward.label} 보상이 해금됐어요!',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Future<void> _showGrowthDialog(GrowthStage stage) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.auto_awesome,
          color: Color(0xFFF2A65A),
          size: 44,
        ),
        title: const Text('축하해요!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(stage.assetPath, width: 150, height: 150),
            const SizedBox(height: 12),
            Text('${stage.label} 포메로 성장했어요!', textAlign: TextAlign.center),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('좋아!'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _moveTimer?.cancel();
    _actionTimer?.cancel();
    _frameTimer?.cancel();
    _breathingController.dispose();
    _tapController.dispose();
    _careController.dispose();
    widget.controller.removeListener(_refresh);
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final state = widget.controller.state;
    final isBabySleeping =
        state.stage == GrowthStage.baby && _activeAction == CareAction.sleep;
    final dogAsset = state.stage == GrowthStage.baby && _isMoving
        ? _babyWalkFrames[_walkFrame]
        : isBabySleeping
        ? 'assets/dog_room/dog/baby_sleep.png'
        : state.stage.assetPath;
    return Scaffold(
      appBar: AppBar(title: const Text('강아지 방')),
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: SizedBox(
              height: max(680, constraints.maxHeight),
              child: Column(
                children: [
                  DogStatusPanel(state: state),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        _roomViewport = constraints.biggest;
                        return Stack(
                          children: [
                            Positioned.fill(
                              child: Image.asset(
                                'assets/dog_room/room/room_background.png',
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                              ),
                            ),
                            Positioned(
                              right: 12,
                              bottom: 68,
                              child: Image.asset(
                                'assets/dog_room/furniture/bed.png',
                                width: 162,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Positioned(
                              left: 18,
                              bottom: 18,
                              child: Image.asset(
                                'assets/dog_room/furniture/food_bowl.png',
                                width: 68,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Positioned(
                              left: 8,
                              bottom: 86,
                              child: Image.asset(
                                'assets/dog_room/furniture/bathtub.png',
                                width: 174,
                                fit: BoxFit.contain,
                              ),
                            ),
                            if (_activeAction == CareAction.sleep)
                              Positioned.fill(
                                child: AnimatedBuilder(
                                  animation: _careController,
                                  builder: (context, _) => ColoredBox(
                                    color: const Color(0xFF26344A).withValues(
                                      alpha: .18 * _careController.value,
                                    ),
                                  ),
                                ),
                              ),
                            Positioned(
                              top: 12,
                              left: 16,
                              right: 16,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: .88),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  child: Text(
                                    widget.controller.message,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            AnimatedPositioned(
                              key: const ValueKey('dog-position'),
                              duration: _moveDuration,
                              curve: Curves.easeInOut,
                              left: _dogX.clamp(
                                0,
                                max(0, constraints.maxWidth - 140),
                              ),
                              top: _dogY.clamp(
                                64,
                                max(64, constraints.maxHeight - 140),
                              ),
                              child: GestureDetector(
                                onTap: _handleDogTap,
                                child: AnimatedBuilder(
                                  animation: Listenable.merge([
                                    _breathingController,
                                    _tapController,
                                    _careController,
                                  ]),
                                  builder: (context, child) {
                                    final breathing =
                                        !_isMoving && _activeAction == null
                                        ? _breathingController.value
                                        : 0.0;
                                    final tapBounce =
                                        sin(pi * _tapController.value) *
                                        (1 - _tapController.value);
                                    final eating =
                                        _activeAction == CareAction.feed
                                        ? (1 -
                                                  cos(
                                                    2 *
                                                        pi *
                                                        _careController.value,
                                                  )) /
                                              2
                                        : 0.0;
                                    final walking =
                                        _isMoving && _walkFrame.isOdd
                                        ? 1.0
                                        : 0.0;
                                    final playing =
                                        _activeAction == CareAction.play
                                        ? sin(pi * _careController.value)
                                        : 0.0;
                                    return Transform.rotate(
                                      angle: -.065 * eating,
                                      alignment: Alignment.bottomCenter,
                                      child: Transform.translate(
                                        offset: Offset(
                                          -2 * eating,
                                          -2 * breathing -
                                              6 * tapBounce +
                                              5 * eating -
                                              3 * walking -
                                              8 * playing,
                                        ),
                                        child: Transform.scale(
                                          scaleX:
                                              1 +
                                              .018 * breathing +
                                              .012 * tapBounce,
                                          scaleY:
                                              1 +
                                              .018 * breathing +
                                              .012 * tapBounce -
                                              .018 * eating,
                                          alignment: Alignment.bottomCenter,
                                          child: child,
                                        ),
                                      ),
                                    );
                                  },
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 900),
                                    switchInCurve: Curves.easeOutBack,
                                    switchOutCurve: Curves.easeIn,
                                    transitionBuilder: (child, animation) =>
                                        FadeTransition(
                                          opacity: animation,
                                          child: ScaleTransition(
                                            scale: Tween<double>(
                                              begin: .72,
                                              end: 1,
                                            ).animate(animation),
                                            child: child,
                                          ),
                                        ),
                                    child: Transform.flip(
                                      key: ValueKey((
                                        state.stage,
                                        isBabySleeping,
                                      )),
                                      flipX: !_isFacingRight,
                                      child: Image.asset(
                                        dogAsset,
                                        width: 140,
                                        height: 140,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const SizedBox(
                                                  width: 140,
                                                  height: 140,
                                                  child: Icon(
                                                    Icons.pets,
                                                    size: 80,
                                                  ),
                                                ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: (_dogX + 86).clamp(
                                8,
                                max(8, constraints.maxWidth - 54),
                              ),
                              top: (_dogY + 5).clamp(
                                52,
                                max(52, constraints.maxHeight - 54),
                              ),
                              child: AnimatedBuilder(
                                animation: _tapController,
                                builder: (context, child) {
                                  final progress = _tapController.value;
                                  final opacity = sin(
                                    pi * progress,
                                  ).clamp(0.0, 1.0);
                                  return IgnorePointer(
                                    child: Opacity(
                                      opacity: opacity,
                                      child: Transform.translate(
                                        offset: Offset(0, -48 * progress),
                                        child: Transform.scale(
                                          scale: .7 + .5 * progress,
                                          child: child,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: const Icon(
                                  Icons.favorite,
                                  color: Color(0xFFE86A76),
                                  size: 36,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 16,
                              bottom: 14,
                              child: Row(
                                children: [
                                  if (kDebugMode)
                                    IconButton.filledTonal(
                                      tooltip: '성장 테스트 +100 XP',
                                      onPressed: _addDebugExperience,
                                      icon: const Icon(Icons.science),
                                    ),
                                  const SizedBox(width: 6),
                                  Chip(
                                    avatar: const Icon(
                                      Icons.auto_awesome,
                                      size: 17,
                                    ),
                                    label: Text('${state.experience} XP'),
                                  ),
                                ],
                              ),
                            ),
                            if (_activeAction != null)
                              Positioned(
                                left:
                                    (_dogX +
                                            (_activeAction == CareAction.wash
                                                ? 5
                                                : 82))
                                        .clamp(
                                          10,
                                          max(
                                            10,
                                            constraints.maxWidth -
                                                (_activeAction ==
                                                        CareAction.wash
                                                    ? 135
                                                    : 90),
                                          ),
                                        ),
                                top:
                                    (_dogY +
                                            (_activeAction == CareAction.wash
                                                ? 20
                                                : -8))
                                        .clamp(
                                          58,
                                          max(
                                            58,
                                            constraints.maxHeight -
                                                (_activeAction ==
                                                        CareAction.wash
                                                    ? 115
                                                    : 100),
                                          ),
                                        ),
                                child: _activeAction == CareAction.wash
                                    ? _BathBubbles(animation: _careController)
                                    : _activeAction == CareAction.play
                                    ? _PlayBall(animation: _careController)
                                    : _activeAction == CareAction.sleep
                                    ? _SleepZzz(animation: _breathingController)
                                    : _CareEffect(
                                        key: ValueKey(_activeAction),
                                        action: _activeAction!,
                                      ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  CareActionBar(
                    onAction: _performCare,
                    enabled: _activeAction == null && !_isCareTransition,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SleepZzz extends StatelessWidget {
  const _SleepZzz({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: 72,
        height: 92,
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final progress = animation.value;
            return Opacity(
              opacity: sin(pi * progress).clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(8 * progress, -34 * progress),
                child: Transform.scale(
                  scale: .75 + .35 * progress,
                  child: const Text(
                    'Zzz',
                    style: TextStyle(
                      color: Color(0xFF7E78C8),
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      shadows: [Shadow(color: Colors.white, blurRadius: 5)],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PlayBall extends StatelessWidget {
  const _PlayBall({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: 76,
        height: 90,
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final progress = animation.value;
            final height = sin(pi * progress) * 48;
            return Transform.translate(
              offset: Offset(-38 * progress, 24 - height),
              child: Transform.rotate(angle: progress * pi * 2, child: child),
            );
          },
          child: const Icon(
            Icons.sports_baseball,
            size: 34,
            color: Color(0xFFE86A76),
            shadows: [Shadow(color: Color(0x55000000), blurRadius: 5)],
          ),
        ),
      ),
    );
  }
}

class _BathBubbles extends StatelessWidget {
  const _BathBubbles({required this.animation});

  final Animation<double> animation;

  static const _bubbles = <(double, double, double, double)>[
    (2, 58, 18, 0),
    (30, 78, 13, .18),
    (56, 50, 21, .36),
    (82, 72, 15, .54),
    (105, 42, 19, .72),
    (43, 22, 11, .86),
  ];

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: 130,
        height: 110,
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, _) => Stack(
            children: [
              for (final bubble in _bubbles)
                _buildBubble(
                  bubble.$1,
                  bubble.$2,
                  bubble.$3,
                  (animation.value + bubble.$4) % 1,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBubble(
    double left,
    double bottom,
    double size,
    double progress,
  ) {
    final opacity = sin(pi * progress).clamp(0.0, 1.0);
    return Positioned(
      left: left + sin(progress * pi * 2) * 5,
      bottom: bottom + progress * 38,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFDDF7FF).withValues(alpha: .72),
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: const [
              BoxShadow(color: Color(0x5568B9D8), blurRadius: 5),
            ],
          ),
        ),
      ),
    );
  }
}

class _CareEffect extends StatelessWidget {
  const _CareEffect({super.key, required this.action});
  final CareAction action;

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = switch (action) {
      CareAction.feed => (Icons.restaurant, '냠냠!', const Color(0xFFF2A65A)),
      CareAction.wash => (Icons.bubble_chart, '뽀글뽀글', const Color(0xFF68B9D8)),
      CareAction.play => (
        Icons.sports_baseball,
        '신난다!',
        const Color(0xFFE86A76),
      ),
      CareAction.sleep => (Icons.bedtime, 'Zzz', const Color(0xFF7E78C8)),
    };
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
      builder: (context, value, child) => Transform.translate(
        offset: Offset(0, -18 * value),
        child: Transform.scale(scale: .45 + .55 * value, child: child),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .94),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: .3), blurRadius: 14),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 5),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
