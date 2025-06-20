import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learning_management_system/controller/ViewFavoriteController.dart';

import '../widget/ViewCFavoriteCard.dart';
import '../widget/ViewTFavoriteCard.dart';

class Favorites extends StatefulWidget {
  const Favorites({super.key});

  @override
  State<Favorites> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorites> {
  @override
  void dispose() {
    super.dispose();
    Get.delete<ViewFavoriteController>();
  }

  @override
  Widget build(BuildContext context) {
    ViewFavoriteController controller = Get.put(ViewFavoriteController());
    return Scaffold(
      appBar: AppBar(title: Text("My Favorite"), centerTitle: true),
      body: GetBuilder<ViewFavoriteController>(
        builder: (controller) {
          return controller.tFav.isEmpty
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: () async => controller.onInit(),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              controller.change("teacher");
                            },
                            child: Text("Teacher"),
                          ),
                          SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () {
                              controller.change("course");
                            },
                            child: Text("Course"),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            controller.favCh == "teacher"
                                ? GridView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                      ),
                                  itemCount: controller.tFav.length,
                                  itemBuilder:
                                      (context, index) => ViewTFavoriteCard(
                                        tFavoriteModel: controller.tFav[index],
                                      ),
                                )
                                : GridView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                      ),
                                  itemCount: controller.cFav.length,
                                  itemBuilder:
                                      (context, index) => ViewCFavoriteCard(
                                        cFavoriteModel: controller.cFav[index],
                                      ),
                                ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
        },
      ),
    );
  }
}
