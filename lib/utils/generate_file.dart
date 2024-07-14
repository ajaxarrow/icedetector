import 'dart:convert';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:icedetector/models/timestamp_record.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:http/http.dart' as http;
import 'format_date.dart';


// Future<List<int>> generateExcel(List<TimestampRecord> logs, String title) async {
//   var excel = Excel.createExcel();
//   var sheet = excel['Ice Count Logs Summary'];
//
//   sheet.merge(CellIndex.indexByString("A1"), CellIndex.indexByString("F1"));
//   sheet.cell(CellIndex.indexByString("A1")).value = TextCellValue(title);
//
//   List<String> headers = ['Timestamp Logs', 'Images'];
//   for (int i = 0; i < headers.length; i++) {
//     sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1)).value = TextCellValue(headers[i]);
//   }
//
//   for (int i = 0; i < logs.length; i++) {
//     TimestampRecord log = logs[i];
//     final url = await FirebaseStorage.instance
//         .ref('images/${formatDate(log.timeStart!)} Ice Logs Image.jpg')
//         .getDownloadURL();
//
//     List<String> row = [
//       formatDate(log.timeStart!).toString(),
//       url
//     ];
//
//     for (int j = 0; j < row.length; j++) {
//       sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 2)).value = TextCellValue(row[j]);
//     }
//   }
//
//   // Save the Excel file
//   excel.setDefaultSheet(sheet.sheetName);
//   return excel.encode()!;
// }

Future<List<int>> generateExcel(List<TimestampRecord> logs, String title) async {
  final Workbook workbook = Workbook();
  final Worksheet sheet = workbook.worksheets[0];

  sheet.getRangeByName("A1").setText(title);

  List<String> headers = ['Timestamp Logs', 'Images'];
  for (int i = 0; i < headers.length; i++) {
    sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
  }
  for (int i = 0; i < logs.length; i++) {
    TimestampRecord log = logs[i];
    final url = await FirebaseStorage.instance
        .ref('images/${formatDate(log.timeStart!)} Ice Logs Image.jpg')
        .getDownloadURL();

    final http.Response response = await http.get(Uri.parse(url));
    final Uint8List bytes = response.bodyBytes;

    List<String> row = [
      formatDate(log.timeStart!).toString(),
      url
    ];

    // for (int j = 0; j < row.length; j++) {
    //   sheet.getRangeByIndex(i + 2, j + 1).setText(row[j]);
    // }
    sheet.getRangeByIndex(i + 2, 1).setText(row[0]);
    sheet.pictures.addStream(i + 2, 2, bytes);
  }

  final bytes = workbook.saveAsStream();
  return bytes;
}

