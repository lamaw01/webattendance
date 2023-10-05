import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/event_log_model.dart';
import '../service/dio_service.dart';

final eventLogStateNotifierProvider =
    StateNotifierProvider<EventLogNotifier, List<EventLogModel>>((ref) {
  return EventLogNotifier();
});

class EventLogNotifier extends StateNotifier<List<EventLogModel>> {
  EventLogNotifier() : super([]);

  Future<void> getLastEventLog() async {
    state = await DioService().getLastEventLog();
  }

  Future<void> getEventLog({required int eventId}) async {
    state = await DioService().getEventLog(eventId: eventId);
  }

  Future<void> searchEventLog(
      {required String searchInput, required int eventId}) async {
    state = await DioService()
        .searchEventLog(searchInput: searchInput, eventId: eventId);
  }
}
