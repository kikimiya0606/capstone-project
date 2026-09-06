import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _green = Color(0xFF315E50);

class MemoryPost {
  MemoryPost({
    required this.id,
    required this.photo,
    required this.body,
    required this.date,
    this.asset = false,
    this.liked = false,
    List<String>? comments,
  }) : comments = comments ?? [];
  final String id, photo;
  final DateTime date;
  final bool asset;
  String body;
  bool liked;
  final List<String> comments;
  Uint8List? _decoded;
  Uint8List get bytes => _decoded ??= base64Decode(photo);

  Map<String, dynamic> toJson() => {
    'id': id,
    'photo': photo,
    'body': body,
    'date': date.toIso8601String(),
    'asset': asset,
    'liked': liked,
    'comments': comments,
  };
  factory MemoryPost.fromJson(Map<String, dynamic> json) => MemoryPost(
    id: json['id'] as String,
    photo: json['photo'] as String,
    body: json['body'] as String,
    date: DateTime.parse(json['date'] as String),
    asset: json['asset'] as bool,
    liked: json['liked'] as bool,
    comments: List<String>.from(json['comments'] as List),
  );
}

class MemoryStore {
  static const storageKey = 'mira_memories_v1';
  final SharedPreferencesAsync preferences = SharedPreferencesAsync();

  Future<List<MemoryPost>> load() async {
    final saved = await preferences.getString(storageKey);
    if (saved != null) {
      return (jsonDecode(saved) as List)
          .map((e) => MemoryPost.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    const pictures = [
      'baby_idle',
      'baby_walk_01',
      'baby_eat',
      'baby_sleep',
      'baby_tail_01',
      'child_idle',
      'teen_idle',
      'adult_idle',
    ];
    const captions = [
      '우리 집에 온 작은 친구',
      '한 발 한 발, 첫 산책',
      '밥 먹는 모습도 사랑스러워',
      '잘 자, 내일 또 놀자',
      '반가워서 꼬리가 살랑',
      '조금씩 자라는 중',
      '함께여서 더 좋은 하루',
      '오래오래 함께하자',
    ];
    return List.generate(
      8,
      (i) => MemoryPost(
        id: 'sample-$i',
        photo: 'assets/dog/${pictures[i]}.png',
        body: captions[i],
        date: DateTime(2026, 9, 6).subtract(Duration(days: i)),
        asset: true,
      ),
    );
  }

  Future<void> save(List<MemoryPost> posts) async {
    final encoded = jsonEncode(posts.map((p) => p.toJson()).toList());
    if (encoded.length > 15 * 1024 * 1024) {
      throw StateError('사진 저장 공간이 찼어요. 이전 사진을 지운 뒤 다시 시도해 주세요.');
    }
    await preferences.setString(storageKey, encoded);
  }
}

class MemoryPhoto extends StatelessWidget {
  const MemoryPhoto(this.post, {this.fit = BoxFit.cover, super.key});
  final MemoryPost post;
  final BoxFit fit;
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xFFEDEBE3),
    child: post.asset
        ? Image.asset(post.photo, fit: BoxFit.contain)
        : Image.memory(
            post.bytes,
            fit: fit,
            gaplessPlayback: true,
            errorBuilder: (_, error, stack) =>
                const Center(child: Icon(CupertinoIcons.photo)),
          ),
  );
}

class MemoryPage extends StatefulWidget {
  const MemoryPage({super.key});
  @override
  State<MemoryPage> createState() => _MemoryPageState();
}

