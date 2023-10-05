import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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

  @override
  void initState() {
    super.initState();
    ref.read(eventLogStateNotifierProvider.notifier).getLastEventLog();
    ref.read(packageInfoFutureProvider.future).then((value) {
      appVersion = value.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    const String title = 'UC-1 Event Attendance';

    final events = ref.watch(eventFutureProvider);
    final eventLogs = ref.watch(eventLogStateNotifierProvider);

    String fullName(EventLogModel eventLogModel) {
      return '${eventLogModel.lastName}, ${eventLogModel.firstName} ${eventLogModel.middleName}';
    }

    final dateFormat = DateFormat().add_yMEd().add_Hms();
    final searchController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text(title),
            const SizedBox(
              width: 2.5,
            ),
            Text(
              appVersion,
              style: const TextStyle(fontSize: 12.0),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: SizedBox(
              width: 250.0,
              height: 50.0,
              child: Center(
                child: TextField(
                  textAlign: TextAlign.right,
                  style: const TextStyle(),
                  controller: searchController,
                  cursorColor: Colors.black,
                  onSubmitted: (value) {
                    final dropDownValue =
                        ref.read(dropDownProvider.notifier).state;
                    ref
                        .read(eventLogStateNotifierProvider.notifier)
                        .searchEventLog(
                            searchInput: value, eventId: dropDownValue.eventId);
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search..',
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
                  child: ListView.builder(
                    itemCount: eventLogs.length,
                    itemBuilder: ((context, index) {
                      return Card(
                        child: ListTile(
                          // leading: Text(eventLogs[index].eventName),
                          title: Text(
                            fullName(eventLogs[index]),
                            maxLines: 1,
                          ),
                          subtitle: Text(eventLogs[index].employeeId),
                          trailing: Text(
                              dateFormat.format(eventLogs[index].timeStamp)),
                          visualDensity: VisualDensity.comfortable,
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
