import 'package:icedetector/models/timestamp_record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io' as io;
import 'generate_file.dart';



saveExcel(List<TimestampRecord> logs, String title) async {
  var savedFile = await generateExcel(logs, title);
  final directory = await getDownloadsDirectory();
  final filePath = p.join(
    directory!.path!,
    '$title.xlsx'
  );
  final file = io.File(filePath);
  await file.writeAsBytes(savedFile, flush: true);
}