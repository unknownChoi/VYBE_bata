import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vybe/design_system/colors.dart';
import 'package:vybe/presentation/home/widgets/home_banner.dart';
import 'package:vybe/presentation/home/widgets/home_category_grid.dart';
import 'package:vybe/presentation/home/widgets/home_gnb.dart';
import 'package:vybe/presentation/home/widgets/home_location_bar.dart';
import 'package:vybe/presentation/home/widgets/home_nearby_clubs.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onSearchTap;

  const HomeScreen({super.key, this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VybeColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: HomeGnb(onSearchTap: onSearchTap)),
            const SliverToBoxAdapter(child: HomeLocationBar()),
            const SliverToBoxAdapter(child: HomeBanner()),
            const SliverToBoxAdapter(child: HomeCategoryGrid()),
            SliverToBoxAdapter(
              child: Container(height: 8.h, color: VybeColors.gray900),
            ),
            const SliverToBoxAdapter(child: HomeNearbyClubs()),
            SliverToBoxAdapter(child: SizedBox(height: 32.h)),
          ],
        ),
      ),
    );
  }
}
