/// 천 단위 콤마 포맷 (예: 1234567 → "1,234,567")
String formatThousands(int amount) {
  return amount.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
}
