import 'dart:async';

import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:samsung_health_handler/step_count_data_type.dart';

//
class SamsungHealthHandlerInitialize {
  bool isConnected;
  bool? permissionAcquired;

  SamsungHealthHandlerInitialize({
    required this.isConnected,
    this.permissionAcquired,
  });
}

class SamsungHealthHandler {
  static const MethodChannel channel = MethodChannel('samsung_health_handler');
  static const EventChannel stepChannel =
      EventChannel('samsung_health_handler_event_steps_channel');
  static const EventChannel connectionChannel =
      EventChannel('samsung_health_handler_event_connection_channel');

  // ignore: close_sinks
  static StreamController<StepCountDataType> streamController =
      StreamController.broadcast();

  static Stream<StepCountDataType?> get stream =>
      SamsungHealthHandler.stepChannel.receiveBroadcastStream().map((event) {
        // print('@@@@@@@@@@@@@@@@@');
        // print(event);
        // print(event.runtimeType.toString());
        // print(event.runtimeType.toString() != 'List<dynamic>');
        // print('!!!!!!!!!!!!!!!!!!!!!!!');
        if (event.runtimeType.toString().contains('List<dynamic>') ||
            event.runtimeType.toString().contains('List<Object?>')) {
          // print('!!!!들갔누!!!!!!!!!!!!!!!!!!!');
          final newArr = List<dynamic>.from(event);
          final stepCountBinningData = newArr.map((e) {
//            print(e);
            return StepCountBinningDataType.fromJson({
              ...e,
              'receivedAt': DateTime.now().millisecondsSinceEpoch,
            });
          }).toList();
          final stepCountData =
              samsungHandlerValueHandler.stepCountState.value!.toJson();
          // print('이거니??');
          // print(stepCountData);
          samsungHandlerValueHandler.stepCountState.add(
            StepCountDataType.fromJson({
              ...stepCountData,
              ...{
                'binningData': stepCountBinningData,
              },
            }),
          );
        } else {
          final data = Map<String, dynamic>.from(event);
          // print('이거니??2222');
          // print(data);
          final today = DateTime.now();
          if (DateTime.fromMillisecondsSinceEpoch(data['timestamp'])
                  .difference(today)
                  .inDays >=
              0) {
            samsungHandlerValueHandler.stepCountState.add(
              StepCountDataType.fromJson({
                ...data,
                ...{'binningData': null},
              }),
            );
          } else {
            samsungHandlerValueHandler.stepCountState.add(
              StepCountDataType.fromJson({
                ...data,
                ...{
                  'binningData': samsungHandlerValueHandler
                      .stepCountState.value?.binningData,
                },
              }),
            );
          }
        }
        if (samsungHandlerValueHandler.stepCountState.value != null) {
          return samsungHandlerValueHandler.stepCountState.value;
        }
        return null;
        // return samsungHandlerValueHandler.stepCountState.value;
      });

  // ignore: top_level_function_literal_block
  static Stream<dynamic> get connectionStream =>
      SamsungHealthHandler.connectionChannel
          .receiveBroadcastStream()
          .map((event) {
        final data = Map<String, dynamic>.from(event);
        return data;
      });

