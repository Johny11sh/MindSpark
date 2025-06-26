import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learning_management_system/controller/MyInfoController.dart';

import '../core/classes/ChangePassword.dart';
import '../core/classes/ChangeUsername.dart';
import '../core/constants/ImageAssets.dart';
import '../themes/Themes.dart';
import 'Favorites.dart';
import 'NavBar.dart';

class MyInfo extends StatelessWidget {
  const MyInfo({super.key});

  @override
  Widget build(BuildContext context) {
    MyInfoController controller = Get.put(MyInfoController());
    return Scaffold(
      // appBar: AppBar(title: Text("MyInfo"), centerTitle: true),
      body: Column(
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
                      padding: EdgeInsets.only(right: Get.width / 40),
                      child: Text(
                        " My Info ".tr,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 23,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    onPressed: () {
                      Get.to(Favorites());
                    },
                    icon: Icon(Icons.favorite, color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 20, right: 20),
              decoration: BoxDecoration(
                color:
                    themeController.initialTheme == Themes.customLightTheme
                        ? Color.fromARGB(255, 40, 41, 61)
                        : Color.fromARGB(255, 210, 209, 224),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child:Column(children: [
                Stack(
                  fit: StackFit.passthrough,
                  children: [
                    Image.asset(ImageAssets.UserAvatar, height: 180, width: 180),
                    // Positioned(
                    //   bottom: 0,
                    //   right: 0,
                    //   child: CircleAvatar(
                    //     radius: 25,
                    //     backgroundColor: Colors.greenAccent,
                    //     child: IconButton(
                    //       onPressed: () {
                    //         Get.bottomSheet(
                    //           backgroundColor: Colors.white,
                    //           SizedBox(
                    //             width: double.infinity,
                    //             height: 200,
                    //             child: SingleChildScrollView(
                    //               child: Column(
                    //                 crossAxisAlignment: CrossAxisAlignment.start,
                    //                 children: [
                    //                   Container(
                    //                     padding: const EdgeInsets.only(
                    //                       top: 20,
                    //                       left: 10,
                    //                     ),
                    //                     child: Text(
                    //                       "Choose Image from:".tr,
                    //                       style: const TextStyle(
                    //                         fontSize: 20,
                    //                         fontWeight: FontWeight.bold,
                    //                       ),
                    //                     ),
                    //                   ),
                    //                   InkWell(
                    //                     onTap: () async {
                    //                       // File? image = await uploadImage(
                    //                       //     ImageSource.gallery);
                    //                       // if (image != null) {
                    //                       //   await uploadToBackend(
                    //                       //       image); // Upload the image after selecting
                    //                       // }
                    //                       // // Get.back();
                    //                       // Get.offAll(()=>Stores());
                    //                     },
                    //                     child: Container(
                    //                       margin: const EdgeInsets.all(20),
                    //                       width: double.infinity,
                    //                       child: Row(
                    //                         children: [
                    //                           const Icon(
                    //                             Icons.photo_library_outlined,
                    //                             size: 25,
                    //                           ),
                    //                           const SizedBox(width: 20),
                    //                           Text(
                    //                             "Gallery".tr,
                    //                             style: TextStyle(fontSize: 20),
                    //                           ),
                    //                         ],
                    //                       ),
                    //                     ),
                    //                   ),
                    //                   InkWell(
                    //                     onTap: () async {
                    //                       // File? image = await uploadImage(
                    //                       //     ImageSource.camera);
                    //                       // if (image != null) {
                    //                       //   await uploadToBackend(
                    //                       //       image); // Upload the image after selecting
                    //                       // }
                    //                       // // Get.back();
                    //                       // Get.offAll(()=>Stores());
                    //                     },
                    //                     child: Container(
                    //                       margin: const EdgeInsets.all(20),
                    //                       width: double.infinity,
                    //                       child: Row(
                    //                         children: [
                    //                           const Icon(Icons.camera, size: 25),
                    //                           const SizedBox(width: 20),
                    //                           Text(
                    //                             "Camera".tr,
                    //                             style: TextStyle(fontSize: 20),
                    //                           ),
                    //                         ],
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //             ),
                    //           ),
                    //         );
                    //       },
                    //       icon: const Icon(Icons.photo_camera, size: 25),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 30),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text("User Name".tr, style: TextStyle(color: Colors.grey)),
                  // trailing: IconButton(
                  //   onPressed: () {
                  //     // Get.bottomSheet(
                  //     //     backgroundColor: Colors.white,
                  //     //     SizedBox(
                  //     //       width: double.infinity,
                  //     //       height: 200,
                  //     //       child: SingleChildScrollView(
                  //     //         child: Column(
                  //     //           crossAxisAlignment: CrossAxisAlignment.center,
                  //     //           children: [
                  //     //             Container(
                  //     //               padding:
                  //     //               const EdgeInsets.only(top: 20, left: 10),
                  //     //               child: Center(
                  //     //                 child: Text(
                  //     //                   "Change User Name".tr,
                  //     //                   style: const TextStyle(
                  //     //                       fontSize: 20,
                  //     //                       fontWeight: FontWeight.bold),
                  //     //                 ),
                  //     //               ),
                  //     //             ),
                  //     //             Container(
                  //     //                 margin:
                  //     //                 EdgeInsets.symmetric(horizontal: 20),
                  //     //                 child: Form(child: TextFormField(
                  //     //                   // controller: ChangeUserNameController,
                  //     //                   maxLength: 20,
                  //     //                   decoration: InputDecoration(prefixIcon: Icon(Icons.perm_identity),label: Text("User Name".tr)),
                  //     //                 ))),
                  //     //             SizedBox(
                  //     //               height: 20,
                  //     //             ),
                  //     //             ElevatedButton(
                  //     //                 onPressed: () {
                  //     //                   // updateUserName();
                  //     //                   // Get.offAll(()=>Stores());
                  //     //                 }, child: Text("Confirm".tr))
                  //     //           ],
                  //     //         ),
                  //     //       ),
                  //     //     ));
                  //     Get.to(() => ChangeUsername());
                  //   },
                  //   icon: Icon(Icons.edit),
                  // ),
                  trailing: InkWell(
                    onTap: () {
                      Get.to(() => ChangeUsername());
                    },
                    child: Container(
                      height: 25,
                      width: 120,
                      decoration: BoxDecoration(
                        // color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        // border: Border.all(color: Color.fromARGB(255, 40, 41, 61)),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Center(
                        child: Text(
                          "Change User Name",
                          // style: Theme.of(
                          //   context,
                          // ).textTheme.bodySmall!.copyWith(fontSize: 12),
                          style: TextStyle(
                            fontSize: 12,
                            color:
                            themeController.initialTheme ==
                                Themes.customLightTheme
                                ? Color.fromARGB(255, 210, 209, 224)
                                : Color.fromARGB(255, 40, 41, 61),
                          ),
                        ),
                      ),
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        controller.profileData["userName"] ?? "",
                        // style: TextStyle(fontSize: 18),
                        // style: Theme.of(
                        //   context,
                        // ).textTheme.bodySmall!.copyWith(fontSize: 18),
                        style: TextStyle(
                          fontSize: 18,
                          color:
                          themeController.initialTheme ==
                              Themes.customLightTheme
                              ? Color.fromARGB(255, 210, 209, 224)
                              : Color.fromARGB(255, 40, 41, 61),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Divider(height: 10, color: Colors.black26),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: Text(
                    "Phone Number".tr,
                    // style: Theme.of(context).textTheme.bodySmall,
                    style: TextStyle(color: Colors.grey),
                  ),
                  subtitle: Text(
                    "${controller.profileData["number"]}" ?? "",
                    // style: TextStyle(fontSize: 18),
                    // style: Theme.of(
                    //   context,
                    // ).textTheme.bodySmall!.copyWith(fontSize: 18),
                    style: TextStyle(
                      fontSize: 18,
                      color:
                      themeController.initialTheme ==
                          Themes.customLightTheme
                          ? Color.fromARGB(255, 210, 209, 224)
                          : Color.fromARGB(255, 40, 41, 61),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Divider(height: 10, color: Colors.black26),
                ListTile(
                  leading: const Icon(Icons.password),
                  title: Text("Password".tr, style: TextStyle(color: Colors.grey)),
                  trailing: InkWell(
                    onTap: () {
                      Get.to(() => ChangePassword());
                    },
                    child: Container(
                      height: 25,
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        // border: Border.all(color: Color.fromARGB(255, 40, 41, 61)),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Center(
                        child: Text(
                          "Change Password",
                          style: TextStyle(
                            fontSize: 12,
                            color:
                            themeController.initialTheme ==
                                Themes.customLightTheme
                                ? Color.fromARGB(255, 210, 209, 224)
                                : Color.fromARGB(255, 40, 41, 61),
                          ),
                        ),
                      ),
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        "XXXXXXXXX",
                        // style: TextStyle(fontSize: 18)
                        // style: Theme.of(
                        //   context,
                        // ).textTheme.bodySmall!.copyWith(fontSize: 18),
                        style: TextStyle(
                          fontSize: 18,
                          color:
                          themeController.initialTheme ==
                              Themes.customLightTheme
                              ? Color.fromARGB(255, 210, 209, 224)
                              : Color.fromARGB(255, 40, 41, 61),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 11),
                Divider(height: 10, color: Colors.black26),
                ListTile(
                  leading: const Icon(Icons.category_outlined),
                  title: Text(
                    "Subscriptions".tr,
                    style: TextStyle(color: Colors.grey),
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        "[ ${controller.profileData["subs"]} ]" ?? "",
                        // style: TextStyle(fontSize: 18),
                        // style: Theme.of(
                        //   context,
                        // ).textTheme.bodySmall!.copyWith(fontSize: 18),
                        style: TextStyle(
                          fontSize: 18,
                          color:
                          themeController.initialTheme ==
                              Themes.customLightTheme
                              ? Color.fromARGB(255, 210, 209, 224)
                              : Color.fromARGB(255, 40, 41, 61),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Divider(height: 10, color: Colors.black26),
                ListTile(
                  leading: const Icon(Icons.subject),
                  title: Text(
                    "Lectures Number".tr,
                    style: TextStyle(color: Colors.grey),
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        "${controller.profileData["lecturesNum"]}" ?? "",
                        // style: TextStyle(fontSize: 18),
                        style: TextStyle(
                          fontSize: 18,
                          color:
                          themeController.initialTheme ==
                              Themes.customLightTheme
                              ? Color.fromARGB(255, 210, 209, 224)
                              : Color.fromARGB(255, 40, 41, 61),
                        ),
                      ),
                    ],
                  ),
                ),
              ],) ,
            ),
          ),

        ],
      ),
    );
  }
}
