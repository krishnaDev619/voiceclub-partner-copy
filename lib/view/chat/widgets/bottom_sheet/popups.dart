//  Column UpgradeNowPop(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         Align(
//             alignment: Alignment.topRight,
//             child: Padding(
//               padding: const EdgeInsets.only(right: 16),
//               child: GestureDetector(
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//                 child: Icon(
//                   Icons.close,
//                   size: 28.0,
//                   color: Colors.white,
//                 ),
//               ),
//             )),
//         Container(
//           margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           decoration: ShapeDecoration(
//             color: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15),
//             ),
//           ),
//           child: Column(
//             children: [
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 16, horizontal: 30),
//                 child: Text(
//                   'Are you sure you want to Upgrade chat with ${partnerName} at ₹${amount}?',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontSize: 19,
//                     fontFamily: GoogleFonts.mulish().fontFamily,
//                     fontWeight: FontWeight.w800,
//                     height: 0,
//                   ),
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   Navigator.pop(context);
//                   double walletBalance =
//                       Get.find<WalletController>().finalValue.value;
//                   if (walletBalance < amount) {
//                     double needToAdd = amount - walletBalance;
//                     showModalBottomSheet(
//                       context: context,
//                       isScrollControlled: false,
//                       isDismissible: true,
//                       backgroundColor: Colors.transparent,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.all(Radius.circular(12.0)),
//                       ),
//                       builder: (BuildContext context) {
//                         return RechargeWalletPopUp(context, needToAdd);
//                       },
//                     );
//                   } else {
//                     // Logic to Proceed to Pay if payment is Done then we need to show the below PopUp
//                     Navigator.pop(context);
//                   }
//                 },
//                 child: Container(
//                   height: 44,
//                   margin: EdgeInsets.only(left: 20, right: 20, bottom: 16),
//                   decoration: ShapeDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment(1.00, 0.06),
//                       end: Alignment(-1, -0.06),
//                       colors: [
//                         Color(0xFFFF9937),
//                         Color(0xFFFEC56B),
//                       ],
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     shadows: [
//                       BoxShadow(
//                         color: Color(0x33000000),
//                         blurRadius: 20,
//                         offset: Offset(0, 0),
//                         spreadRadius: 0,
//                       )
//                     ],
//                   ),
//                   child: Center(
//                     child: Text(
//                       'Upgrade Now',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontFamily: GoogleFonts.mulish().fontFamily,
//                         fontWeight: FontWeight.bold,
//                         height: 0,
//                       ),
//                     ),
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Column RechargeWalletPopUp(BuildContext context, double needToAdd) {
//     needToAdd = double.parse(needToAdd.toStringAsFixed(2));
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         Align(
//             alignment: Alignment.topRight,
//             child: Padding(
//               padding: const EdgeInsets.only(right: 16),
//               child: GestureDetector(
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//                 child: Icon(
//                   Icons.close,
//                   size: 28.0,
//                   color: Colors.white,
//                 ),
//               ),
//             )),
//         Container(
//           margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           decoration: ShapeDecoration(
//             color: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15),
//             ),
//           ),
//           child: Column(
//             children: [
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 16, horizontal: 30),
//                 child: Text(
//                   'Add ₹${needToAdd} more to Chat with ${partnerName}!',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontSize: 19,
//                     fontFamily: GoogleFonts.mulish().fontFamily,
//                     fontWeight: FontWeight.w800,
//                     height: 0,
//                   ),
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//                 child: Container(
//                   height: 44,
//                   margin: EdgeInsets.only(left: 20, right: 20, bottom: 16),
//                   decoration: ShapeDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment(1.00, 0.06),
//                       end: Alignment(-1, -0.06),
//                       colors: [Color(0xFFFF7D42), Get.theme.primaryColor],
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     shadows: [
//                       BoxShadow(
//                         color: Color(0x33000000),
//                         blurRadius: 20,
//                         offset: Offset(0, 0),
//                         spreadRadius: 0,
//                       )
//                     ],
//                   ),
//                   child: Center(
//                     child: Text(
//                       'Add Money',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontFamily: GoogleFonts.mulish().fontFamily,
//                         fontWeight: FontWeight.bold,
//                         height: 0,
//                       ),
//                     ),
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ],
//     );
//   }
