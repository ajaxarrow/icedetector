import 'dart:convert';
import 'package:icedetector/models/timestamp_record.dart';
import 'package:web/web.dart' as web;
import 'generate_file.dart';


saveExcel(List<TimestampRecord> logs, String title) async {
  var savedFile = await generateExcel(logs, title);
  List<int> fileInts = List.from(savedFile);
  web.HTMLAnchorElement()
    ..href = "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(fileInts)}"
    ..setAttribute("download", "$title.xlsx")
    ..click();
}