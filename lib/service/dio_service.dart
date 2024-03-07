import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../model/event_log_model.dart';
import '../model/event_model.dart';

class DioService {
  static const String _serverUrl = 'http://103.62.153.74:53000';

  final _dio = Dio(
    BaseOptions(
      baseUrl: '$_serverUrl/attendance_web_api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: <String, String>{
        'Accept': '*/*',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    ),
  );

  Future<List<EventModel>> getEvent() async {
    Response response = await _dio.get('/get_event.php');
    // debugPrint(response.data.toString());
    return eventModelFromJson(json.encode(response.data));
  }

  Future<List<EventLogModel>> getLastEventLog() async {
    Response response = await _dio.get('/get_last_event_log.php');
    // debugPrint(response.data.toString());
    return eventLogModelFromJson(json.encode(response.data));
  }

  Future<List<EventLogModel>> getEventLog({required int eventId}) async {
    Response response =
        await _dio.post('/get_event_log.php', data: {"event_id": eventId});
    // debugPrint(response.data.toString());
    return eventLogModelFromJson(json.encode(response.data));
  }

  Future<List<EventLogModel>> searchEventLog(
      {required String searchInput, required int eventId}) async {
    Response response = await _dio.post('/search_event_log.php', data: {
      "search_input": searchInput,
      "event_id": eventId,
    });
    // debugPrint(response.data.toString());
    return eventLogModelFromJson(json.encode(response.data));
  }

  Future<void> deleteLog({required int id, required String employeeId}) async {
    Response response = await _dio.post('/delete_log.php', data: {
      "id": id,
      "employee_id": employeeId,
    });
    debugPrint(response.data.toString());
  }
}
