import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dio_service_riverpod.dart';

class DeleteLogArg {
  int id;
  String employeeId;
  DeleteLogArg({required this.id, required this.employeeId});
}

final deleteLogFutureProvider =
    FutureProvider.autoDispose.family<void, DeleteLogArg>(
  (ref, arg) async {
    var dioProvider = ref.watch(dioServiceProvider);
    await dioProvider.deleteLog(id: arg.id, employeeId: arg.employeeId);
  },
);
