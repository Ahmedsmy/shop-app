import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/core/helper/my_navigator.dart';
import 'package:shop/core/utils/app_assets.dart';
import 'package:shop/core/utils/app_colors.dart';
import 'package:shop/features/shop/presentation/cubit/main/main_cubit.dart';
import 'package:shop/features/shop/presentation/cubit/main/main_state.dart';
import 'package:shop/features/shop/presentation/views/favorites_view.dart';
import 'package:shop/features/shop/presentation/views/product_details_view.dart';
import 'package:shop/features/shop/presentation/views/search_view.dart';
import 'package:shop/features/shop/presentation/views/widgets/product_card.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  // ═══ Categories data (static / local) ═══
  static const List<Map<String, String>> _categoriesData = [
    {'title': 'Beauty',  'image': 'assets/images/beauty.png'},
    {'title': 'Fashion', 'image': 'assets/images/fashion.png'},
    {'title': 'Kids',    'image': 'assets/images/kids.png'},
    {'title': 'Mens',    'image': 'assets/images/mens.png'},
    {'title': 'Womens',  'image': 'assets/images/womens.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainCubit, MainState>(
      builder: (context, state) {
        var cubit = MainCubit.get(context);
        return SafeArea(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: cubit.loadHomeData,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              children: [
                // ═══ Header (favorites icon + logo) ═══
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () =>
                          goTo(context, toPage: const FavoritesView()),
                      icon: Icon(Icons.favorite_border,
                          color: AppColors.black),
                    ),
                    Image.asset(
                      AppImages.logo,
                      height: 30,
                      errorBuilder: (context, error, stackTrace) => Text(
                        'Stylish',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 8),

                // ═══ Search bar (navigates to SearchView) ═══
                GestureDetector(
                  onTap: () => goTo(context, toPage: const SearchView()),
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.fieldFill,
                        hintText: 'Search any Product...',
                        hintStyle: TextStyle(
                            color: AppColors.darkGery, fontSize: 14),
                        prefixIcon: Icon(Icons.search,
                            color: AppColors.darkGery),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ═══ All Featured (Categories list) ═══
                Text(
                  'All Featured',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 71,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categoriesData.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final cat = _categoriesData[index];
                      final isSelected = index == 0;

                      return GestureDetector(
                        onTap: () {
                          // TODO: Filter products by selected category
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ─── Circle avatar ───
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF6C4AB6)
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  cat['image']!,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.category,
                                        color: Colors.grey, size: 20),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // ─── Title ───
                            SizedBox(
                              width: 56,
                              child: Text(
                                cat['title']!,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? const Color(0xFF6C4AB6)
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // ═══ Promotional banner ═══
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    AppImages.bannerOffer,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                const SizedBox(height: 24),

                // ═══ Recommended products ═══
                Text(
                  'Recommended',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 14),
                if (cubit.isLoadingHome)
                // Loading state
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (cubit.homeError != null)
                // Error state
                  _HomeErrorState(
                      message: cubit.homeError!,
                      onRetry: cubit.loadHomeData)
                else
                // Success — products grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cubit.products.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.54,
                    ),
                    itemBuilder: (context, index) {
                      var product = cubit.products[index];
                      return ProductCard(
                        product: product,
                        isFavorite: cubit.isFavorite(product.id),
                        onFavoriteTap: () =>
                            cubit.toggleFavorite(product.id),
                        onTap: () => goTo(context,
                            toPage:
                            ProductDetailsView(product: product)),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HomeErrorState extends StatelessWidget {
  const _HomeErrorState({required this.message, required this.onRetry});

  final String message;
  final void Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.wifi_off_rounded, size: 40, color: AppColors.darkGery),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.darkGery, fontSize: 13),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child:
            Text('Retry', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}