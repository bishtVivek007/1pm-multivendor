import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/card_design/item_card.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/home/widgets/views/special_offer_view.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/common/widgets/title_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../util/styles.dart';

class MostPopularItemView extends StatelessWidget {
  final bool isFood;
  final bool isShop;
  const MostPopularItemView({super.key, required this.isFood, required this.isShop});

  @override
  Widget build(BuildContext context) {
    bool isShop = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.ecommerce;

    return GetBuilder<ItemController>(
      builder: (itemController) {
        List<Item>? itemList = itemController.popularItemList;
        List<Item>? onDemandList = itemController.onDemandProducts;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
              child: (itemList != null && itemList.isNotEmpty)
                  ? Container(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: Dimensions.paddingSizeDefault,
                        left: Dimensions.paddingSizeDefault,
                        right: Dimensions.paddingSizeDefault,
                      ),
                      child: TitleWidget(
                        title: isShop ? 'most_popular_products'.tr : 'most_popular_items'.tr,
                        image: Images.mostPopularIcon,
                        onTap: () => Get.toNamed(RouteHelper.getPopularItemRoute(true, false)),
                      ),
                    ),
                    SizedBox(
                      height: 285,
                      width: Get.width,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                        itemCount: itemList.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: Dimensions.paddingSizeDefault,
                              right: Dimensions.paddingSizeDefault,
                              top: Dimensions.paddingSizeDefault,
                            ),
                            child: ItemCard(
                              isPopularItem: isShop ? false : true,
                              isPopularItemCart: true,
                              item: itemList[index],
                              isShop: isShop,
                              isFood: isFood,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
                  : const ItemShimmerView(isPopularItem: true),
            ),

            if (onDemandList != null && onDemandList.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: Dimensions.paddingSizeDefault,
                      left: Dimensions.paddingSizeDefault,
                      right: Dimensions.paddingSizeDefault,
                    ),
                    child: TitleWidget(
                      title: 'On Demand products',
                      onTap: () {
                        // Implement navigation if needed
                      },
                    ),
                  ),
                  SizedBox(
                    height: 285,
                    width: Get.width,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                      itemCount: onDemandList.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: Dimensions.paddingSizeDefault,
                            right: Dimensions.paddingSizeDefault,
                            top: Dimensions.paddingSizeDefault,
                          ),
                          child: Stack(
                            children: [
                              ItemCard(
                                item: onDemandList[index],
                                isShop: isShop,
                                isFood: isFood,
                                isPopularItem: false,
                                isPopularItemCart: true,
                              ),
                              Positioned(
                                bottom: 10,
                                right: 10,
                                child: GestureDetector(
                                  onTap: () {
                                    Get.toNamed(RouteHelper.getConversationRoute());
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 0.1,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 5,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Ask price',
                                          style: robotoMedium.copyWith(fontSize: 10),
                                        ),
                                        const SizedBox(width: 4),
                                        Image.asset(
                                          Images.chatIcon,
                                          height: 24,
                                          width: 24,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}
