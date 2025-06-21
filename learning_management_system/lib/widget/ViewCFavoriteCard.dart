import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:learning_management_system/view/NavBar.dart';

import '../controller/FavoriteController.dart';
import '../model/CFavoriteModel.dart';
import 'package:get/get.dart';


class ViewCFavoriteCard extends StatelessWidget {
  final CFavoriteModel cFavoriteModel;

  const ViewCFavoriteCard({super.key, required this.cFavoriteModel});

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
                  favoriteController.toggleFavoriteC(
                    cFavoriteModel.id.toString(),
                  );
                },
                child: GetBuilder<FavoriteController>(
                  builder: (controller) {
                    final isFav =
                        controller.isFavoriteC[cFavoriteModel.id
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
                  cFavoriteModel.image!.isEmpty
                      ? Image.asset(
                        "images/subject.png",
                        height: 100,
                        fit: BoxFit.cover,
                      )
                      : CachedNetworkImage(
                        imageUrl: "$mainIP/${cFavoriteModel.image}",
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                  SizedBox(height: 20),
                  Text(
                    "${cFavoriteModel.name}",
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
