import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/event_model.dart';
import 'event_riverpod.dart';

final dropDownProvider = StateProvider<EventModel>((ref) {
  var data = ref.read(eventFutureProvider).value;
  return data!.last;
});
