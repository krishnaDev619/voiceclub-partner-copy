// import 'package:flutter/material.dart';
// import 'package:quiver/async.dart';
// import 'package:voiceclub_partner/view/chat/widgets/bottom_sheet/upgarde_chat_bottomsheet.dart';

// class AudioLimitBottomSheet extends StatefulWidget {
//   const AudioLimitBottomSheet({super.key});

//   @override
//   State<AudioLimitBottomSheet> createState() => _AudioLimitBottomSheetState();
// }

// class _AudioLimitBottomSheetState extends State<AudioLimitBottomSheet> {
//   double amount = 499;
//   CountdownTimer? _timer;
//   String _displayTime = '23:59';

//   @override
//   void initState() {
//     super.initState();
//     _startTimer();
//   }

//   void _startTimer() {
//     final now = DateTime.now();
//     final endTime = now.add(Duration(hours: 24));
//     final duration = endTime.difference(now);

//     _timer = CountdownTimer(duration, Duration(seconds: 1))
//       ..listen((event) {
//         final remaining = event.remaining;
//         final hours = remaining.inHours.toString().padLeft(2, '0');
//         final minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');

//         setState(() {
//           _displayTime = '$hours:$minutes';
//         });

//         if (event.remaining.isNegative) {
//           _timer?.cancel();
//         }
//       });
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.end,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           margin: EdgeInsets.all(12),
//           child: Column(
//             children: [
//               Transform.translate(
//                 offset: const Offset(0, 15),
//                 child: Container(
//                   decoration: ShapeDecoration(
//                     color: Color(0xFFF7F7F7),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     shadows: [
//                       BoxShadow(
//                         color: Color(0x19000000),
//                         blurRadius: 10,
//                         offset: Offset(0, 0),
//                         spreadRadius: 0,
//                       )
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       Container(
//                         padding: EdgeInsets.all(8.0),
//                         child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 Icons.lock_open_rounded,
//                                 color: Colors.black,
//                                 size: 14,
//                               ),
//                               SizedBox(width: 8),
//                               Text(
//                                 '${_displayTime} hours left to chat again',
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   color: Colors.black,
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.w600,
//                                   height: 0,
//                                   letterSpacing: 0.07,
//                                 ),
//                               ),
//                             ]),
//                       ),
//                       SizedBox(
//                         height: 20,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               Container(
//                   width: MediaQuery.of(context).size.width,
//                   decoration: ShapeDecoration(
//                     gradient: LinearGradient(
//                       colors: [Color(0xFF172937), Color(0xFF1E4663)],
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: Transform.translate(
//                     offset: const Offset(0, -10),
//                     child: Column(children: [
//                       Container(
//                         width: 29,
//                         height: 29,
//                         decoration: ShapeDecoration(
//                           color: Colors.white,
//                           shape: OvalBorder(),
//                           shadows: [
//                             BoxShadow(
//                               color: Color(0x26000000),
//                               blurRadius: 20,
//                               offset: Offset(0, 0),
//                               spreadRadius: 0,
//                             )
//                           ],
//                         ),
//                         child: Center(child: Text("or")),
//                       ),
//                       Container(
//                         margin: EdgeInsets.all(8.0),
//                         child: Text(
//                           'You’ve reached Daily Audio Limit',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 17,
//                             fontWeight: FontWeight.w800,
//                             height: 0,
//                             letterSpacing: 0.09,
//                           ),
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: () {
//                           Navigator.pop(context);
//                           showModalBottomSheet(
//                             context: context,
//                             isScrollControlled: true,
//                             isDismissible: true,
//                             backgroundColor: Colors.transparent,
//                             shape: RoundedRectangleBorder(
//                               borderRadius:
//                                   BorderRadius.all(Radius.circular(12.0)),
//                             ),
//                             builder: (BuildContext context) {
//                               return Container(
//                                 child: UpgradeChatBottomsheet(),
//                               );
//                             },
//                           );
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.all(12.0),
//                           margin: const EdgeInsets.all(10.0),
//                           child: Center(
//                               child: Text(
//                             "Subscribe ₹${amount} for 30 Days",
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.w700,
//                               height: 0,
//                             ),
//                           )),
//                           decoration: BoxDecoration(
//                               gradient: LinearGradient(colors: [
//                                 Color.fromRGBO(254, 199, 109, 1),
//                                 Color.fromRGBO(255, 153, 54, 1)
//                               ]),
//                               borderRadius: BorderRadius.circular(10)),
//                         ),
//                       )
//                     ]),
//                   ))
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
