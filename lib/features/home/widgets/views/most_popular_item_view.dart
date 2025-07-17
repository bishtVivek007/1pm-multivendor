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

class MostPopularItemView extends StatelessWidget {
  final bool isFood;
  final bool isShop;
  const MostPopularItemView({super.key, required this.isFood, required this.isShop});

  @override
  Widget build(BuildContext context) {
    bool isShop = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.ecommerce;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      child: GetBuilder<ItemController>(builder: (itemController) {
        List<Item>? itemList = itemController.popularItemList;
        List<Item>? onDemandList = itemController.onDemandProducts;

        return (itemList != null) ? itemList.isNotEmpty ? Container(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            child: Column(children: [

              Padding(
                padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                child: TitleWidget(
                  title: isShop ? 'most_popular_products'.tr : 'most_popular_items'.tr,
                  image: Images.mostPopularIcon,
                  onTap: () => Get.toNamed(RouteHelper.getPopularItemRoute(true, false)),
                ),
              ),

              SizedBox(
                height: 285, width: Get.width,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                  itemCount: itemList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeDefault),
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
                          // optional: implement a route if needed
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
                                  bottom: 20,
                                  right: 20,
                                  child: FloatingActionButton(
                                    onPressed: () async {
                                      final item = onDemandList[index];
                                      final productName = item.name ?? 'this product';
                                      final imageUrl = item.imageFullUrl ?? ''; // assuming your model has this
                                      final phone = '918851249134';

                                      final message = Uri.encodeComponent(
                                          "Hi, I have a query regarding *$productName*.\n\n\nHere is the image:\n$imageUrl"
                                      );

                                      final url = Uri.parse("https://wa.me/$phone?text=$message");

                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url, mode: LaunchMode.externalApplication);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Could not open WhatsApp")),
                                        );
                                      }
                                    },
                                    backgroundColor: Colors.transparent,
                                    mini: true,
                                    child: Image.asset(
                                      'assets/image/whatsapp-icon.png',
                                      height: 96,
                                      width: 96,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

            ]),
          ) : const SizedBox() : const ItemShimmerView(isPopularItem: true);
        }
      ),
    );
  }
}
