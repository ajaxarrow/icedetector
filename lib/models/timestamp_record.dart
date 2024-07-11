import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class TimestampRecord{
  TimestampRecord({
    this.timeStart,
    this.timeEnd
  });

  final DateTime? timeStart;
  final DateTime? timeEnd;

  factory TimestampRecord.fromMap(Map<String, dynamic> map) {
    return TimestampRecord(
      timeStart: DateTime.fromMicrosecondsSinceEpoch(map['timestamp_start']  * 1000),
      timeEnd: DateTime.fromMicrosecondsSinceEpoch(map['timestamp_end']  * 1000)
    );
  }

  List<TimestampRecord> processData(DataSnapshot snapshot) {
    List<TimestampRecord> records = [];
    if (snapshot.value != null && snapshot.value is Map) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

      data.forEach((key, value) {
        if (value is Map) {
          records.add(TimestampRecord.fromMap(Map<String, dynamic>.from(value)));
        }
      });
    }
    return records;
  }

  sortRecordsByTimeStart(List<TimestampRecord> records) {
    records.sort((a, b) {
      // Ensure that null values are handled gracefully
      if (a.timeStart == null && b.timeStart == null) return 0;
      if (a.timeStart == null) return 1;
      if (b.timeStart == null) return -1;

      // Sort in descending order (latest to oldest)
      return b.timeStart!.compareTo(a.timeStart!);
    });
  }

  void filterRecordsByToday(List<TimestampRecord> records) {
    DateTime now = DateTime.now();
    records.retainWhere((record) => record.timeStart != null && record.timeStart!.day == now.day);
  }

  Map<String, List<TimestampRecord>> groupByDay(List<TimestampRecord> records) {
    Map<String, List<TimestampRecord>> grouped = {};

    records.forEach((record) {
      String key = DateFormat.yMMMMd().format(record.timeStart!);
      if (grouped[key] == null) {
        grouped[key] = [];
      }
      grouped[key]!.add(record);
    });

    return grouped;
  }

}