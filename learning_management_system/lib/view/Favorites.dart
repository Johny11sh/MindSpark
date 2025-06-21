import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learning_management_system/controller/ViewFavoriteController.dart';
import 'package:learning_management_system/core/function/loadingLottie.dart';
import 'package:learning_management_system/core/function/noDataLottie.dart';

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
          return RefreshIndicator(
            onRefresh: () async {
              controller.onInit();
              controller.getCFavorite();
            },
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color(0xFFE0DEF0), // Light background
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Color(0xFFE0DEF0)),
                    ),
                    child: Row(
                      // mainAxisSize: MainAxisSize.min,
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              controller.change("teacher");
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    controller.favCh == "teacher"
                                        ? Color.fromARGB(255, 210, 209, 224)
                                        : Color.fromARGB(255, 40, 41, 61),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(25),
                                  bottomLeft: Radius.circular(25),
                                ),
                              ),

                              alignment: Alignment.center,
                              child: Text(
                                "Teacher",
                                style: TextStyle(
                                  fontSize: 18,
                                  color:
                                      controller.favCh == "teacher"
                                          ? Color.fromARGB(255, 40, 41, 61)
                                          : Color.fromARGB(255, 210, 209, 224),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              controller.change("course");
                              controller.getCFavorite();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    controller.favCh == "teacher"
                                        ? Color.fromARGB(255, 40, 41, 61)
                                        : null,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(25),
                                  bottomRight: Radius.circular(25),
                                ),
                              ),

                              alignment: Alignment.center,
                              child: Text(
                                "Course",
                                style: TextStyle(
                                  fontSize: 18,
                                  color:
                                      controller.favCh == "teacher"
                                          ? Color.fromARGB(255, 210, 209, 224)
                                          : Color.fromARGB(255, 40, 41, 61),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 10),
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        controller.loading
                            ? loadingLottie()
                            : controller.favCh == "teacher"
                            ? controller.tFav.isEmpty
                                ? noDataLottie()
                                : GridView.builder(
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
                            : controller.loading2
                            ? loadingLottie()
                            : controller.cFav.isEmpty
                            ? noDataLottie()
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