class _MemoryPageState extends State<MemoryPage> {
  final store = MemoryStore();
  List<MemoryPost> posts = [];
  bool loading = true;
  bool saving = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await store.load();
      if (mounted) {
        setState(() {
          posts = result;
          loading = false;
          error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          loading = false;
          error = '사진첩을 불러오지 못했어요. 다시 시도해 주세요.';
        });
      }
    }
  }

  Future<void> _compose() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => _ComposePage(
          onPublish: (result) async {
            final next = [...result, ...posts];
            await store.save(next);
            if (mounted) setState(() => posts = next);
          },
        ),
      ),
    );
  }

  Future<void> _open(MemoryPost post) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => _MemoryDetail(
          post: post,
          onSave: () => store.save(posts),
          onDelete: () async {
            final next = posts.where((p) => p.id != post.id).toList();
            await store.save(next);
            if (mounted) setState(() => posts = next);
          },
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => CustomScrollView(
    slivers: [
      SliverAppBar(
        title: const Text('우리의 사진첩'),
        actions: [
          IconButton(
            tooltip: '사진과 글 올리기',
            onPressed: loading || saving || error != null ? null : _compose,
            icon: const Icon(CupertinoIcons.plus_circle),
          ),
        ],
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '평범한 하루도,\n우리에게는 소중한 장면.',
                style: TextStyle(
                  fontSize: 27,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.8,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '사진을 누르고 이야기와 마음을 남겨 보세요.',
                style: TextStyle(color: Color(0xFF68766D), height: 1.5),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.square_stack_3d_up,
                    size: 18,
                    color: _green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${posts.length}장의 순간',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  const Text(
                    '이 기기에 저장',
                    style: TextStyle(fontSize: 12, color: Color(0xFF68766D)),
                  ),
                ],
              ),
              if (saving)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: LinearProgressIndicator(),
                ),
              if (posts.any((p) => p.asset))
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    '보리의 사진은 예시예요. + 버튼으로 우리 사진을 담아 보세요.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: Color(0xFF68766D),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      if (loading)
        const SliverToBoxAdapter(
          child: Center(child: CircularProgressIndicator()),
        )
      else if (error != null)
        SliverToBoxAdapter(
          child: Column(
            children: [
              Text(error!),
              TextButton(onPressed: _load, child: const Text('다시 불러오기')),
            ],
          ),
        )
      else if (posts.isEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Icon(
                  CupertinoIcons.photo_on_rectangle,
                  size: 48,
                  color: _green,
                ),
                const SizedBox(height: 16),
                const Text('첫 번째 추억을 남겨 볼까요?'),
                const SizedBox(height: 16),
                FilledButton(onPressed: _compose, child: const Text('사진 올리기')),
              ],
            ),
          ),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid.builder(
            itemCount: posts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemBuilder: (context, i) => Semantics(
              button: true,
              label:
                  '${posts[i].body}, 좋아요 ${posts[i].liked ? 1 : 0}, 댓글 ${posts[i].comments.length}',
              child: Material(
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: saving ? null : () => _open(posts[i]),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      MemoryPhoto(posts[i]),
                      if (posts[i].liked || posts[i].comments.isNotEmpty)
                        Positioned(
                          right: 4,
                          bottom: 4,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 3,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (posts[i].liked)
                                    const Icon(
                                      CupertinoIcons.heart_fill,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  if (posts[i].comments.isNotEmpty) ...[
                                    const SizedBox(width: 3),
                                    const Icon(
                                      CupertinoIcons.chat_bubble_fill,
                                      color: Colors.white,
                                      size: 11,
                                    ),
                                    Text(
                                      ' ${posts[i].comments.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      const SliverToBoxAdapter(child: SizedBox(height: 40)),
    ],
  );
}

class _ComposePage extends StatefulWidget {
  const _ComposePage({required this.onPublish});
  final Future<void> Function(List<MemoryPost>) onPublish;
  @override
  State<_ComposePage> createState() => _ComposePageState();
}

class _ComposePageState extends State<_ComposePage> {
  final caption = TextEditingController();
  final photos = <Uint8List>[];
  bool picking = false;
  bool publishing = false;
  String? error;
  @override
  void dispose() {
    caption.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    setState(() {
      picking = true;
      error = null;
    });
    try {
      final files = await ImagePicker().pickMultiImage(
        maxWidth: 1440,
        maxHeight: 1440,
        imageQuality: 80,
        limit: 8,
      );
      final selected = <Uint8List>[];
      for (final file in files.take(8 - photos.length)) {
        final bytes = await file.readAsBytes();
        if (bytes.length > 2 * 1024 * 1024) {
          throw StateError('사진 한 장은 2MB 이하로 선택해 주세요.');
        }
        final decoded = await decodeImageFromList(bytes);
        decoded.dispose();
        selected.add(bytes);
      }
      if (mounted) setState(() => photos.addAll(selected));
    } catch (_) {
      if (mounted) {
        setState(
          () => error = '사진을 열지 못했어요. 사진 접근 권한과 파일 크기(장당 2MB 이하)를 확인해 주세요.',
        );
      }
    } finally {
      if (mounted) setState(() => picking = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !publishing,
    child: Scaffold(
      appBar: AppBar(title: const Text('오늘의 순간 남기기')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            '어떤 하루였나요?',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          const Text(
            '사진과 짧은 글을 함께 담아 주세요.\n현재 사진첩은 이 기기에만 저장돼요.',
            style: TextStyle(height: 1.6, color: Color(0xFF68766D)),
          ),
          const SizedBox(height: 24),
          if (photos.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: photos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemBuilder: (_, i) => Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(photos[i], fit: BoxFit.cover),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton.filled(
                      tooltip: '선택한 사진 삭제',
                      onPressed: publishing || picking
                          ? null
                          : () => setState(() => photos.removeAt(i)),
                      icon: const Icon(CupertinoIcons.xmark, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: publishing || picking || photos.length == 8
                ? null
                : _pick,
            icon: const Icon(CupertinoIcons.photo_on_rectangle),
            label: Text(picking ? '사진을 불러오는 중…' : '사진 선택 (${photos.length}/8)'),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 24),
          TextField(
            enabled: !publishing,
            controller: caption,
            minLines: 4,
            maxLines: 8,
            maxLength: 500,
            decoration: const InputDecoration(
              labelText: '사진에 담긴 이야기',
              hintText: '오늘 함께한 순간을 적어 주세요.',
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: photos.isEmpty || picking || publishing
                ? null
                : () async {
                    setState(() {
                      publishing = true;
                      error = null;
                    });
                    final now = DateTime.now();
                    final result = List.generate(
                      photos.length,
                      (i) => MemoryPost(
                        id: '${now.microsecondsSinceEpoch}-$i',
                        photo: base64Encode(photos[i]),
                        body: caption.text.trim(),
                        date: now,
                      ),
                    );
                    final navigator = Navigator.of(context);
                    try {
                      await widget.onPublish(result);
                      if (mounted) {
                        setState(() => publishing = false);
                        navigator.pop();
                      }
                    } catch (_) {
                      if (mounted) {
                        setState(() {
                          publishing = false;
                          error =
                              '저장하지 못했어요. 사진은 그대로 있으니 저장 공간을 확인한 뒤 다시 시도해 주세요.';
                        });
                      }
                    }
                  },
            child: Text(publishing ? '저장하는 중…' : '사진첩에 저장'),
          ),
        ],
      ),
    ),
  );
}

class _MemoryDetail extends StatefulWidget {
  const _MemoryDetail({
    required this.post,
    required this.onSave,
    required this.onDelete,
  });
  final MemoryPost post;
  final Future<void> Function() onSave, onDelete;
  @override
  State<_MemoryDetail> createState() => _MemoryDetailState();
}

class _MemoryDetailState extends State<_MemoryDetail> {
  final comment = TextEditingController();
  bool busy = false;
  @override
  void dispose() {
    comment.dispose();
    super.dispose();
  }

  Future<void> _change(VoidCallback change, VoidCallback rollback) async {
    if (busy) return;
    setState(() {
      busy = true;
      change();
    });
    try {
      await widget.onSave();
    } catch (_) {
      rollback();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('저장하지 못했어요. 다시 시도해 주세요.')));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _edit() async {
    final editor = TextEditingController(text: widget.post.body);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이야기 수정'),
        content: TextField(
          controller: editor,
          maxLength: 500,
          minLines: 2,
          maxLines: 5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, editor.text.trim()),
            child: const Text('저장'),
          ),
        ],
      ),
    );
    // The route's exit animation may still render its text field.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    editor.dispose();
    if (result != null && mounted) {
      final old = widget.post.body;
      await _change(
        () => widget.post.body = result,
        () => widget.post.body = old,
      );
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이 사진을 삭제할까요?'),
        content: const Text('사진과 글, 댓글이 함께 삭제돼요.'),
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
    setState(() => busy = true);
    try {
      await widget.onDelete();
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() => busy = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('삭제하지 못했어요. 다시 시도해 주세요.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return Scaffold(
      appBar: AppBar(
        title: const Text('우리의 순간'),
        actions: [
          IconButton(
            tooltip: '글 수정',
            onPressed: busy ? null : _edit,
            icon: const Icon(CupertinoIcons.pencil),
          ),
          IconButton(
            tooltip: '사진 삭제',
            onPressed: busy ? null : _delete,
            icon: const Icon(CupertinoIcons.trash),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFE4ECE5),
              child: Icon(CupertinoIcons.person, color: _green),
            ),
            title: Text(
              post.asset ? '보리의 성장 앨범 · 예시' : '나의 이야기',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${post.date.year}년 ${post.date.month}월 ${post.date.day}일',
            ),
          ),
          AspectRatio(
            aspectRatio: 1,
            child: GestureDetector(
              onTap: () => showDialog<void>(
                context: context,
                builder: (context) => Dialog.fullscreen(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: InteractiveViewer(
                          minScale: 1,
                          maxScale: 4,
                          child: MemoryPhoto(post, fit: BoxFit.contain),
                        ),
                      ),
                      SafeArea(
                        child: IconButton.filled(
                          tooltip: '사진 닫기',
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(CupertinoIcons.xmark),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              child: MemoryPhoto(post, fit: BoxFit.contain),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.body.isNotEmpty)
                  Text(
                    post.body,
                    style: const TextStyle(fontSize: 16, height: 1.65),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: busy
                          ? null
                          : () {
                              final old = post.liked;
                              _change(
                                () => post.liked = !old,
                                () => post.liked = old,
                              );
                            },
                      icon: Icon(
                        post.liked
                            ? CupertinoIcons.heart_fill
                            : CupertinoIcons.heart,
                        color: post.liked ? const Color(0xFFC36555) : _green,
                      ),
                      label: Text('좋아요 ${post.liked ? 1 : 0}'),
                    ),
                    const SizedBox(width: 12),
                    const Icon(CupertinoIcons.chat_bubble, size: 19),
                    const SizedBox(width: 6),
                    Text('댓글 ${post.comments.length}'),
                  ],
                ),
                const Divider(height: 32),
                const Text(
                  '따뜻한 한마디',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                if (post.comments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      '첫 번째 댓글로 마음을 전해 보세요.',
                      style: TextStyle(color: Color(0xFF68766D)),
                    ),
                  ),
                for (var i = 0; i < post.comments.length; i++)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      radius: 17,
                      child: Icon(CupertinoIcons.person, size: 17),
                    ),
                    title: const Text(
                      '나',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      post.comments[i],
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                    trailing: IconButton(
                      tooltip: '댓글 삭제',
                      onPressed: busy
                          ? null
                          : () {
                              final removed = post.comments[i];
                              _change(
                                () => post.comments.removeAt(i),
                                () => post.comments.insert(i, removed),
                              );
                            },
                      icon: const Icon(CupertinoIcons.xmark, size: 16),
                    ),
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: comment,
                  maxLength: 200,
                  minLines: 1,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: '댓글을 남겨 주세요',
                    labelText: '댓글',
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: busy
                        ? null
                        : () async {
                            final value = comment.text.trim();
                            if (value.isEmpty) return;
                            var succeeded = true;
                            await _change(() => post.comments.add(value), () {
                              post.comments.removeLast();
                              succeeded = false;
                            });
                            if (mounted && succeeded) comment.clear();
                          },
                    icon: const Icon(CupertinoIcons.arrow_up, size: 18),
                    label: const Text('댓글 등록'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
