import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';

class DetailMenuTab extends StatefulWidget {
  const DetailMenuTab({super.key});

  @override
  State<DetailMenuTab> createState() => _DetailMenuTabState();
}

class _DetailMenuTabState extends State<DetailMenuTab> {
  int _selectedCategoryIndex = 0;

  static const _categories = [
    '대표메뉴',
    'SET',
    'HARD',
    'CHAMPAGNE',
    'BEER',
    'COCKTAIL',
  ];

  static const _menuGroups = [
    _MenuGroup(
      title: '대표 메뉴',
      items: [
        _MenuItem(badge: '대표', name: 'LEMON DROP', desc: '레몬 보드카 베이스 · 새콤달콤', price: '15,000원', image: 'assets/club_detail/images/menu_image.png'),
        _MenuItem(badge: '대표', name: 'PURPLE HAZE', desc: '블루베리 진 토닉', price: '16,000원', image: 'assets/club_detail/images/menu_image.png'),
      ],
    ),
    _MenuGroup(
      title: 'SET',
      items: [
        _MenuItem(badge: '대표', name: 'HARD SET A', desc: 'CHOICE A · OPERA BRUIT', price: '220,000원'),
        _MenuItem(name: 'HARD SET A·B', desc: 'CHOICE A·B · OPERA BRUIT', price: '420,000원'),
        _MenuItem(name: 'HARD SET B', desc: 'CHOICE B · HENKELL', price: '320,000원'),
      ],
    ),
    _MenuGroup(
      title: 'HARD',
      items: [
        _MenuItem(name: 'JACK DANIEL\'S', desc: '버번 위스키 · 750ml', price: '180,000원', image: 'assets/club_detail/images/menu_image.png'),
        _MenuItem(name: 'CHIVAS REGAL 12', desc: '스카치 위스키 · 750ml', price: '220,000원'),
        _MenuItem(name: 'GREY GOOSE', desc: '프렌치 보드카 · 750ml', price: '260,000원'),
      ],
    ),
    _MenuGroup(
      title: 'CHAMPAGNE',
      items: [
        _MenuItem(name: 'MOËT & CHANDON', desc: '브뤼 · 750ml', price: '280,000원'),
        _MenuItem(name: 'VEUVE CLICQUOT', desc: '옐로우 라벨 · 750ml', price: '320,000원'),
        _MenuItem(name: 'DOM PÉRIGNON', desc: '빈티지 · 750ml', price: '780,000원'),
      ],
    ),
    _MenuGroup(
      title: 'BEER',
      items: [
        _MenuItem(name: 'HEINEKEN', desc: '하이네켄 · 330ml', price: '12,000원'),
        _MenuItem(name: 'CORONA', desc: '코로나 엑스트라 · 355ml', price: '14,000원'),
        _MenuItem(name: 'STELLA', desc: '스텔라 아르투아 · 330ml', price: '13,000원'),
      ],
    ),
    _MenuGroup(
      title: 'COCKTAIL',
      items: [
        _MenuItem(name: 'NEGRONI', desc: '진 · 캄파리 · 베르무트', price: '14,000원', image: 'assets/club_detail/images/menu_image.png'),
        _MenuItem(name: 'OLD FASHIONED', desc: '버번 · 비터스 · 슈가', price: '15,000원'),
        _MenuItem(name: 'ESPRESSO MARTINI', desc: '보드카 · 에스프레소 · 칼루아', price: '16,000원'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        _buildImageSection(),
        // divider
        Container(
          height: 2,
          color: VybeColors.gray900,
        ),
        _buildCategoryChips(),
        _buildMenuSections(),
        SizedBox(height: 32.h),
      ],
    );
  }

  Widget _buildImageSection() {
    return Padding(
      padding: EdgeInsets.only(top: 24.h, bottom: 28.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              '메뉴 이미지',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                'assets/club_detail/images/menu_board_1.png',
                'assets/club_detail/images/menu_board_2.png',
                'assets/club_detail/images/menu_board_3.png',
                'assets/club_detail/images/menu_image.png',
              ].map((img) {
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.asset(
                      img,
                      width: 121.r,
                      height: 121.r,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: VybeColors.gray900)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_categories.length, (i) {
            final selected = i == _selectedCategoryIndex;
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: GestureDetector(
                onTap: () =>
                    setState(() => _selectedCategoryIndex = i),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? VybeColors.mainPurple700
                        : VybeColors.gray800,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    _categories[i],
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 13.sp,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: selected
                          ? Colors.white
                          : VybeColors.gray400,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMenuSections() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._menuGroups.map((group) {
            return Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.title,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  ...group.items.map((item) => _MenuItemWidget(item: item)),
                  Container(height: 1, color: VybeColors.gray800),
                ],
              ),
            );
          }),
          SizedBox(height: 12.h),
          Text(
            '메뉴 항목과 가격은 각 매장 사정에 따라 기재된 내용과 다를 수 있습니다.',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12.sp,
              color: VybeColors.gray500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItemWidget extends StatelessWidget {
  final _MenuItem item;
  const _MenuItemWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: VybeColors.gray800)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (item.badge != null) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: VybeColors.mainPurple500,
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Text(
                          item.badge!,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: VybeColors.gray200,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                    ],
                    Text(
                      item.name,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14.sp,
                        color: VybeColors.gray200,
                      ),
                    ),
                  ],
                ),
                if (item.desc != null) ...[
                  SizedBox(height: 6.h),
                  Text(
                    item.desc!,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12.sp,
                      color: VybeColors.gray500,
                    ),
                  ),
                ],
                SizedBox(height: 10.h),
                Text(
                  item.price,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (item.image != null) ...[
            SizedBox(width: 16.w),
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: Image.asset(
                item.image!,
                width: 100.r,
                height: 100.r,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MenuGroup {
  final String title;
  final List<_MenuItem> items;
  const _MenuGroup({required this.title, required this.items});
}

class _MenuItem {
  final String? badge;
  final String name;
  final String? desc;
  final String price;
  final String? image;
  const _MenuItem({this.badge, required this.name, this.desc, required this.price, this.image});
}
