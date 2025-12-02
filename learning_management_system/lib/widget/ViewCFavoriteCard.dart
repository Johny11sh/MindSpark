// import 'package:cached_network_image/cached_network_image.dart';
// ignore_for_file: file_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants/FontGlobals.dart';
import '../view/NavBar.dart';
import 'package:like_button/like_button.dart';
import '../controller/FavoriteController.dart';
import '../core/constants/ImageAssets.dart';
import '../model/CFavoriteModel.dart';
import 'package:get/get.dart';
import '../themes/Themes.dart';

class ViewCFavoriteCard extends StatelessWidget {
  final CFavoriteModel cFavoriteModel;

  const ViewCFavoriteCard({super.key, required this.cFavoriteModel});

  @override
  Widget build(BuildContext context) {
    Get.put(FavoriteController());
    return Container(
      margin: const EdgeInsets.only(left: 1, right: 10),
      padding: const EdgeInsets.all(10),
      height: 130,
      width: 120,
      decoration: BoxDecoration(
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
            top: 5,
            left: 5,
            right: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                cFavoriteModel.rating != null
                    ? Container(
                      height: 23,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFFCCF2E0),
                        border: Border.all(
                          color:
                              themeController.initialTheme ==
                                      Themes.customLightTheme
                                  ? Color.fromARGB(255, 210, 209, 224)
                                  : Color.fromARGB(255, 40, 41, 61),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Color(0XFFE6D827), size: 20),
                          SizedBox(width: 2),
                          Text(
                            // "${subscribedCourses[i]["rating"]}",
                            double.parse(
                              cFavoriteModel.rating.toString(),
                            ).toStringAsFixed(1),
                            style: TextStyle(
                              fontFamily: globalFontFamily,
                              overflow: TextOverflow.clip,
                              fontSize:
                                  globalFontSizeChange <= 17
                                      ? (globalFontSizeChange / 5) + 16
                                      : 16 - (globalFontSizeChange / 5),
                              color: Color.fromARGB(255, 40, 41, 61),
                            ),
                          ),
                        ],
                      ),
                    )
                    : SizedBox.shrink(),
                SizedBox.shrink(),

                GetBuilder<FavoriteController>(
                  builder: (controller) {
                    final isFav =
                        controller.isFavoriteC[cFavoriteModel.id.toString()] ??
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
                        controller.toggleFavoriteC(
                          cFavoriteModel.id.toString(),
                        );
                        return !isLiked;
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          Center(
            child: Column(
              children: [
                const SizedBox(height: 34),
                cFavoriteModel.image != null
                    ? CachedNetworkImage(
                      imageUrl: "$mainIP/${cFavoriteModel.image}",
                      height: 60,
                      width: 60,
                    )
                    : Image.asset(ImageAssets.course),

                Expanded(
                  flex: 1,
                  child: Text(
                    "${cFavoriteModel.name}".tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: globalFontFamily,
                      fontSize:
                          globalFontSizeChange <= 17
                              ? (globalFontSizeChange / 5) + 16
                              : 16 - (globalFontSizeChange / 5),
                      fontWeight: FontWeight.w400,
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
