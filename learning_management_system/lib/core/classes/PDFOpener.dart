// ignore_for_file: file_names, non_constant_identifier_names

import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path/path.dart';
import '../../themes/Themes.dart';
import 'package:get/get.dart';
import '../../themes/ThemeController.dart';

class PDFOpener extends StatefulWidget {
  final File PDFfile;
  const PDFOpener({super.key, required this.PDFfile});

  @override
  State<PDFOpener> createState() => _PDFOpenerState();
}

class _PDFOpenerState extends State<PDFOpener> {
  late PDFViewController pdfViewController;
  int pages = 0;
  int pageIndex = 0;
  bool isLoading = true;
  final ThemeController themeController = Get.find<ThemeController>();
  bool isDragging = false;
  final ScrollController _scrollController = ScrollController();
  bool _isDisposed = false;

  String _formatFileName(String name) {
    if (name.toLowerCase().endsWith('.pdf')) {
      return name.substring(0, name.length - 4);
    }
    return name;
  }

  @override
  void initState() {
    super.initState();
    // Hide system UI when entering PDF viewer
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _preloadPDF();
  }

  Future<void> _preloadPDF() async {
    if (_isDisposed) return;

    try {
      final file = widget.PDFfile;
      if (await file.exists()) {
        if (!_isDisposed) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error preloading PDF: $e');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    // Show system UI when leaving PDF viewer
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = _formatFileName(basename(widget.PDFfile.path));
    return Scaffold(
      backgroundColor: themeController.initialTheme == Themes.customLightTheme
          ? const Color.fromARGB(255, 40, 41, 61)
          : const Color.fromARGB(255, 210, 209, 224),
      appBar: AppBar(
        backgroundColor: themeController.initialTheme == Themes.customLightTheme
            ? const Color.fromARGB(255, 40, 41, 61)
            : const Color.fromARGB(255, 210, 209, 224),
        title: Text(
          name,
          style: TextStyle(
            color: themeController.initialTheme == Themes.customLightTheme
                ? const Color.fromARGB(255, 210, 209, 224)
                : const Color.fromARGB(255, 40, 41, 61),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: themeController.initialTheme == Themes.customLightTheme
                ? const Color.fromARGB(255, 210, 209, 224)
                : const Color.fromARGB(255, 40, 41, 61),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (pages > 0) ...[
            IconButton(
              onPressed: () {
                final page = pageIndex == 0 ? pages : pageIndex - 1;
                pdfViewController.setPage(page);
              },
              icon: Icon(
                Icons.chevron_left_outlined,
                size: 26,
                color: themeController.initialTheme == Themes.customLightTheme
                    ? const Color.fromARGB(255, 210, 209, 224)
                    : const Color.fromARGB(255, 40, 41, 61),
              ),
            ),
            if (pages > 0)
              Text(
                '${pageIndex + 1} of $pages',
                style: TextStyle(
                  fontSize: 12,
                  color: themeController.initialTheme == Themes.customLightTheme
                      ? const Color.fromARGB(255, 210, 209, 224)
                      : const Color.fromARGB(255, 40, 41, 61),
                ),
              ),
            IconButton(
              onPressed: () {
                final page = pageIndex == pages - 1 ? 0 : pageIndex + 1;
                pdfViewController.setPage(page);
              },
              icon: Icon(
                Icons.chevron_right_outlined,
                size: 26,
                color: themeController.initialTheme == Themes.customLightTheme
                    ? const Color.fromARGB(255, 210, 209, 224)
                    : const Color.fromARGB(255, 40, 41, 61),
              ),
            ),
          ],
        ],
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.PDFfile.path,
            swipeHorizontal: false,
            pageSnap: false,
            autoSpacing: true,
            pageFling: false,
            preventLinkNavigation: false,
            onRender: (pages) {
              if (!_isDisposed) {
                setState(() {
                  this.pages = pages!;
                  isLoading = false;
                });
              }
            },
            onViewCreated: (pdfViewController) {
              if (!_isDisposed) {
                setState(() {
                  this.pdfViewController = pdfViewController;
                });
              }
            },
            onPageChanged: (pageIndex, _) {
              if (!_isDisposed) {
                setState(() {
                  this.pageIndex = pageIndex!;
                });
              }
            },
            onError: (error) {
              debugPrint('Error loading PDF: $error');
              if (!_isDisposed) {
                Get.snackbar(
                  'Error'.tr,
                  'Failed to load PDF'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            onPageError: (page, error) {
              debugPrint('Error loading page $page: $error');
            },
            enableSwipe: true,
            fitPolicy: FitPolicy.BOTH,
            defaultPage: 0,
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(
                color: themeController.initialTheme == Themes.customLightTheme
                    ? const Color.fromARGB(255, 210, 209, 224)
                    : const Color.fromARGB(255, 40, 41, 61),
              ),
            ),
          if (pages > 0)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 40,
                color: Colors.transparent,
                child: Center(
                  child: Container(
                    width: 8,
                    height: MediaQuery.of(context).size.height * 0.75,
                    decoration: BoxDecoration(
                      color: themeController.initialTheme == Themes.customLightTheme
                          ? const Color.fromARGB(255, 210, 209, 224).withOpacity(0.5)
                          : const Color.fromARGB(255, 40, 41, 61).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: GestureDetector(
                      onVerticalDragStart: (_) => setState(() => isDragging = true),
                      onVerticalDragEnd: (_) => setState(() => isDragging = false),
                      onVerticalDragUpdate: (details) {
                        if (pages > 0) {
                          final screenHeight = MediaQuery.of(context).size.height * 0.7;
                          final dragPercentage = details.localPosition.dy / screenHeight;
                          final targetPage = (dragPercentage * (pages - 1)).floor();
                          if (targetPage >= 0 && targetPage < pages) {
                            pdfViewController.setPage(targetPage);
                          }
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          if (isDragging && pages > 0)
            Positioned(
              right: 50,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: themeController.initialTheme == Themes.customLightTheme
                        ? const Color.fromARGB(255, 40, 41, 61)
                        : const Color.fromARGB(255, 210, 209, 224),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${pageIndex + 1}',
                    style: TextStyle(
                      color: themeController.initialTheme == Themes.customLightTheme
                          ? const Color.fromARGB(255, 210, 209, 224)
                          : const Color.fromARGB(255, 40, 41, 61),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
