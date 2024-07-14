import 'package:icedetector/models/timestamp_record.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'dart:io' as io;
import 'generate_file.dart';



saveExcel(List<TimestampRecord> logs, String title) async {
  var uuid = const Uuid();
  var savedFile = await generateExcel(logs, title);
  final directory = await getDownloadsDirectory();
  final filePath = p.join(
    directory!.path!,
    '$title - ${uuid.v4()}.xlsx'
  );
  final file = io.File(filePath);
  await file.writeAsBytes(savedFile, flush: true);

  OpenFile.open(filePath);
}

// saveExcel(List<TimestampRecord> logs, String title) async {
//   if(await Permission.storage.request().isGranted){
//     var savedFile = await generateExcel(logs, title);
//     const directoryPath = '/storage/emulated/0/IceDetector/files/';
//
//     // Create the directory if it doesn't exist
//     final directory = io.Directory(directoryPath);
//     if (!await directory.exists()) {
//       await directory.create(recursive: true);
//     }
//
//     // Save the file in the directory
//     final filePath = p.join(directoryPath, '$title.xlsx');
//     final file = io.File(filePath);
//     await file.writeAsBytes(savedFile, flush: true);
//
//     print('File saved to: $filePath');
//   }
//
// }