// import 'package:cached_network_image/cached_network_image.dart';
// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '../controller/FavoriteController.dart';
import '../controller/FontController.dart';
import '../core/constants/ImageAssets.dart';
import '../model/TFavoriteModel.dart';
import '../view/NavBar.dart';
import 'package:get/get.dart';
import 'package:like_button/like_button.dart';
import '../themes/Themes.dart';

class ViewTFavoriteCard extends StatelessWidget {
  final TFavoriteModel tFavoriteModel;

  const ViewTFavoriteCard({super.key, required this.tFavoriteModel});

  @override
  Widget build(BuildContext context) {
    Get.put(FavoriteController());
    return Container(
      margin: const EdgeInsets.only(left: 1, right: 1, top: 2),
      padding: const EdgeInsets.all(10),
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        // color: Colors.red,
        border: Border.all(
          color:
              themeController.initialTheme == Themes.customLightTheme
                  ? Color.fromARGB(255, 40, 41, 61)
                  : Color.fromARGB(255, 210, 209, 224),
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 10,
            top: 3,
            child: GetBuilder<FavoriteController>(
              builder: (controller) {
                final isFav =
                    controller.isFavorite[tFavoriteModel.id.toString()] ??
                    false;

                return LikeButton(
                  size: 30,
                  isLiked: isFav,
                  likeBuilder: (bool isLiked) {
                    return Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border_outlined,
                      color: Colors.red,
                      size: 30,
                    );
                  },
                  onTap: (bool isLiked) async {
                    controller.toggleFavorite(tFavoriteModel.id.toString());
                    return !isLiked;
                  },
                );
              },
            ),
          ),
          Center(
            child: Column(
              children: [
                SizedBox(height: 15),
                tFavoriteModel.image != null
                    ? Image.asset(
                      ImageAssets.teacherAvatar,
                      height: 100,
                      width: 100,
                    )
                    : Image.asset(ImageAssets.teacherAvatar),
                SizedBox(height: 10),
                Text(
                  "${tFavoriteModel.name}".tr,
                  style: TextStyle(
                    fontFamily: FontController().currentFontFamily,
                    overflow: TextOverflow.ellipsis,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    color:
                        themeController.initialTheme == Themes.customLightTheme
                            ? Color.fromARGB(255, 40, 41, 61)
                            : Color.fromARGB(255, 210, 209, 224),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
