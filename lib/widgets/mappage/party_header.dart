import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/utils/theming.dart';
import '/utils/ext.dart' show openMap;

class PartyHeader extends StatelessWidget {
  final String partyName;
  final String localisation;
  final DateTime startTime;
  final int participantsCount;
  const PartyHeader({
    super.key,
    required this.partyName,
    required this.localisation,
    required this.startTime,
    required this.participantsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 110),
      decoration: const BoxDecoration(
        color: Theming.bgColor,
        boxShadow: [
          BoxShadow(
            color: Theming.bgColor,
            offset: Offset(0, 20),
            spreadRadius: 15,
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            partyName,
            style: Styles.partyHeaderTitle,
            maxLines: 1,
          ),
          GestureDetector(
            onTap: () {
              openMap(lat: 51.40253, lng: 21.14714);
            },
            child: Row(
              children: [
                Text(
                  localisation,
                  style: Styles.partyHeaderLocation,
                ),
                const SizedBox(width: 5),
                Icon(
                  Icons.link_sharp,
                  color: Theming.whiteTone.withOpacity(0.6),
                  size: 18,
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          //Party info (date, time, number of people)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //Date
              Row(
                children: [
                  const Icon(
                    Icons.date_range_outlined,
                    color: Theming.primaryColor,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    DateFormat.yMd().format(startTime),
                    style: Styles.partyHeaderInfo,
                  ),
                ],
              ),

              //Time
              Row(
                children: [
                  const Icon(Icons.timelapse, color: Theming.primaryColor),
                  const SizedBox(width: 5),
                  Text(
                    DateFormat.Hm().format(startTime),
                    style: Styles.partyHeaderInfo,
                  ),
                ],
              ),

              //Number of people participating
              Row(
                children: [
                  const Icon(Icons.group_outlined, color: Theming.primaryColor),
                  const SizedBox(width: 5),
                  Text(
                    participantsCount.toString(),
                    style: Styles.partyHeaderInfo,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