  static Future<SamsungHealthHandlerInitialize> initialize() async {
    final result = SamsungHealthHandlerInitialize(
      isConnected: false,
      permissionAcquired: false,
    );

    if (samsungHandlerInitializeState.initialized.value == true) {
      // print('ALREADY_INITIALIZED@@@@@@@@@@@@');
      result.isConnected = true;
      // var res = await isPermissionAcquired();
      // 일단 이렇게 가정함...
      // result.permissionAcquired = true;
      return result;
      // result.permissionAcquired = true;
    }
    channel.invokeMethod('initialize');
    final res = SamsungHealthHandler.connectionStream.takeWhile((element) {
      // print('123123@@@@@@@@@@@@');
      // print(element);
      // print('@@!12121212');
      // if (element['requestPermissionResult'] != null) result.permissionAcquired = true;
      // permissionAcquired = element['requestPermissionResult'];
      if (element['isConnected'] == true) result.isConnected = true;
      if (element['requestPermissionResult'] != null) {
        result.permissionAcquired = true;
      }
      return element['isConnected'] == null ||
          element['requestPermissionResult'] == null;
    });
    // var permissionRes = SamsungHealthHandler.connectionStream.takeWhile((element) {
    //   print('@@@@@@@@@@@@');
    //   print(element);
    //   // print('@@!12121212');
    //   // if (element['requestPermissionResult'] != null) result.permissionAcquired = true;
    //   // permissionAcquired = element['requestPermissionResult'];
    //   if (element['requestPermissionResult'] != null) result.permissionAcquired = true;
    //   return element['requestPermissionResult'] == null;
    // });
//    돌기까지 기다림
    await res.isEmpty;
    // await permissionRes.isEmpty;
    samsungHandlerInitializeState.initialized.add(true);
    return result;
  }

  static void dispose() async {
    channel.invokeMethod('dispose');
  }

  static Future<Map<String, dynamic>> isPermissionAcquired() async {
    final result = await channel.invokeMethod('isPermissionAcquired');
    return Map<String, dynamic>.from(result);
  }

  static Future<dynamic> requestPermission() async {
    final dynamic result = await channel.invokeMethod('requestPermission');
    return result;
  }

  static void passTimestamp(int timestampInMillisecond) {
    channel
        .invokeMethod('passTimestamp', {'timestamp': timestampInMillisecond});
  }

  static Future<dynamic> prevDate() async {
    final dynamic result = await channel.invokeMethod('prevDate');
    return result;
  }

  static Future<dynamic> nextDate() async {
    final dynamic result = await channel.invokeMethod('nextDate');
    return result;
  }

  static Future<StepCountDataType> getStepCount(
    int millisecondTimestamp,
  ) async {
    passTimestamp(millisecondTimestamp);
    var result = StepCountDataType.fromJson({});
    final today = DateTime.now();
    try {
      final intList = List<int>.generate(15, (i) => i + 1);
      await Future.forEach(intList, (_) async {
        await Future.delayed(const Duration(milliseconds: 30));
        final passedTime =
            DateTime.fromMillisecondsSinceEpoch(millisecondTimestamp);
        final value = samsungHandlerValueHandler.stepCountState.value;
        if (value?.timestamp != null) {
          final dateTime =
              DateTime.fromMillisecondsSinceEpoch(value!.timestamp);
          // var newValue = samsungHandlerValueHandler.stepCountState.value!.toJson();
          // print('@@@@@@@@@@@@22222223');
          // print(newValue);
          if (dateTime.day == passedTime.day &&
              dateTime.month == passedTime.month &&
              dateTime.year == passedTime.year) {
            if (passedTime.difference(today).inDays >= 0) {
              final newValue =
                  samsungHandlerValueHandler.stepCountState.value!.toJson();
              // print('@@@@@@@@@@@@');
              // print(newValue);
              newValue['binningData'] = null;
              result = StepCountDataType.fromJson(newValue);
            }
            result = value;
            return;
          }
        }
        return;
      });
      return result;
    } catch (error) {
      rethrow;
    }
  }
}

class SamsungHandlerValueHandler {
  // ignore: close_sinks
  BehaviorSubject<StepCountDataType> stepCountState =
      BehaviorSubject<StepCountDataType>.seeded(
    StepCountDataType.fromJson({}),
  );
}

class SamsungHandlerInitializeState {
  // ignore: close_sinks
  BehaviorSubject<bool> initialized = BehaviorSubject<bool>.seeded(false);
}

SamsungHandlerInitializeState samsungHandlerInitializeState =
    SamsungHandlerInitializeState();

SamsungHandlerValueHandler samsungHandlerValueHandler =
    SamsungHandlerValueHandler();
