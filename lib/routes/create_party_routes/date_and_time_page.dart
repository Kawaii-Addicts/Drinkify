import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '/utils/theming.dart';
import '/utils/locale_support.dart';

final Color errorColor = Colors.red.withOpacity(0.3);

//Moved outside the class to let the values stay after the page switch
DateTime? startDate;
TimeOfDay? startTime;
DateTime? stopDate;
TimeOfDay? stopTime;
List<int> errorFields = [];

late AppLocalizations transl;

class DateAndTimePage extends StatefulWidget {
  /// * start time, stop time, next page index
  final Function(DateTime, DateTime, int) onNext;

  /// * index of previous page
  final Function(int) onPrevious;

  const DateAndTimePage({
    required this.onPrevious,
    required this.onNext,
    super.key,
  });

  @override
  State<DateAndTimePage> createState() => _DateAndTimePageState();
}

class _DateAndTimePageState extends State<DateAndTimePage> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
  }

  @override
  Widget build(BuildContext context) {
    transl = LocaleSupport.appTranslates(context);

    const double topLeftRightPadding = 15;

    return Scaffold(
      backgroundColor: Theming.bgColor,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).viewPadding.top + 40),
            _categoryText(transl.pickDateAndTime),
            Expanded(
              flex: 6,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _dateOrTimeButton(
                      context,
                      0,
                      textValue: startDate,
                      isStart: true,
                      isDate: true,
                    ),
                    _dateOrTimeButton(
                      context,
                      1,
                      textValue: startTime,
                      isStart: true,
                      isDate: false,
                    ),
                    Text(
                      transl.to,
                      style: const TextStyle(
                        fontSize: 24,
                      ),
                    ),
                    _dateOrTimeButton(
                      context,
                      2,
                      textValue: stopDate,
                      isStart: false,
                      isDate: true,
                    ),
                    _dateOrTimeButton(
                      context,
                      3,
                      textValue: stopTime,
                      isStart: false,
                      isDate: false,
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 100 + MediaQuery.of(context).viewPadding.bottom,
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _navButton(
                      context,
                      topLeftRightPadding,
                      backgroundColor: Theming.whiteTone,
                      text: Text(
                        transl.back,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      onTap: () => widget.onPrevious(1),
                    ),
                    _navButton(
                      context,
                      topLeftRightPadding,
                      backgroundColor: Theming.primaryColor,
                      text: Text(
                        transl.next,
                        style: const TextStyle(
                          color: Theming.whiteTone,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      onTap: () {
                        setState(() => errorFields = []);

                        final List<dynamic> fields = [
                          startDate,
                          startTime,
                          stopDate,
                          stopTime,
                        ];

                        for (int i = 0; i < fields.length; i++) {
                          if (fields[i] == null) {
                            setState(() => errorFields.add(i));
                          }
                        }

                        if (errorFields.isNotEmpty) return;

                        var startDateTime = DateTime(
                          startDate!.year,
                          startDate!.month,
                          startDate!.day,
                          startTime!.hour,
                          startTime!.minute,
                        );

                        var stopDateTime = DateTime(
                          stopDate!.year,
                          stopDate!.month,
                          stopDate!.day,
                          stopTime!.hour,
                          stopTime!.minute,
                        );

                        if (stopDateTime.isBefore(startDateTime)) {
                          for (int i = 0; i < fields.length; i++) {
                            setState(() => errorFields.add(i));
                          }
                          return;
                        }

                        widget.onNext(
                          startDateTime,
                          stopDateTime,
                          3,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryText(String caption) {
    return Text(
      caption,
      style: const TextStyle(
        color: Theming.whiteTone,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

  Widget _navButton(
    BuildContext ctx,
    double padding, {
    required Color backgroundColor,
    required Text text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: (MediaQuery.of(ctx).size.width - padding * 2) / 2 - 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: text,
      ),
    );
  }

  Widget _dateOrTimeButton(
    BuildContext ctx,
    int index, {
    required dynamic textValue,
    required bool isStart,
    required bool isDate,
  }) {
    bool isError = false;
    for (final i in errorFields) {
      if (i == index) {
        setState(() => isError = true);
        break;
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: () {
          if (isDate) {
            showDatePicker(
              context: ctx,
              initialDate: DateTime.now(),
              firstDate: DateTime(DateTime.now().year),
              lastDate: DateTime(DateTime.now().year + 14),
              useRootNavigator: true,
              locale: Locale(transl.localeName),
            ).then((date) {
              if (isStart) {
                setState(() => startDate = date!);
              } else {
                setState(() => stopDate = date!);
              }
            });
          } else {
            showTimePicker(
              context: context,
              initialTime: TimeOfDay(
                hour: DateTime.now().hour,
                minute: DateTime.now().minute,
              ),
            ).then((time) {
              if (isStart) {
                setState(() => startTime = time!);
              } else {
                setState(() => stopTime = time!);
              }
            });
          }
        },
        child: Container(
          width: (MediaQuery.of(ctx).size.width - 25 * 2) / 2,
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isError ? errorColor : Theming.whiteTone.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                isDate ? Icons.calendar_month_outlined : Icons.watch_later_outlined,
                color: Theming.primaryColor,
              ),
              const SizedBox(width: 5),
              Text(
                textValue != null
                    ? isDate
                        ? DateFormat.yMd(transl.localeName).format(textValue)
                        : "${textValue.hour < 10 ? "0${textValue.hour}" : textValue.hour}:${textValue.minute < 10 ? "0${textValue.minute}" : textValue.minute}"
                    : isDate
                        ? isStart
                            ? transl.startDate
                            : transl.completionDate
                        : isStart
                            ? transl.startTime
                            : transl.completionTime,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}