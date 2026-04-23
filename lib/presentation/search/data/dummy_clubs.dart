class DummyClub {
  final String id;
  final String name;
  final String imagePath;
  final bool isVybeRecommended;
  final double rating;
  final String area;
  final String genre;
  final String address;
  final bool isOpen;
  final String closeTime;
  final int entryFeeMin;
  final int entryFeeMax;

  const DummyClub({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.isVybeRecommended,
    required this.rating,
    required this.area,
    required this.genre,
    required this.address,
    required this.isOpen,
    required this.closeTime,
    required this.entryFeeMin,
    required this.entryFeeMax,
  });
}

const dummyClubs = [
  DummyClub(
    id: '1',
    name: '어썸레드',
    imagePath: 'assets/images/search_screen/test_club_image_1.png',
    isVybeRecommended: true,
    rating: 4.76,
    area: '홍대',
    genre: '힙합 클럽',
    address: '서울 마포구 동교로 264',
    isOpen: true,
    closeTime: '02:00',
    entryFeeMin: 0,
    entryFeeMax: 10000,
  ),
  DummyClub(
    id: '2',
    name: '홍대 클럽 레이저',
    imagePath: 'assets/images/search_screen/test_club_image_2.png',
    isVybeRecommended: false,
    rating: 4.52,
    area: '홍대',
    genre: '힙합',
    address: '서울 마포구 와우산로 17',
    isOpen: true,
    closeTime: '03:00',
    entryFeeMin: 0,
    entryFeeMax: 15000,
  ),
  DummyClub(
    id: '3',
    name: '버뮤다',
    imagePath: 'assets/images/search_screen/test_club_image_3.png',
    isVybeRecommended: false,
    rating: 4.38,
    area: '홍대',
    genre: 'R&B',
    address: '서울 마포구 홍익로 8',
    isOpen: true,
    closeTime: '04:00',
    entryFeeMin: 0,
    entryFeeMax: 10000,
  ),
  DummyClub(
    id: '4',
    name: '인클',
    imagePath: 'assets/images/search_screen/test_club_image_4.png',
    isVybeRecommended: false,
    rating: 4.21,
    area: '홍대',
    genre: '팝',
    address: '서울 마포구 어울마당로 64',
    isOpen: false,
    closeTime: '02:00',
    entryFeeMin: 10000,
    entryFeeMax: 20000,
  ),
];
