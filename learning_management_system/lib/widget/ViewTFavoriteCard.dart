// import 'package:cached_network_image/cached_network_image.dart';
// ignore_for_file: file_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controller/FavoriteController.dart';
import '../core/constants/FontGlobals.dart';
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
                          isLiked
                              ? Icons.favorite
                              : Icons.favorite_border_outlined,
                          color: Colors.red,
                          size: 30,
                        )
                        .animate(
                          onPlay: (controller) {
                            if (isLiked) {
                              controller.repeat(reverse: true);
                            }
                          },
                        )
                        .scaleXY(
                          begin: isLiked ? 1.2 : 1,
                          end: isLiked ? 0.9 : 1,
                          duration: 800.ms,
                          curve: Curves.easeInOut,
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
                    ? CachedNetworkImage(
                      imageUrl: "$mainIP/${tFavoriteModel.image}",
                      height: 60,
                      width: 60,
                    )
                    : Image.asset(ImageAssets.teacher),
                SizedBox(height: 10),
                Expanded(
                  flex: 1,
                  child: Text(
                    "${tFavoriteModel.name}".tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: globalFontFamily,
                      // overflow: TextOverflow.ellipsis,
                      fontSize:
                          globalFontSizeChange <= 17
                              ? (globalFontSizeChange / 5) + 16
                              : 16 - (globalFontSizeChange / 5),
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      color:
                          themeController.initialTheme ==
                                  Themes.customLightTheme
                              ? Color.fromARGB(255, 40, 41, 61)
                              : Color.fromARGB(255, 210, 209, 224),
                    ),
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
