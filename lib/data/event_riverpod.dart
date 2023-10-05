import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/event_model.dart';
import 'dio_service_riverpod.dart';

final eventFutureProvider = FutureProvider.autoDispose<List<EventModel>>(
  (ref) {
    var dioProvider = ref.watch(dioServiceProvider);
    return dioProvider.getEvent();
  },
);
