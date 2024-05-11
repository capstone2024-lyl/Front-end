enum MbtiFile {
  enfj,
  enfp,
  entj,
  entp,
  esfj,
  esfp,
  estj,
  estp,
  infj,
  infp,
  intj,
  intp,
  isfj,
  isfp,
  istj,
  istp;

  String get mbti {
    String mbti;
    String extension = '.svg';
    switch (this) {
      case enfj:
        mbti = 'enfj';
      case enfp:
        mbti = 'enfp';
      case entj:
        mbti = 'entj';
      case entp:
        mbti = 'entp';
      case esfj:
        mbti = 'esfj';
      case esfp:
        mbti = 'esfp';
      case estj:
        mbti = 'estj';
      case estp:
        mbti = 'estp';
      case infj:
        mbti = 'infj';
      case infp:
        mbti = 'infp';
      case intj:
        mbti = 'intj';
      case intp:
        mbti = 'intp';
      case isfj:
        mbti = 'isfj';
      case isfp:
        mbti = 'isfp';
      case istj:
        mbti = 'istj';
      case istp:
        mbti = 'istp';
    }
    return mbti + extension;
  }
}
