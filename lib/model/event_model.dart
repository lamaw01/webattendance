// To parse this JSON data, do
//
//     final eventModel = eventModelFromJson(jsonString);

import 'dart:convert';

List<EventModel> eventModelFromJson(String str) =>
    List<EventModel>.from(json.decode(str).map((x) => EventModel.fromJson(x)));

String eventModelToJson(List<EventModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class EventModel {
  int eventId;
  String eventName;

  EventModel({
    required this.eventId,
    required this.eventName,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        eventId: json["event_id"],
        eventName: json["event_name"],
      );

  Map<String, dynamic> toJson() => {
        "event_id": eventId,
        "event_name": eventName,
      };
}
