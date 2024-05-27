class Nickname {
  static String nicknameTransfer(String originalNickname) {
    switch (originalNickname) {
      case 'GAME':
        return '게임';
      case 'MUSIC':
        return '음악';
      case 'ENTERTAINMENT':
        return '엔터테인';
      case 'EDUCATION':
        return '교육';
      case 'SCIENCE':
        return '과학';
      case 'TRAVEL':
        return '여행';
      case 'COMEDY':
        return '코미디';
      case 'SPORTS':
        return '스포츠';
      case 'PET':
        return '반려동물';
      case 'NEWS':
        return '뉴스';
      case 'MOVIE':
        return '영화';
      default:
        return '기타';
    }
  }
}
