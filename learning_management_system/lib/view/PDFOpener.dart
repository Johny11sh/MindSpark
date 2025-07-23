import 'package:flutter/material.dart';

class PDFOpener extends StatefulWidget {
  const PDFOpener({super.key});

  @override
  State<PDFOpener> createState() => _PDFOpenerState();
}

class _PDFOpenerState extends State<PDFOpener> {
  @override
  Widget build(BuildContext context) {
    
    return const Placeholder();
  }
}


// import 'package:get/get.dart';
// import 'package:learning_management_system/view/Timer.dart';

// class PDFOpener extends StatefulWidget {
//   const PDFOpener({super.key});

//   @override
//   State<PDFOpener> createState() => _PDFOpenerState();
// }

// class _PDFOpenerState extends State<PDFOpener> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('PDF Viewer'),
//         backgroundColor: Colors.deepPurple,
//       ),
//       body: const Center(
//         child: Placeholder(
//           fallbackHeight: 200,
//           fallbackWidth: 300,
//           color: Colors.grey,
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Get.to(() => const TimerView());
//         },
//         backgroundColor: Colors.deepPurple,
//         tooltip: 'Open Timer',
//         child: const Icon(Icons.timer, color: Colors.white),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//     );
//   }
// }