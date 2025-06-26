import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:learning_management_system/view/NavBar.dart';
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
    FavoriteController favoriteController = Get.put(FavoriteController());

    // return Card(
    //   child: Container(
    //     height: 60,
    //     padding: EdgeInsets.all(10),
    //     child: Stack(
    //       children: [
    //         Positioned(
    //           right: 10,
    //           top: 3,
    //           child:  GetBuilder<FavoriteController>(
    //             builder: (controller) {
    //               final isFav =
    //                   controller.isFavoriteC[cFavoriteModel.id
    //                       .toString()] ??
    //                       false;
    //
    //               return LikeButton(
    //                 size: 30,
    //                 isLiked: isFav,
    //                 likeBuilder: (bool isLiked) {
    //                   return Icon(
    //                     isLiked
    //                         ? Icons.favorite
    //                         : Icons
    //                         .favorite_border_outlined,
    //                     color: Colors.red,
    //                     size: 30,
    //                   );
    //                 },
    //                 onTap: (bool isLiked) async {
    //                   controller.toggleFavoriteC(
    //                     cFavoriteModel.id.toString(),
    //                   );
    //                   return !isLiked;
    //                 },
    //               );
    //             },
    //           ),
    //         ),
    //         Center(
    //           child: Column(
    //             children: [
    //               cFavoriteModel.image!.isEmpty
    //                   ? Image.asset(
    //                     "images/subject.png",
    //                     height: 100,
    //                     fit: BoxFit.cover,
    //                   )
    //                   : CachedNetworkImage(
    //                     imageUrl: "$mainIP/${cFavoriteModel.image}",
    //                     height: 100,
    //                     fit: BoxFit.cover,
    //                   ),
    //               SizedBox(height: 20),
    //               Text(
    //                 "${cFavoriteModel.name}",
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
        right: 10,
      ),
      // padding: EdgeInsets.only(left: 10,right: 10),
      padding: EdgeInsets.all(10),
      height: 130,
      width: 120,
      decoration: BoxDecoration(
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
            top: 5,
            left: 5,
            right: 5,
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,
              children: [
               cFavoriteModel.rating != null?

                Container(
                  height: 23,
                  padding:
                  EdgeInsets.symmetric(
                    horizontal: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFCCF2E0),
                    border: Border.all(
                      color: Color.fromARGB(
                        255,
                        40,
                        41,
                        61,
                      ),
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      10,
                    ),
                  ),
                  child: Row(
                    mainAxisSize:
                    MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: Color(
                          0XFFE6D827,
                        ),
                        size: 20,
                      ),
                      SizedBox(width: 2),
                      Text(
                        // "${subscribedCourses[i]["rating"]}",
                        double.parse(cFavoriteModel.rating.toString()).toStringAsFixed(1),
                        style: TextStyle(
                          overflow:
                          TextOverflow
                              .clip,
                          fontSize: 16,
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
                ):                                                    SizedBox.shrink(),
                SizedBox.shrink(),

                GetBuilder<
                    FavoriteController
                >(
                  builder: (controller) {
                    final isFav =
                        controller
                            .isFavoriteC[cFavoriteModel.id
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
                        controller
                            .toggleFavoriteC(
                         cFavoriteModel.id
                              .toString(),
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
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                const SizedBox(height: 34),
                cFavoriteModel.image != null
                    ? Image.asset(
                  ImageAssets.book,
                  height: 90,
                  width: 90,
                )
                    : Image.asset(
                  ImageAssets.book,
                ),

                Expanded(
                  flex: 1,
                  child: Text(
                    "${cFavoriteModel.name}"
                        .tr,
                    textAlign:
                    TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.w500,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
