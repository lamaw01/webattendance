import 'package:excel/excel.dart';
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
  final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(packageInfoFutureProvider.future).then((value) {
        appVersion = value.version;
      });
      await ref.read(eventLogStateNotifierProvider.notifier).getLastEventLog();
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
                  // ignore: use_build_context_synchronously
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

  void downloadExcel(List<EventLogModel> eventLogs, EventModel eventModel) {
    try {
      final excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      final cellStyle = CellStyle(
        backgroundColorHex: '#dddddd',
        fontFamily: getFontFamily(FontFamily.Calibri),
        horizontalAlign: HorizontalAlign.Center,
        fontSize: 12,
        bold: true,
      );

      final column1 = sheetObject.cell(CellIndex.indexByString('A1'));
      column1.value = const TextCellValue('#');
      column1.cellStyle = cellStyle;

      final column2 = sheetObject.cell(CellIndex.indexByString('B1'));
      column2.value = const TextCellValue('QR ID');
      column2.cellStyle = cellStyle;

      final column3 = sheetObject.cell(CellIndex.indexByString('C1'));
      column3.value = const TextCellValue('Name');
      column3.cellStyle = cellStyle;

      final column4 = sheetObject.cell(CellIndex.indexByString('D1'));
      column4.value = const TextCellValue('Company');
      column4.cellStyle = cellStyle;

      final column5 = sheetObject.cell(CellIndex.indexByString('E1'));
      column5.value = const TextCellValue('Timestamp');
      column5.cellStyle = cellStyle;

      // var cell = worksheet.cell(CellIndex.indexByColumnRow(0, 0));
      // cell.value = IntCellValue(1);
      // cell.cellStyle = CellStyle(numberFormat: NumFormat.defaultNumeric);

      sheetObject.setColumnWidth(0, 7.0);
      sheetObject.setColumnWidth(1, 15.0);
      sheetObject.setColumnWidth(2, 30.0);
      sheetObject.setColumnWidth(3, 25.0);
      sheetObject.setColumnWidth(4, 18.0);

      int counter = 0;
      for (int i = 0; i < eventLogs.length; i++) {
        counter = counter + 1;
        String companies = '';
        for (var company in eventLogs[i].company) {
          companies = '$companies ${company.companyName}';
        }
        List<CellValue> dataList = [
          IntCellValue(counter),
          TextCellValue(eventLogs[i].employeeId),
          TextCellValue(fullName(eventLogs[i])),
          TextCellValue(companies),
          DateTimeCellValue.fromDateTime(eventLogs[i].timeStamp)
        ];
        sheetObject.appendRow(dataList);

        sheetObject.updateCell(
          CellIndex.indexByColumnRow(
            columnIndex: 0,
            rowIndex: counter,
          ),
          IntCellValue(counter),
          cellStyle: CellStyle(
            numberFormat: NumFormat.defaultNumeric,
            horizontalAlign: HorizontalAlign.Center,
            fontSize: 10,
          ),
        );
        sheetObject.updateCell(
          CellIndex.indexByColumnRow(
            columnIndex: 1,
            rowIndex: counter,
          ),
          TextCellValue(eventLogs[i].employeeId),
          cellStyle: CellStyle(
            numberFormat: NumFormat.standard_0,
            horizontalAlign: HorizontalAlign.Center,
            fontSize: 10,
          ),
        );
        sheetObject.updateCell(
          CellIndex.indexByColumnRow(
            columnIndex: 2,
            rowIndex: counter,
          ),
          TextCellValue(fullName(eventLogs[i])),
          cellStyle: CellStyle(
            numberFormat: NumFormat.standard_0,
            horizontalAlign: HorizontalAlign.Center,
            fontSize: 10,
          ),
        );
        sheetObject.updateCell(
          CellIndex.indexByColumnRow(
            columnIndex: 3,
            rowIndex: counter,
          ),
          TextCellValue(companies),
          cellStyle: CellStyle(
            numberFormat: NumFormat.standard_0,
            horizontalAlign: HorizontalAlign.Center,
            fontSize: 10,
          ),
        );
        sheetObject.updateCell(
          CellIndex.indexByColumnRow(
            columnIndex: 4,
            rowIndex: counter,
          ),
          DateTimeCellValue.fromDateTime(eventLogs[i].timeStamp),
          cellStyle: CellStyle(
            numberFormat: NumFormat.defaultDateTime,
            horizontalAlign: HorizontalAlign.Center,
            fontSize: 10,
          ),
        );
      }
      excel.save(fileName: '${eventModel.eventName}.xlsx');
    } catch (e) {
      debugPrint('downloadExcel $e');
    }
  }

  String fullName(EventLogModel eventLogModel) {
    return '${eventLogModel.lastName}, ${eventLogModel.firstName} ${eventLogModel.middleName}';
  }

  @override
  Widget build(BuildContext context) {
    const String title = 'UC-1 Attendance';

    final events = ref.watch(eventFutureProvider);
    final eventLogs = ref.watch(eventLogStateNotifierProvider);

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
                            leading: Text(
                              eventLogs[index].employeeId,
                              style: const TextStyle(fontSize: 12.0),
                            ),
                            title: Text(
                              fullName(eventLogs[index]),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14.0),
                            ),
                            subtitle: Row(
                              children: [
                                for (var company
                                    in eventLogs[index].company) ...[
                                  Text(
                                    company.companyName,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 13.0,
                                    ),
                                  ),
                                  const SizedBox(width: 5.0),
                                ],
                              ],
                            ),
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
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 20.0,
                    child: Text('Total: ${eventLogs.length}'),
                  ),
                  TextButton(
                    onPressed: () {
                      final dropDownValue =
                          ref.read(dropDownProvider.notifier).state;
                      downloadExcel(eventLogs, dropDownValue);
                    },
                    child: const Text(
                      'Download Excel',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5.0),
            ],
          ),
        ),
      ),
    );
  }
}
