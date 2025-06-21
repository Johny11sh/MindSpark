import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:learning_management_system/controller/FavoriteController.dart';
import 'package:learning_management_system/model/TFavoriteModel.dart';
import 'package:learning_management_system/view/NavBar.dart';
import 'package:get/get.dart';
import 'package:like_button/like_button.dart';

class ViewTFavoriteCard extends StatelessWidget {
  final TFavoriteModel tFavoriteModel;

  const ViewTFavoriteCard({super.key, required this.tFavoriteModel});

  @override
  Widget build(BuildContext context) {
    FavoriteController favoriteController = Get.put(FavoriteController());
    return Card(
      child: Container(
        height: 60,
        padding: EdgeInsets.all(10),
        child: Stack(
          children: [
            Positioned(
              right: 10,
              top: 3,
              child: GetBuilder<FavoriteController>(
                builder: (controller) {
                  final isFav =
                      controller.isFavorite[tFavoriteModel.id
                          .toString()] ??
                          false;

                  return LikeButton(
                    size: 30,
                    isLiked: isFav,
                    likeBuilder: (bool isLiked) {
                      return Icon(
                        isLiked
                            ? Icons.favorite
                            : Icons
                            .favorite_border_outlined,
                        color: Colors.red,
                        size: 30,
                      );
                    },
                    onTap: (bool isLiked) async {
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
                  tFavoriteModel.image!.isEmpty
                      ? Image.asset(
                        "images/subject.png",
                        height: 100,
                        fit: BoxFit.cover,
                      )
                      : CachedNetworkImage(
                        imageUrl: "$mainIP/${tFavoriteModel.image}",
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                  SizedBox(height: 20),
                  Text(
                    "${tFavoriteModel.name}",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
