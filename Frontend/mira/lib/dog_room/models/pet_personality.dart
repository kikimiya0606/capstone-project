/// Four independent observations, rather than a diagnostic personality type.
class PetPersonality {
  const PetPersonality(this.answers);
  final List<int> answers;
  static const questions = [
    '간식 앞에서 “기다려”라고 하면?',
    '처음 보는 강아지를 만나면?',
    '가족이 집에 돌아오면?',
    '낯선 장난감을 발견하면?',
  ];
  static const options = [
    ['바로 먹으러 달려가요', '잠깐 기다리다 먹어요', '신호를 줄 때까지 기다려요'],
    ['먼저 다가가 인사해요', '잠깐 살피고 다가가요', '가족 뒤에서 지켜봐요'],
    ['폴짝폴짝 온몸으로 반겨요', '옆에 붙어 애교를 부려요', '편안하게 꼬리를 흔들어요'],
    ['바로 냄새 맡고 가지고 놀아요', '가족과 함께 살펴봐요', '익숙해질 때까지 기다려요'],
  ];
  static const traits = [
    ['솔직한 행동파', '귀여운 조급쟁이', '차분한 기다림쟁이'],
    ['먼저 다가가는 친구', '천천히 친해지는 친구', '조심스러운 관찰자'],
    ['신나는 환영대장', '다정한 애교쟁이', '편안한 곁지킴이'],
    ['호기심 많은 탐험가', '함께하는 모험가', '익숙함이 좋은 신중파'],
  ];
  bool get complete =>
      answers.length == 4 && answers.every((a) => a >= 0 && a < 3);
  List<String> get labels =>
      complete ? List.generate(4, (i) => traits[i][answers[i]]) : [];
  String get summary => labels.join(' · ');
  String get legacyStyle => !complete
      ? '활발함'
      : answers[2] == 1
      ? '애교쟁이'
      : answers[0] == 2
      ? '차분함'
      : answers[3] == 0
      ? '호기심'
      : '활발함';
  Map<String, dynamic> toJson() => {
    'version': 1,
    'answers': answers,
    'summary': summary,
  };
  static PetPersonality? fromJson(dynamic value) {
    if (value is! Map || value['answers'] is! List) return null;
    final raw = value['answers'] as List;
    if (raw.any((a) => a is! int)) return null;
    final result = PetPersonality(List<int>.from(raw));
    return result.complete ? result : null;
  }
}
