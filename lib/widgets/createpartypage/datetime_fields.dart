import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '/utils/theming.dart';
import '/utils/locale_support.dart';

class DateTimeField extends StatefulWidget {
  final bool isStart;
  final Function(DateTime) onFinish;
  const DateTimeField({
    required this.isStart,
    required this.onFinish,
    super.key,
  });

  @override
  State<DateTimeField> createState() => _DateTimeFieldState();
}

class _DateTimeFieldState extends State<DateTimeField> {
  late AppLocalizations transl;

  DateTime? date;
  TimeOfDay? time;

  @override
  void initState() {
    super.initState();

    initializeDateFormatting();
  }

  @override
  Widget build(BuildContext context) {
    transl = LocaleSupport.appTranslates(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: GestureDetector(
        onTap: () async {
          if (mounted) {
            final DateTime? selectedDate;
            selectedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(
                DateTime.now().year + 15,
                DateTime.now().month,
                DateTime.now().day,
              ),
            );
            setState(() => date = selectedDate);
          }
          if (mounted) {
            final TimeOfDay? selectedTime;
            selectedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            setState(() => time = selectedTime);
          }
          if (date != null && time != null) {
            widget.onFinish(
              DateTime(
                date!.year,
                date!.month,
                date!.day,
                time!.hour,
                time!.minute,
              ),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15 / 2),
              child: Text(
                widget.isStart
                    ? transl.partyStart.toUpperCase()
                    : transl.partyEnd.toUpperCase(),
                style: TextStyle(
                  color: Theming.whiteTone.withOpacity(0.3),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            AnimatedContainer(
              height: 100,
              width: MediaQuery.of(context).size.width / 2 - 30 * 2,
              duration: const Duration(milliseconds: 300),
              curve: Curves.linearToEaseOut,
              decoration: BoxDecoration(
                color: Theming.whiteTone.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  width: 1.5,
                  color: date != null && time != null
                      ? Theming.primaryColor
                      : Theming.whiteTone.withOpacity(0.2),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      Icon(
                        Icons.date_range_outlined,
                        color: date != null
                            ? Theming.primaryColor
                            : Theming.whiteTone.withOpacity(0.2),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        date != null
                            ? DateFormat.yMd(transl.localeName).format(date!)
                            : transl.partyDate,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: date != null
                              ? Theming.whiteTone
                              : Theming.whiteTone.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 1.5,
                    width: MediaQuery.of(context).size.width / 2 - 30 * 2,
                    color: Theming.whiteTone.withOpacity(0.2),
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      Icon(
                        widget.isStart
                            ? Icons.wb_sunny_outlined
                            : Icons.nights_stay_rounded,
                        color: time != null
                            ? Theming.primaryColor
                            : Theming.whiteTone.withOpacity(0.2),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        time != null
                            ? "${time!.hour}:${time!.minute} "
                            : transl.partyTime,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: time != null
                              ? Theming.whiteTone
                              : Theming.whiteTone.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}