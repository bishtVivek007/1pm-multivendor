import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

import '../../../common/widgets/add_favourite_view.dart';
import '../../../common/widgets/cart_count_view.dart';
import '../../../common/widgets/discount_tag.dart';
import '../../item/controllers/item_controller.dart';

class ItemGridTile extends StatelessWidget {
  final Item item;
  final int index;

  const ItemGridTile({super.key, required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height;
    return GestureDetector(
      onTap: () => Get.find<ItemController>().navigateToItemPage(item, context, inStore: false, isCampaign: false), // Navigate to item details
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: Theme.of(context).cardColor,
          // boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey, // Set border color
                        width: 0.8, // Set border width
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(Dimensions.radiusDefault)), // Apply rounded corners
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
                      child: CustomImage(
                        image: item.imageFullUrl!,
                        fit: BoxFit.contain,
                        width: screenHeight * 0.175,
                        height: screenHeight * 0.175,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(left: screenWidth *0.04, top: screenHeight * 0.005), // Moves it 20 pixels forward
                  child: DiscountTag(
                    discount: item.discount,
                    discountType: item.discountType,
                    freeDelivery: false,
                    fontSize: Dimensions.fontSizeSmall,
                    // fromTop: screenWidth * 0.02,
                    inLeft: true,
                  ),
                ),
              ],
            ),
            Padding(
              padding: screenWidth > 600 ?
              EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.005) :
              const EdgeInsets.symmetric(horizontal: 12, vertical: 5)
              ,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 40, // Adjust this based on your font size
                    child: Text(
                      item.name!,
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    'Qty: ${ item.unitType ?? ''}',
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        PriceConverter.convertPrice(
                          Get.find<ItemController>().getStartingPrice(item), discount: item.discount,
                          discountType: item.discountType,
                        ),
                        textDirection: TextDirection.ltr, style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeLarge
                      ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall,),
                      item.discount != null && item.discount! > 0  ? Text(
                        PriceConverter.convertPrice(Get.find<ItemController>().getStartingPrice(item)),
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).disabledColor,
                          decoration: TextDecoration.lineThrough,
                        ), textDirection: TextDirection.ltr,
                      ) : const SizedBox(),
                    ],
                  ),
                ],
              ),
            ),
            Center(
              child: CartCountView(
                // isDashboard: true,
                item: item,
                index: index,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
