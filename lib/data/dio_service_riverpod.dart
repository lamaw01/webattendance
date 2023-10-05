import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../service/dio_service.dart';

final dioServiceProvider = Provider((ref) {
  return DioService();
});
