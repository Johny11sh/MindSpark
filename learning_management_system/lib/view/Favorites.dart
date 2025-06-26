import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learning_management_system/controller/ViewFavoriteController.dart';
import 'package:learning_management_system/core/function/loadingLottie.dart';
import 'package:learning_management_system/core/function/noDataLottie.dart';

import '../themes/Themes.dart';
import '../widget/ViewCFavoriteCard.dart';
import '../widget/ViewTFavoriteCard.dart';
import 'NavBar.dart';

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
      body: GetBuilder<ViewFavoriteController>(
        builder: (controller) {
          return RefreshIndicator(
            onRefresh: () async {
              controller.onInit();
              controller.getCFavorite();
            },
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(top: 30),
                  height: 100,
                  color:
                      themeController.initialTheme == Themes.customLightTheme
                          ? Color.fromARGB(255, 210, 209, 224)
                          : Color.fromARGB(255, 40, 41, 61),
                  // color: Colors.red,
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: IconButton(
                          onPressed: () {
                            Get.back();
                          },
                          icon: Icon(
                            Icons.arrow_back,
                            color: Color.fromARGB(255, 210, 209, 224),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(right: Get.width / 8),

                            child: Text(
                              "My Favorite".tr,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall!.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 23,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(left: 20,right: 20),
                    decoration: BoxDecoration(
                      color:
                          themeController.initialTheme ==
                                  Themes.customLightTheme
                              ? Color.fromARGB(255, 40, 41, 61)
                              : Color.fromARGB(255, 210, 209, 224),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 20),
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
                                              ?
                                          Color.fromARGB(255, 40, 41, 61)

                                              :
                                          Color.fromARGB(
                                            255,
                                            210,
                                            209,
                                            224,
                                          )
                                      ,
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
                                                ?
                                            Color.fromARGB(
                                              255,
                                              210,
                                              209,
                                              224,
                                            )

                                                :
                                            Color.fromARGB(
                                              255,
                                              40,
                                              41,
                                              61,
                                            )
                                        ,
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
                                              ? Color.fromARGB(
                                            255,
                                            210,
                                            209,
                                            224,
                                          )
                                              :
                                          Color.fromARGB(
                                            255,
                                            40,
                                            41,
                                            61,
                                          )
                                      ,
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
                                                ?
                                            Color.fromARGB(
                                              255,
                                              40,
                                              41,
                                              61,
                                            )

                                                :
                                            Color.fromARGB(
                                              255,
                                              210,
                                              209,
                                              224,
                                            )
                                        ,
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
                                        physics:
                                            NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              mainAxisSpacing: 10,
                                              crossAxisSpacing: 10
                                            ),
                                        itemCount: controller.tFav.length,
                                        itemBuilder:
                                            (context, index) =>
                                                ViewTFavoriteCard(
                                                  tFavoriteModel:
                                                      controller
                                                          .tFav[index],
                                                ),
                                      )
                                  : controller.loading2
                                  ? loadingLottie()
                                  : controller.cFav.isEmpty
                                  ? noDataLottie()
                                  : GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                        ),
                                    itemCount: controller.cFav.length,
                                    itemBuilder:
                                        (context, index) =>
                                            ViewCFavoriteCard(
                                              cFavoriteModel:
                                                  controller.cFav[index],
                                            ),
                                  ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
