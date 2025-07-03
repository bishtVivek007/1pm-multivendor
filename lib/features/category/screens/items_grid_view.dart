import 'package:flutter/material.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'item_grid_tile.dart'; // Import the new item grid tile widget

class ItemsGridView extends StatelessWidget {
  final List<Item> items;

  const ItemsGridView({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.sizeOf(context).height;
    double screenWidth = MediaQuery.sizeOf(context).width;
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 items per row
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: screenHeight * 0.34,
      ),
      itemBuilder: (context, index) {
        return ItemGridTile(item: items[index], index: index,);
      },
    );
  }
}
