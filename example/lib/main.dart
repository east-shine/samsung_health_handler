// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:samsung_health_handler/samsung_health_handler.dart';
// import 'package:samsung_health_handler/step_count_data_type.dart';

// void main() {
//   Intl.defaultLocale = 'ko_KR';
//   runApp(const MyApp());
// }

// class MyApp extends StatefulWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   final stepStream = SamsungHealthHandler.stream;
//   bool loading = true;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await initialize();
//     });
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     disposeSamsungHealth();
//   }

//   Future<void> initialize() async {
//     // print('1이니셜라이즈?');
//     final isInitialized = await SamsungHealthHandler.initialize();
//     debugPrint('이니셜라이즈?');
//     debugPrint(isInitialized.permissionAcquired?.toString());
//     debugPrint(isInitialized.isConnected.toString());
//     if (isInitialized.isConnected) {
//       // var req = await SamsungHealthHandler.requestPermission();
//       // print('퍼미션???????');
//       // print(req);
//       setState(() {
//         loading = false;
//       });
//       SamsungHealthHandler.passTimestamp(DateTime.now().millisecondsSinceEpoch);
//     }

//     // setState(() {
//     //   loading = false;
//     // });
//     // SamsungHealthHandler.passTimestamp(DateTime.now().millisecondsSinceEpoch);
//   }

//   void disposeSamsungHealth() async {
//     SamsungHealthHandler.dispose();
//     setState(() {
//       loading = true;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // print(samsungHandlerValueHandler.stepCountState.toJson().toString());

//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Plugin example app'),
//         ),
//         body: SingleChildScrollView(
//           child: Center(
//             child: Column(
//               children: <Widget>[
//                 Row(
//                   children: <Widget>[
// //                        Calls data of 2020/04/05
//                     ElevatedButton(
//                       child: const Text('today'),
//                       onPressed: () {
//                         SamsungHealthHandler.passTimestamp(
//                           DateTime.now().millisecondsSinceEpoch,
//                         );
//                       },
//                     ),
//                     ElevatedButton(
//                       child: const Text('prevDate'),
//                       onPressed: () async {
//                         SamsungHealthHandler.prevDate();
//                       },
//                     ),
//                     const ElevatedButton(
//                       onPressed: SamsungHealthHandler.nextDate,
//                       child: Text('nextDate'),
//                     ),
//                   ],
//                 ),
//                 const Text(
//                     'On hot restart, dispose method of stateful widget does not work.'
//                     '\n So, If you want to reinitialize SamsungHealthHandler,'
//                     '\n you have to manually dispose and reinitialize.'),
//                 ElevatedButton(
//                   onPressed: disposeSamsungHealth,
//                   child: const Text('dispose'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () async {
//                     try {
// //                    Must be called after initialized
// //                    gets date of 2020/07/01
//                       debugPrint(
//                         DateTime.parse('2020-11-10T00:00:00.000Z')
//                             .millisecondsSinceEpoch,
//                       );
//                       final timestampFromLocalTime =
//                           // 1593561600000 삼성헬스
//                           // 1604880000000 위플
//                           // DateTime.parse('2020-11-01T00:00:00.000Z').millisecondsSinceEpoch;
//                           DateTime.now().millisecondsSinceEpoch;
//                       // DateTime.parse('2020-07-01T00:00:00.000Z').millisecondsSinceEpoch;
//                       final today = DateTime.now();
//                       // print('@@@@@@@@@@@@@');
//                       print(
//                         DateTime.fromMillisecondsSinceEpoch(
//                           timestampFromLocalTime,
//                         ).difference(today).inDays,
//                       );
//                       final res = await SamsungHealthHandler.getStepCount(
//                         timestampFromLocalTime,
//                       );
//                       debugPrint(res.timestamp);
//                       debugPrint(DateTime.fromMillisecondsSinceEpoch(res.timestamp));
//                       debugPrint(res.stepCount);
//                       debugPrint(res.distance);
//                       debugPrint(res.calorie);
//                       // res.binningData.forEach((element) {
//                       //     print(element.toJson());
//                       // });
//                       // print('바이닝?');
//                       // print(res.binningData);
//                       if (res.binningData != null) {
//                         for (final element in res.binningData) {
//                           debugPrint(element.toJson());
//                         }
//                       }
// //                      print('binningData // ${res.binningData}');
//                     } catch (error) {
//                       debugPrint(error);
//                     }
//                   },
//                   child: const Text('getStepCount once'),
//                 ),
//                 if (!loading)
//                   StreamBuilder<StepCountDataType>(
//                     stream: stepStream,
//                     initialData: StepCountDataType.fromJson({}),
//                     builder: (context, snapshot) {
//                       // if (snapshot.connectionState)
//                       if (snapshot.data?.timestamp != null) {
//                         // try {
//                         print('jqwioejqwiojeioqwjoi');
//                         print(snapshot.data.toJson());
//                         final timestamp = snapshot.data.timestamp;
//                         final date =
//                             DateTime.fromMillisecondsSinceEpoch(timestamp);
//                         final steps = snapshot.data.stepCount;
// //                      Data of today only delivers stepCount
//                         final calorie = snapshot.data.calorie;
//                         final distance = snapshot.data.distance;
//                         final binningData = snapshot.data.binningData;
//                         print(binningData);
//                         return Column(
//                           children: <Widget>[
//                             Text('date: $date'),
//                             Text('steps: $steps'),
//                             Text('calorie: $calorie'),
//                             Text('distance: $distance'),
//                             if (binningData != null)
//                               ListView.separated(
//                                 shrinkWrap: true,
//                                 physics: const NeverScrollableScrollPhysics(),
//                                 itemCount: binningData.length,
//                                 separatorBuilder: (context, index) =>
//                                     const Divider(
//                                   height: 3,
//                                 ),
//                                 itemBuilder: (context, index) {
//                                   final binningValue = binningData[index];
//                                   final binningTime = binningValue.time;
//                                   final binningStepCount =
//                                       binningValue.stepCount;
//                                   return ListTile(
//                                     title: Column(
//                                       children: <Widget>[
//                                         Text('time: $binningTime'),
//                                         Text('steps: $binningStepCount'),
//                                       ],
//                                     ),
//                                   );
//                                 },
//                               ),
//                           ],
//                         );
//                         // } catch (error) {
//                         //   return Text('error: $error');
//                         // }
//                       }
//                       return const Text(
//                         'data of current date does not exist. 2222',
//                       );
//                     },
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
