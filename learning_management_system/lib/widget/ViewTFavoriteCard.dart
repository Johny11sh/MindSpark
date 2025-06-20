import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:learning_management_system/model/TFavoriteModel.dart';
import 'package:learning_management_system/view/NavBar.dart';

class ViewTFavoriteCard extends StatelessWidget {
  final TFavoriteModel tFavoriteModel;

  const ViewTFavoriteCard({super.key, required this.tFavoriteModel});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 60,
        padding: EdgeInsets.all(10),
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
    );
  }
}
