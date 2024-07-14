import 'package:flutter/material.dart';
import 'package:icedetector/models/timestamp_record.dart';
import 'package:icedetector/utils/download.dart';

class DownloadScheduleDialog extends StatefulWidget {
  const DownloadScheduleDialog({
    super.key,
    required this.logs,
    required this.title
  });

  final List<TimestampRecord> logs;
  final String title;

  @override
  State<DownloadScheduleDialog> createState() => _DownloadScheduleDialogState();
}

class _DownloadScheduleDialogState extends State<DownloadScheduleDialog> {
  bool isLoading = false;

  saveExcelFile() async {
    setState(() {
      isLoading = true;
    });
    await saveExcel(widget.logs, widget.title);
    setState(() {
      isLoading = false;
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 2),
          content: Text("File Saved!"),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 190,
          width: 150,
          child: isLoading ? const Center(child: CircularProgressIndicator()) : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Text(
                    'Confirm Download',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close_rounded))
                ],
              ),
              const SizedBox(height: 10),
              const Text('Are you sure you want to save the logs as an excel file?'),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffdae2f3),
                            padding: const EdgeInsets.symmetric(vertical: 19)
                        ),
                        onPressed: (){
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                            'Cancel',
                            style: TextStyle(
                                fontSize: 16,
                                color: Color(0xff3b5ba9)
                            )
                        )
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 19)
                        ),
                        onPressed: saveExcelFile,
                        child: const Text(
                            'Save',
                            style: TextStyle(
                                fontSize: 16
                            )
                        )
                    ),
                  )
                ],
              )
            ],
          ),
      )
    );
  }
}
