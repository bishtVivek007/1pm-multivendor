import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/controllers/taxi_cart_controller.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TaxiCartWidget extends StatelessWidget {
  final Color? color;
  final double size;
  final bool fromStore;
  const TaxiCartWidget({super.key, required this.color, required this.size, this.fromStore = false});

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
