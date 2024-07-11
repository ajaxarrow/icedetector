import 'package:excel/excel.dart';
import 'package:icedetector/models/timestamp_record.dart';

import 'format_date.dart';


Future<List<int>> generateExcel(List<TimestampRecord> logs, String title) async {
  var excel = Excel.createExcel();
  var sheet = excel['Ice Count Logs Summary'];

  sheet.merge(CellIndex.indexByString("A1"), CellIndex.indexByString("F1"));
  sheet.cell(CellIndex.indexByString("A1")).value = TextCellValue(title);

  List<String> headers = ['Timestamp Logs'];
  for (int i = 0; i < headers.length; i++) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1)).value = TextCellValue(headers[i]);
  }

  for (int i = 0; i < logs.length; i++) {
    TimestampRecord log = logs[i];


    List<String> row = [
      formatDate(log.timeStart!).toString()
    ];

    for (int j = 0; j < row.length; j++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 2)).value = TextCellValue(row[j]);
    }
  }

  // Save the Excel file
  excel.setDefaultSheet(sheet.sheetName);
  return excel.encode()!;
}

