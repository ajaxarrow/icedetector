import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:icedetector/models/timestamp_record.dart';
import 'package:icedetector/utils/format_date.dart';
import 'package:intl/intl.dart';

class SummarySnippet extends StatefulWidget {
  const SummarySnippet({super.key});

  @override
  State<SummarySnippet> createState() => _SummarySnippetState();
}

class _SummarySnippetState extends State<SummarySnippet> {
  final _firebaseLogsRef = FirebaseDatabase.instance.ref('logs');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firebaseLogsRef.onValue,
      builder: (context, snap) {
        if (snap.hasData && !snap.hasError && snap.data?.snapshot.value != null) {
          List<TimestampRecord> item = TimestampRecord().processData(snap.data!.snapshot);
          TimestampRecord().filterRecordsByToday(item);
          TimestampRecord().sortRecordsByTimeStart(item);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Ice Count of ${DateFormat.yMMMMd().format(DateTime.now())}: ',
                      style: const TextStyle(
                        fontSize: 16
                      ),
                    ),
                    const Spacer(),
                    Text(
                      item.length.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 5),
                const Text('Recent Logs: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                  )
                ),
                Expanded(child: ListView.builder(
                  itemCount: min(item.length, 3),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Text('Timestamp: ${formatDate(item[index].timeStart!)}'),
                    );
                  },
                ))
              ],
            ),
          );
        }
        else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
