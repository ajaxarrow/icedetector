import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:icedetector/models/timestamp_record.dart';
import 'package:icedetector/utils/format_date.dart';
import 'package:icedetector/widgets/download_schedule_dialog.dart';
import 'package:icedetector/widgets/ice_logs_details_dialog.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _firebaseLogsRef = FirebaseDatabase.instance.ref('logs');


  void showDownloadDialog(List<TimestampRecord> logs, String title) {
    showDialog(
      context: context,
      builder: (ctx) =>
          SimpleDialog(
            children: [
              DownloadScheduleDialog(
                title: title,
                logs: logs,
              )
            ],
          )
    );
  }

  Future<String> getImageUrl(DateTime timestamp) async {
    final url = await FirebaseStorage.instance
        .ref('images/${timestamp.millisecondsSinceEpoch}.jpg')
        .getDownloadURL();
    return url;
  }

  void openIceLogsDetailsDialog(String date, String url){
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))
      ),
      builder: (ctx) => IceLogsDetailsDialog(logDate: date, url: url)
    );
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firebaseLogsRef.onValue,
      builder: (context, snap) {
        if (snap.hasData && !snap.hasError && snap.data?.snapshot.value != null) {
          List<TimestampRecord> item = TimestampRecord().processData(snap.data!.snapshot);
          TimestampRecord().sortRecordsByTimeStart(item);
          Map<String, List<TimestampRecord>> groupedRecords = TimestampRecord().groupByDay(item);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 15),
                const Text(
                  'Reports Summary',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text(
                      'Total Ice Count: ',
                      style: TextStyle(
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
                const SizedBox(height: 10),
                const Text('Daily Breakdown: ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                    )
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: ListView.builder(
                    itemCount: groupedRecords.length,
                    itemBuilder: (context, index) {
                      String dateKey = groupedRecords.keys.elementAt(index);
                      List<TimestampRecord> records = groupedRecords[dateKey]!;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  '$dateKey (Total: ${records.length})',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () => showDownloadDialog(records, 'Ice Count Log Summary - $dateKey'),
                                  child: const Text('Save Excel')
                                )
                              ],
                            ),
                            ExpansionTile(
                              title: const Text('Expand Ice Count Logs'),
                              children: records.map((record) {
                                return FutureBuilder<String>(
                                  future: getImageUrl(record.timeStart!),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return ListTile(
                                        leading: const CircularProgressIndicator(),
                                        title: Text(
                                          'Timestamp: ${formatDate(record.timeStart!)}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      );
                                    } else if (snapshot.hasError) {
                                      return ListTile(
                                        leading: const Icon(Icons.error),
                                        title: Text(
                                          'Timestamp: ${formatDate(record.timeStart!)}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        subtitle: const Text('Error loading image'),
                                      );
                                    } else {
                                      return GestureDetector(
                                        onTap: () => openIceLogsDetailsDialog(formatDate(record.timeStart!), snapshot.data!),
                                        child: ListTile(
                                          leading: Image.network(
                                            snapshot.data!,
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return CircularProgressIndicator(
                                                  value: loadingProgress.expectedTotalBytes != null
                                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                      : null,
                                              );
                                            }
                                          ),
                                          title: Text(
                                            'Timestamp: ${formatDate(record.timeStart!)}',
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                );
                              }).toList(),
                            )
                          ],
                        ),
                      );
                    },
                  )
                ),
                ElevatedButton(
                  onPressed: () => showDownloadDialog(item, 'Ice Count Log General Summary'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24
                    )
                  ),
                  child: const Text('Save General Summary'),
                ),
                const SizedBox(height: 15)
              ],
            ),
          );
        }
        else if (snap.hasError){
          return Center(
              child: Text('Error: ${snap.error}')
          );
        }
        // else if (!snap.hasData || snap.data?.snapshot.value == null){
        //   return const Center(
        //       child: Text('No Data Found!')
        //   );
        // }
        else {
          return const Center(
            child: CircularProgressIndicator()
          );
        }
      },
    );
  }
}
