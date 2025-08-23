// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/AvatarModel.dart';
import '../../services/SharedPrefs.dart';
import '../../themes/ThemeController.dart';
import '../../themes/Themes.dart';
import '../../controller/FontController.dart';
import '../constants/ImageAssets.dart';

class AvatarPicker extends StatefulWidget {
  const AvatarPicker({super.key});

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  String selectedAvatar = ImageAssets.AppIcon;
  int selectedAvatarId = 0;

  @override
  void initState() {
    super.initState();
    _loadCurrentAvatar();
  }

  void _loadCurrentAvatar() {
    try {
      final savedAvatar = SharedPrefs.instance.prefs.getString("CurrentAvatar");
      final savedAvatarId = SharedPrefs.instance.prefs.getInt(
        "CurrentAvatarId",
      );

      if (savedAvatar != null) {
        setState(() {
          selectedAvatar = savedAvatar;
          selectedAvatarId = savedAvatarId ?? 0;
        });
      } else {
        setState(() {
          selectedAvatar = ImageAssets.AppLogo;
          selectedAvatarId = 1;
        });
      }
    } catch (e) {
      setState(() {
        selectedAvatar = ImageAssets.AppLogo;
        selectedAvatarId = 1;
      });
    }
  }

  void _selectAvatar(String avatarPath, int avatarId) {
    setState(() {
      selectedAvatar = avatarPath;
      selectedAvatarId = avatarId;
    });

    try {
      SharedPrefs.instance.prefs.setString("CurrentAvatar", avatarPath);
      SharedPrefs.instance.prefs.setInt("CurrentAvatarId", avatarId);
    } catch (e) {
      // Error saving avatar
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    final List<AvatarModel> avatarList = [
      AvatarModel(id: 0, avatar: ImageAssets.Avatar1),
      AvatarModel(id: 1, avatar: ImageAssets.Avatar2),
      AvatarModel(id: 2, avatar: ImageAssets.Avatar3),
      AvatarModel(id: 3, avatar: ImageAssets.Avatar4),
      AvatarModel(id: 4, avatar: ImageAssets.Avatar5),
      AvatarModel(id: 5, avatar: ImageAssets.Avatar6),
      AvatarModel(id: 6, avatar: ImageAssets.Avatar7),
      AvatarModel(id: 7, avatar: ImageAssets.Avatar8),
      AvatarModel(id: 8, avatar: ImageAssets.Avatar9),
    ];

    final bool isDark = themeController.initialTheme == Themes.customDarkTheme;
    final Color bgColor =
        isDark
            ? const Color.fromARGB(255, 40, 41, 61)
            : const Color.fromARGB(255, 210, 209, 224);
    final Color fgColor =
        isDark
            ? const Color.fromARGB(255, 210, 209, 224)
            : const Color.fromARGB(255, 40, 41, 61);

    return Scaffold(
      backgroundColor: fgColor,
      appBar: AppBar(
        backgroundColor: fgColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: bgColor),
        ),
        title: Text(
          "Choose Avatar".tr,
          style: TextStyle(
            fontFamily: FontController().currentFontFamily,
            color: bgColor,
            fontWeight: FontWeight.bold,
            fontSize: 23,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(60),
            topRight: Radius.circular(60),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 30),

            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: fgColor, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    selectedAvatar,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.person,
                          size: 100,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Selection indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: fgColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Tap an avatar below to select".tr,
                style: TextStyle(
                  fontFamily: FontController().currentFontFamily,
                  color: fgColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1,
                  ),
                  itemCount: avatarList.length,
                  itemBuilder: (context, index) {
                    final avatar = avatarList[index];
                    final isSelected = selectedAvatarId == avatar.id;

                    return GestureDetector(
                      onTap:
                          () => setState(() {
                            _selectAvatar(
                              avatar.avatar ?? ImageAssets.AppIcon,
                              avatar.id ?? 0,
                            );
                          }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                isSelected ? Colors.blue : Colors.transparent,
                            width: isSelected ? 4 : 0,
                          ),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: Colors.blue.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                  : [],
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                isSelected
                                    ? Colors.blue.withValues(alpha: 0.1)
                                    : Colors.transparent,
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              avatar.avatar ?? ImageAssets.AppIcon,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.person,
                                    size: 30,
                                    color: Colors.grey[600],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Enhanced Confirm Button
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                            Get.forceAppUpdate();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: fgColor,
                            foregroundColor: bgColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 3,
                          ),
                          child: Text(
                            "Confirm Selection".tr,
                            style: TextStyle(
                              fontFamily: FontController().currentFontFamily,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
