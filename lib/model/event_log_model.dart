// To parse this JSON data, do
//
//     final eventLogModel = eventLogModelFromJson(jsonString);

import 'dart:convert';

List<EventLogModel> eventLogModelFromJson(String str) =>
    List<EventLogModel>.from(
        json.decode(str).map((x) => EventLogModel.fromJson(x)));

String eventLogModelToJson(List<EventLogModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class EventLogModel {
  int id;
  String employeeId;
  String firstName;
  String lastName;
  String middleName;
  int eventId;
  String eventName;
  List<Company> company;
  DateTime timeStamp;

  EventLogModel({
    required this.id,
    required this.employeeId,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.eventId,
    required this.eventName,
    required this.company,
    required this.timeStamp,
  });

  factory EventLogModel.fromJson(Map<String, dynamic> json) => EventLogModel(
        id: json["id"],
        employeeId: json["employee_id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        middleName: json["middle_name"],
        eventId: json["event_id"],
        eventName: json["event_name"],
        company:
            List<Company>.from(json["company"].map((x) => Company.fromJson(x))),
        timeStamp: DateTime.parse(json["time_stamp"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "employee_id": employeeId,
        "first_name": firstName,
        "last_name": lastName,
        "middle_name": middleName,
        "event_id": eventId,
        "event_name": eventName,
        "company": List<dynamic>.from(company.map((x) => x.toJson())),
        "time_stamp": timeStamp.toIso8601String(),
      };
}

class Company {
  String companyName;

  Company({
    required this.companyName,
  });

  factory Company.fromJson(Map<String, dynamic> json) => Company(
        companyName: json["company_name"],
      );

  Map<String, dynamic> toJson() => {
        "company_name": companyName,
      };
}
