import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'dart:async';


Future<String> loadImage(String url, String saveName) async {
  var response = await http.get(Uri.parse(url));
  var documentDirectory = await getApplicationDocumentsDirectory();
  var firstPath = "${documentDirectory.path}/images";
  var filePathAndName = '${documentDirectory.path}/images/$saveName';

  await Future<int>.delayed(const Duration(seconds: 2), () => 0);
  await Directory(firstPath).create(recursive: true);

  File file2 = File(filePathAndName);
  var exists = await file2.exists();
  if (!exists) {
    print("**** initial store of image cache $saveName ***");
    file2.writeAsBytesSync(response.bodyBytes);
  }
  else {
    var age = await file2.lastModified();
    var now = DateTime.now();
    if (now.difference(age).inSeconds > 60) {
      print("**** update image cache $saveName ***");
      file2.writeAsBytesSync(response.bodyBytes);
    }
  }
  return filePathAndName;
}
