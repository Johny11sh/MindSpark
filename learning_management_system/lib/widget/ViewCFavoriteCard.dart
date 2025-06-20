import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:learning_management_system/main.dart';
import 'package:learning_management_system/view/NavBar.dart';

import '../model/CFavoriteModel.dart';



class ViewCFavoriteCard extends StatelessWidget {
  final CFavoriteModel cFavoriteModel;

  const ViewCFavoriteCard({super.key, required this.cFavoriteModel});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 60,
        padding: EdgeInsets.all(10),
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
    );
  }
}
