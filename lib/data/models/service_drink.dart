/// 무료 서비스 음료 정보 — clubs/{clubId}.serviceDrink 임베드 객체.
///
/// 서비스 음료(무료 제공) 페이지의 데이터 소스. 제공 여부/코멘트/음료 종류 보관.
/// 미제공 클럽은 serviceDrink 필드 자체가 없거나 isOffered=false.
class ServiceDrink {
  /// 서비스 음료 제공 여부 (필터/노출 기준).
  final bool isOffered;

  /// 제공 코멘트 (예: "1인 음료 무제한", "테이블당 맥주 6병", "양주 1병 + 웰컴드링크").
  final String comment;

  /// 제공 음료 종류 — "양주" | "샴페인" | "칵테일" | "맥주" | "와인".
  final List<String> drinks;

  const ServiceDrink({
    this.isOffered = false,
    this.comment = '',
    this.drinks = const [],
  });

  static const none = ServiceDrink();

  factory ServiceDrink.fromMap(Map<String, dynamic>? map) {
    if (map == null) return none;
    return ServiceDrink(
      isOffered: map['isOffered'] as bool? ?? false,
      comment: map['comment'] as String? ?? '',
      drinks: List<String>.from(map['drinks'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
    'isOffered': isOffered,
    'comment': comment,
    'drinks': drinks,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceDrink &&
          isOffered == other.isOffered &&
          comment == other.comment &&
          _listEq(drinks, other.drinks);

  @override
  int get hashCode => Object.hash(isOffered, comment, Object.hashAll(drinks));

  static bool _listEq(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
