import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/features/home/widgets/highlight_widget.dart';
import 'package:sixam_mart/features/home/widgets/views/category_view.dart';
import 'package:sixam_mart/features/home/widgets/views/top_offers_near_me.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/features/home/widgets/bad_weather_widget.dart';
import 'package:sixam_mart/features/home/widgets/views/best_reviewed_item_view.dart';
import 'package:sixam_mart/features/home/widgets/views/best_store_nearby_view.dart';
import 'package:sixam_mart/features/home/widgets/views/item_that_you_love_view.dart';
import 'package:sixam_mart/features/home/widgets/views/just_for_you_view.dart';
import 'package:sixam_mart/features/home/widgets/views/most_popular_item_view.dart';
import 'package:sixam_mart/features/home/widgets/views/new_on_mart_view.dart';
import 'package:sixam_mart/features/home/widgets/views/special_offer_view.dart';
import 'package:sixam_mart/features/home/widgets/views/visit_again_view.dart';
import 'package:sixam_mart/features/home/widgets/banner_view.dart';

import '../../../splash/controllers/splash_controller.dart';

class FoodHomeScreen extends StatelessWidget {
  const FoodHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    final configModel = Get.find<SplashController>().configModel;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      Container(
        width: MediaQuery.of(context).size.width,
        decoration: Get.find<ThemeController>().darkTheme ? null : const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Images.foodModuleBannerBg),
            fit: BoxFit.cover,
          ),
        ),
        child: const Column(
          children: [
            BadWeatherWidget(),

            BannerView(isFeatured: false),
            SizedBox(height: 12),
          ],
        ),
      ),

      configModel?.homePageSections?['category_list_enable'] == 1 ? const CategoryView() : const SizedBox(),
      isLoggedIn ? const VisitAgainView(fromFood: true) : const SizedBox(),
      configModel?.homePageSections?['special_offer_enable'] == 1 ? const SpecialOfferView(isFood: true, isShop: false) : const SizedBox(),
      const HighlightWidget(),
      configModel?.homePageSections?['top_offer_near_me_stores_enable'] == 1 ? const TopOffersNearMe() : const SizedBox(),
      configModel?.homePageSections?['best_reviewed_item_enable'] == 1 ? const BestReviewItemView() : const SizedBox(),
      configModel?.homePageSections?['popular_store_enable'] == 1 ? const BestStoreNearbyView() : const SizedBox(),
      const ItemThatYouLoveView(forShop: false),
      configModel?.homePageSections?['popular_item_enable'] == 1 ? const MostPopularItemView(isFood: true, isShop: false) : const SizedBox(),
      configModel?.homePageSections?['item_campaign_enable'] == 1 ? const JustForYouView() : const SizedBox(),
      configModel?.homePageSections?['latest_stores_enable'] == 1 ? const NewOnMartView(isNewStore: true, isPharmacy: false, isShop: false) : const SizedBox(),
    ]);
  }
}
