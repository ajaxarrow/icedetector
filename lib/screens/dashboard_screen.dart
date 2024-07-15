import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:icedetector/models/app_user.dart';
import 'package:icedetector/models/timestamp_record.dart';
import 'package:icedetector/themes/colors.dart';
import 'package:icedetector/widgets/download_schedule_dialog.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String user = 'User';
  final _firebaseLogsRef = FirebaseDatabase.instance.ref('logs');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AppUser().getUserById(FirebaseAuth.instance.currentUser!.uid).then((value){
      setState(() {
        user = value.name!;
      });
    });
  }

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
            padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 20
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Welcome Back, $user!',
                  style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 22
                  ),
                ),
                const Text('What do you want to do today?'),
                const SizedBox(height: 15),
                Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 10,
                  ),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 20
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Total Ice Counts Today',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.length.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 32
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  ElevatedButton(
                                    onPressed: () => showDownloadDialog(item, 'Ice Count Log Summary - ${DateFormat.yMMMMd().format(DateTime.now())}'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: secondaryColor,
                                      foregroundColor: primaryColor
                                    ),
                                    child: const Text('Save today logs'),
                                  )
                                ],
                              ),
                              const Spacer(),
                              Image.asset(
                                'lib/assets/images/data-placeholder.png',
                                height: 80,
                              )
                            ],
                          )
                        ],
                      )
                  ),
                ),
              ],
            ),
          );
        }
        else if (snap.hasError){
          return Center(
            child: Text('Error: ${snap.error}')
          );
        }
        else if (!snap.hasData || snap.data?.snapshot.value == null){
          return const Center(
              child: Text('No Data Found!')
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
