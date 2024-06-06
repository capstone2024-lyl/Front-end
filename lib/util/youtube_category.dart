class YoutubeCategory {
  static String youtubeCategoryTransfer(String originalCategory) {
    switch (originalCategory) {
      case 'GAME':
        return '게임';
      case 'MUSIC':
        return '음악';
      case 'ENTERTAINMENT':
        return '예능';
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
      case 'IT':
        return 'IT 및 전자기기';
      default:
        return '기타';
    }
  }
}
