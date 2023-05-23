import 'package:flutter/material.dart';

class Helper {
  late BuildContext context;
  DateTime currentBackPressTime = DateTime.now();

 

  static showLoaderSpinner(Color color) {
    return Center(
      child:  Container(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor:  AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }

 
  static Uri getUri(String path) {
    String baseUrl = "http://35.177.177.128:8001/video/";
    String _path = Uri.parse(baseUrl).path;
    if (!_path.endsWith('/')) {
      _path += '/';
    }
   Uri uri = Uri(
        scheme: Uri.parse(baseUrl).scheme,
        host: Uri.parse(baseUrl).host,
        port: Uri.parse(baseUrl).port,
        path: _path + path);
    
    return uri;
  }


  static Color? getColor(String colorCode) {
    colorCode = colorCode.replaceAll("#", "");

    try {
      if (colorCode.length == 6) {
        return Color(int.parse("0xFF$colorCode"));
      } else if (colorCode.length == 8) {
        return Color(int.parse("0x$colorCode"));
      } else {
        return const Color(0xFFCCCCCC).withOpacity(1);
      }
    } catch (e) {
      print("printColor error $e");
      return const Color(0xFFCCCCCC).withOpacity(1);
    }
  }

 
}
