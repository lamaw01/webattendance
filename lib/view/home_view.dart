import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../data/delete_log_riverpod.dart';
import '../data/event_dropdown_provider.dart';
import '../data/event_log_riverpod.dart';
import '../data/event_riverpod.dart';
import '../data/package_info_riverpod.dart';
import '../model/event_log_model.dart';
import '../model/event_model.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  String appVersion = '1.0.0';
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.read(eventLogStateNotifierProvider.notifier).getLastEventLog();
    ref.read(packageInfoFutureProvider.future).then((value) {
      appVersion = value.version;
    });
  }

  void deleteLogDialog(EventLogModel model) async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Log'),
          content: SizedBox(
            // width: 300.0,
            child: PinCodeTextField(
              cursorColor: Colors.black,
              appContext: context,
              controller: controller,
              length: 4,
              obscureText: true,
              obscuringCharacter: '*',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (controller.text == "1223") {
                  await ref.read(
                    deleteLogFutureProvider(DeleteLogArg(
                            id: model.id, employeeId: model.employeeId))
                        .future,
                  );
                  await ref
                      .read(eventLogStateNotifierProvider.notifier)
                      .getLastEventLog();
                }
                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const String title = 'UC-1 Attendance';

    final events = ref.watch(eventFutureProvider);
    final eventLogs = ref.watch(eventLogStateNotifierProvider);

    String fullName(EventLogModel eventLogModel) {
      return '${eventLogModel.lastName}, ${eventLogModel.firstName} ${eventLogModel.middleName}';
    }

    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text(title),
            const SizedBox(
              width: 2.5,
            ),
            Text(
              'v$appVersion',
              style: const TextStyle(fontSize: 12.0),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: SizedBox(
              width: 125.0,
              height: 50.0,
              child: Center(
                child: TextField(
                  textAlign: TextAlign.right,
                  style: const TextStyle(),
                  controller: searchController,
                  cursorColor: Colors.black,
                  onChanged: (value) {
                    final dropDownValue =
                        ref.read(dropDownProvider.notifier).state;
                    ref
                        .read(eventLogStateNotifierProvider.notifier)
                        .searchEventLog(
                            searchInput: value, eventId: dropDownValue.eventId);
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search name/id..',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                    focusColor: Colors.black,
                    fillColor: Colors.black,
                    hoverColor: Colors.black,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                      ),
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    disabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 5.0),
              events.when(
                data: (data) {
                  return Container(
                    width: 590.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.white,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<EventModel>(
                        style: const TextStyle(color: Colors.black),
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        borderRadius: BorderRadius.circular(5.0),
                        value: ref.watch(dropDownProvider),
                        onChanged: (value) {
                          ref.read(dropDownProvider.notifier).state = value!;
                          ref
                              .read(eventLogStateNotifierProvider.notifier)
                              .getEventLog(eventId: value.eventId);
                        },
                        items: data.map<DropdownMenuItem<EventModel>>(
                            (EventModel value) {
                          return DropdownMenuItem<EventModel>(
                            value: value,
                            child: Text(
                              value.eventName,
                              style: const TextStyle(fontSize: 20.0),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
                error: (error, stack) => Text(error.toString()),
                loading: () => const SizedBox(
                  width: 200.0,
                  child: Center(child: Text('Loading..')),
                ),
              ),
              const SizedBox(height: 5.0),
              Expanded(
                child: SizedBox(
                  width: 600.0,
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await ref
                          .read(eventLogStateNotifierProvider.notifier)
                          .getLastEventLog();
                    },
                    child: ListView.builder(
                      itemCount: eventLogs.length,
                      itemBuilder: ((context, index) {
                        return Card(
                          child: ListTile(
                            title: Text(
                              fullName(eventLogs[index]),
                              maxLines: 2,
                            ),
                            subtitle: Text(eventLogs[index].employeeId),
                            trailing: Text(
                                dateFormat.format(eventLogs[index].timeStamp)),
                            visualDensity: VisualDensity.comfortable,
                            onLongPress: () {
                              deleteLogDialog(eventLogs[index]);
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              SizedBox(
                height: 20.0,
                child: Text('Total: ${eventLogs.length}'),
              ),
              const SizedBox(height: 5.0),
            ],
          ),
        ),
      ),
    );
  }
}
