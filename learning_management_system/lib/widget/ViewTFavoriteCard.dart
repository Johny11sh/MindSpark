import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:learning_management_system/controller/FavoriteController.dart';
import 'package:learning_management_system/core/constants/ImageAssets.dart';
import 'package:learning_management_system/model/TFavoriteModel.dart';
import 'package:learning_management_system/view/NavBar.dart';
import 'package:get/get.dart';
import 'package:like_button/like_button.dart';

import '../themes/ThemeController.dart';
import '../themes/Themes.dart';

class ViewTFavoriteCard extends StatelessWidget {
  final TFavoriteModel tFavoriteModel;

  const ViewTFavoriteCard({super.key, required this.tFavoriteModel});

  @override
  Widget build(BuildContext context) {
    Get.put(FavoriteController());
    // ThemeController themeController = Get.find();
    // return Card(
    //   child: Container(
    //     height: 60,
    //     padding: EdgeInsets.all(10),
    //     child: Stack(
    //       children: [
    //         Positioned(
    //           right: 10,
    //           top: 3,
    //           child: GetBuilder<FavoriteController>(
    //             builder: (controller) {
    //               final isFav =
    //                   controller.isFavorite[tFavoriteModel.id.toString()] ??
    //                   false;
    //
    //               return LikeButton(
    //                 size: 30,
    //                 isLiked: isFav,
    //                 likeBuilder: (bool isLiked) {
    //                   return Icon(
    //                     isLiked
    //                         ? Icons.favorite
    //                         : Icons.favorite_border_outlined,
    //                     color: Colors.red,
    //                     size: 30,
    //                   );
    //                 },
    //                 onTap: (bool isLiked) async {
    //                   controller.toggleFavorite(tFavoriteModel.id.toString());
    //                   return !isLiked;
    //                 },
    //               );
    //             },
    //           ),
    //         ),
    //         Center(
    //           child: Column(
    //             children: [
    //               tFavoriteModel.image!.isEmpty
    //                   ? Image.asset(
    //                     "images/subject.png",
    //                     height: 100,
    //                     fit: BoxFit.cover,
    //                   )
    //                   : CachedNetworkImage(
    //                     imageUrl: "$mainIP/${tFavoriteModel.image}",
    //                     height: 100,
    //                     fit: BoxFit.cover,
    //                     errorWidget: (context, url, error) {
    //                       return Image.asset(
    //                         ImageAssets.teacherAvatar,
    //                         height: 100,
    //                         fit: BoxFit.cover,
    //                       );
    //                     },
    //                   ),
    //               SizedBox(height: 20),
    //               Text(
    //                 "${tFavoriteModel.name}",
    //                 style: TextStyle(color: Colors.white),
    //               ),
    //             ],
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
   return Container(
      margin: EdgeInsets.only(
        left: 1,
        right: 1,
        top: 2,
      ),
      padding: EdgeInsets.all(10),
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        // color: Colors.red,
        border: Border.all(
          color: Color.fromARGB(
            255,
            40,
            41,
            61,
          ),
        ),
        borderRadius: BorderRadius.circular(
          15,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 10,
            top: 3,
            child:
            // InkWell(
            //   onTap: () {
            //     favoriteController.toggleFavorite(
            //       teacherId.toString(),
            //     );
            //   },
            //   child: GetBuilder<FavoriteController>(
            //     builder: (controller) {
            //       final isFav =
            //           controller.isFavorite[teacherId
            //               .toString()] ??
            //           false;
            //
            //       return Icon(
            //         isFav
            //             ? Icons.favorite
            //             : Icons
            //                 .favorite_border_outlined,
            //         size: 30,
            //         color: Colors.red,
            //       );
            //     },
            //   ),
            // ),
            GetBuilder<FavoriteController>(
              builder: (controller) {
                final isFav =
                    controller
                        .isFavorite[tFavoriteModel.id
                        .toString()] ??
                        false;

                return LikeButton(
                  size: 30,
                  isLiked: isFav,
                  likeBuilder: (
                      bool isLiked,
                      ) {
                    return Icon(
                      isLiked
                          ? Icons.favorite
                          : Icons
                          .favorite_border_outlined,
                      color: Colors.red,
                      size: 30,
                    );
                  },
                  onTap: (
                      bool isLiked,
                      ) async {
                    controller.toggleFavorite(
                      tFavoriteModel.id.toString(),
                    );
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
                  ImageAssets
                      .teacherAvatar,
                  height: 100,
                  width: 100,
                )
                    : Image.asset(
                  ImageAssets.teacherAvatar,
                ),
                SizedBox(height: 10),
                Text(
                  "${tFavoriteModel.name}".tr,
                  style: TextStyle(
                    overflow:
                    TextOverflow.ellipsis,
                    fontSize: 16,
                    fontWeight:
                    FontWeight.w400,
                    fontStyle:
                    FontStyle.normal,
                    color:
                    themeController
                        .initialTheme ==
                        Themes
                            .customLightTheme
                        ? Color.fromARGB(
                      255,
                      210,
                      209,
                      224,
                    )
                        : Color.fromARGB(
                      255,
                      40,
                      41,
                      61,
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
