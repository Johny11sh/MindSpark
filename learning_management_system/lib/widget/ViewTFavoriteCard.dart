import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:learning_management_system/controller/FavoriteController.dart';
import 'package:learning_management_system/model/TFavoriteModel.dart';
import 'package:learning_management_system/view/NavBar.dart';
import 'package:get/get.dart';

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
              child: InkWell(
                onTap: () {
                  favoriteController.toggleFavorite(
                    tFavoriteModel.id.toString()
                  );
                },
                child: GetBuilder<FavoriteController>(
                  builder: (controller) {
                    final isFav =
                        controller.isFavorite[tFavoriteModel.id
                            .toString()] ??
                            false;

                    return Icon(
                      isFav
                          ? Icons.favorite
                          : Icons
                          .favorite_border_outlined,
                      size: 30,
                      color: Colors.red,
                    );
                  },
                ),
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
