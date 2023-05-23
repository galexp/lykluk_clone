import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../controllers/dashboard_controller.dart';
import '../helpers/helper.dart';
import '../models/videos_model.dart';

ValueNotifier<DashboardController> homeCon =
    new ValueNotifier(DashboardController());
ValueNotifier<bool> dataLoaded = new ValueNotifier(false);
ValueNotifier<bool> firstLoad = new ValueNotifier(true);
ValueNotifier<VideoModel> videosData = new ValueNotifier(VideoModel());
ValueNotifier<VideoModel> loadedVideoData =
    new ValueNotifier(VideoModel());
ValueNotifier<bool> isOnHomePage = new ValueNotifier(true);


Future<VideoModel> getVideos(page, [obj]) async {
  Uri uri = Helper.getUri('testapi');
  uri = uri.replace(queryParameters: {
    "page_size": '10',
    "page": page.toString(),
    "user_id": '0',
    "video_id": '0'
  });

  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
     

      var listItems = jsonData['data'];
        videosData.value =
            VideoModel.fromJson(listItems);
      
      videosData.notifyListeners();
      return videosData.value;
    } else {
      
      return VideoModel.fromJson({});
    }
  } catch (e) {
    return VideoModel.fromJson({});
  }
}
