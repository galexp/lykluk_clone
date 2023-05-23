import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_swiper_plus/flutter_swiper_plus.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:video_player/video_player.dart';

import 'package:lykluk_clone/models/videos_model.dart';
import '../repositories/settings_repository.dart' as settingRepo;
import '../repositories/video_repository.dart' as videoRepo;
import '../services/CacheManager.dart';

class DashboardController extends ControllerMVC {
  bool completeLoaded = false;
  bool textFieldMoveToUp = false;
  DateTime currentBackPressTime = DateTime.now();
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  PanelController pc = new PanelController();
  ValueNotifier<bool> isVideoInitialized = new ValueNotifier(false);
  ValueNotifier<bool> loadMoreUpdateView = new ValueNotifier(false);
  ValueNotifier<bool> showFollowingPage = new ValueNotifier(false);
  ValueNotifier<bool> showHomeLoader = new ValueNotifier(false);
  
  int page = 1;
  
  Map<String, VideoPlayerController?> videoControllers = {};
  Map<String, VideoPlayerController?> videoControllers2 = {};
  Map<String, Future<void>> initializeVideoPlayerFutures = {};
  Map<String, Future<void>> initializeVideoPlayerFutures2 = {};
  
  int videoIndex = 0;
  bool lock = true;
  
  double paddingBottom = 0;
 
  int swiperIndex = 0;
  int swiperIndex2 = 0;
  bool initializePage = true;
  SwiperController swipeController = new SwiperController();
  SwiperController swipeController2 = new SwiperController();
  bool onTap = false;
  
  
  @override
  initState() {
    swiperIndex = 0;
    swiperIndex2 = 0;
    super.initState();
  }

  @override
  dispose() {
    videoControllers.forEach((key, value) async {
      await value!.dispose();
    });
    videoControllers2.forEach((key, value) async {
      await value!.dispose();
    });
    super.dispose();
  }

  updateSwiperIndex(int index) {
    swiperIndex = index;
  }

  updateSwiperIndex2(int index) {
    swiperIndex2 = index;
  }

  onVideoChange(String videoId) {
    videoId = videoId;
  }

  disposeControls(controls) {
    controls.forEach((key, value2) async {
      await value2.dispose();
    });
  }


  initVideos(length) {
    for (int i = 0; i < length; i++) {
      initController(i).whenComplete(() {
        if (i == 0) {
          videoRepo.dataLoaded.value = true;
          videoRepo.homeCon.value.showHomeLoader.value = false;
          videoRepo.homeCon.value.showHomeLoader.notifyListeners();
          videoRepo.dataLoaded.notifyListeners();
          playController(i);
          isVideoInitialized.value = true;
          isVideoInitialized.notifyListeners();
        } else {
          completeLoaded = true;
        }
      });
    }
  }

  Future<void> getVideos() async {
    isVideoInitialized.value = false;
    isVideoInitialized.notifyListeners();
    swiperIndex = 0;
    swiperIndex2 = 0;
    videoRepo.videosData.value.videos = [];
    videoRepo.videosData.notifyListeners();
    initializeVideoPlayerFutures = {};
    initializeVideoPlayerFutures2 = {};
    page = 1;
   
    Map obj = {'userId': 0, 'videoId': 0};

    // if (userVideoObj.value.userId > 0) {
    //   obj['userId'] = userVideoObj.value.userId;
    //   obj['videoId'] = userVideoObj.value.videoId;
    // } else if (userVideoObj.value.videoId > 0) {
    //   obj['videoId'] = userVideoObj.value.videoId;
    // }

    videoRepo.getVideos(page, obj).then((data1) async {
      if (data1 != VideoModel()) {
        if (data1.videos.isNotEmpty) {
          if (data1.videos.isNotEmpty && data1.videos.isNotEmpty) {
            await initVideos(2);
          } else {
            initializeVideoPlayerFutures = {};
            initializeVideoPlayerFutures2 = {};
          }
        } else {
          initializeVideoPlayerFutures = {};
          initializeVideoPlayerFutures2 = {};
        }
      }
    });
  }

  Future<void> listenForMoreVideos() async {
    Map obj = {'userId': 0, 'videoId': 0};
    // if (userVideoObj.value.userId > 0) {
    //   obj['userId'] = userVideoObj.value.userId;
    //   obj['videoId'] = userVideoObj.value.videoId;
    // } else if (userVideoObj.value.videoId > 0) {
    //   obj['videoId'] = userVideoObj.value.videoId;
    // }
    page = page + 1;
    videoRepo.getVideos(page, obj).whenComplete(() {
      loadMoreUpdateView.value = true;
      loadMoreUpdateView.notifyListeners();
    });
  }

  


  videoController(int index) {
    if (videoRepo.videosData.value.videos.isNotEmpty) {
      return videoControllers[
          videoRepo.videosData.value.videos.elementAt(index).url];
    }
  }

  VideoPlayerController videoController2(int index) {
    if (videoRepo.loadedVideoData.value.videos.isNotEmpty) {
      return videoControllers2[
          videoRepo.loadedVideoData.value.videos.elementAt(index).url]!;
    } else {
      return VideoPlayerController.network("dataSource");
    }
  }

  Future<void> initController(int index) async {
    try {
      var controller = await getControllerForVideo(
          videoRepo.videosData.value.videos.elementAt(index).url);
      videoControllers[videoRepo.videosData.value.videos.elementAt(index).url] =
          controller;
      initializeVideoPlayerFutures[videoRepo.videosData.value.videos
          .elementAt(index)
          .url] = controller.initialize();
      controller.setLooping(true);
    } catch (e) {
      print("Init Catch Error: $e");
    }
  }

  Future<VideoPlayerController> getControllerForVideo(String video) async {
    try {
      final fileInfo = await DefaultCacheManager().getFileFromCache(video);
      VideoPlayerController controller;
      double volume = 5;

      if (fileInfo == null || fileInfo.file == null) {
        unawaited(DefaultCacheManager()
            .downloadFile(video)
            .whenComplete(() => print('saved video url $video')));
        controller = VideoPlayerController.network(video);
        controller.setVolume(volume);
        return controller;
      } else {
        controller = VideoPlayerController.file(fileInfo.file);
        controller.setVolume(volume);
        return controller;
      }
    } catch (e) {
      return VideoPlayerController.network("");
    }
  }

  Future<void> initController2(int index) async {
    try {
      var controller = await getControllerForVideo(
          videoRepo.loadedVideoData.value.videos.elementAt(index).url);
      videoControllers2[videoRepo.loadedVideoData.value.videos
          .elementAt(index)
          .url] = controller;
      initializeVideoPlayerFutures2[videoRepo
          .loadedVideoData.value.videos
          .elementAt(index)
          .url] = controller.initialize();
      controller.setLooping(true);
    } catch (e) {
      print("Init Catch Error: $e");
    }
  }

  void removeController(int count) async {
    try {
      await videoController(count)?.dispose();
      videoControllers
          .remove(videoRepo.videosData.value.videos.elementAt(count));
      initializeVideoPlayerFutures
          .remove(videoRepo.videosData.value.videos.elementAt(count));
    } catch (e) {
      print("Catch: $e");
    }
  }

  void removeController2(int count) async {
    try {
      await videoController2(count).dispose();
      videoControllers2.remove(
          videoRepo.loadedVideoData.value.videos.elementAt(count));
      initializeVideoPlayerFutures2.remove(
          videoRepo.loadedVideoData.value.videos.elementAt(count));
    } catch (e) {
      print("Catch: $e");
    }
  }

  void stopController(int index) {
    videoController(index)!.pause();
    print("paused $index");
  }

  void playController(int index) async {
    if (videoRepo.isOnHomePage.value) {
      print(index);
      videoController(index).play();
    }
  }

  void stopController2(int index) {
    videoController2(index).pause();
  }

  void playController2(int index) async {
    if (videoRepo.isOnHomePage.value) {
      videoController2(index).play();
    }
  }

  //Swipe Prev Video
  void previousVideo(ind) async {
    if (ind < 0) {
      return;
    }
    lock = true;
    stopController(ind + 1);

    if (ind + 2 < videoRepo.videosData.value.videos.length) {
      removeController(ind + 2);
    }
    playController(ind);
    if (ind == 0) {
      lock = false;
    } else {
      initController(ind - 1).whenComplete(() => lock = false);
    }
  }

  void previousVideo2(ind) async {
    if (ind < 0) {
      return;
    }
    lock = true;
    stopController2(ind + 1);

    if (ind + 2 < videoRepo.loadedVideoData.value.videos.length) {
      removeController2(ind + 2);
    }

    playController2(ind);

    if (ind == 0) {
      lock = false;
    } else {
      initController2(ind - 1).whenComplete(() => lock = false);
    }
  }

  //Swipe Next Video
  void nextVideo(ind) async {
    if (ind > videoRepo.videosData.value.videos.length - 1) {
      return;
    }
    lock = true;
    stopController(ind - 1);
    if (ind - 2 >= 0) {
      removeController(ind - 2);
    }
    playController(ind);
    if (ind == videoRepo.videosData.value.videos.length - 1) {
      lock = false;
    } else {
      initController(ind + 1).whenComplete(() => lock = false);
    }
  }

  void nextVideo2(ind) async {
    if (ind > videoRepo.loadedVideoData.value.videos.length - 1) {
      return;
    }
    lock = true;
    stopController2(ind - 1);
    if (ind - 2 >= 0) {
      removeController2(ind - 2);
    }
    playController2(ind);
    if (ind != videoRepo.loadedVideoData.value.videos.length - 1) {
      initController2(ind + 1);
    }
  }

  Future<void> preCacheVideos() {
    for (final e in videoRepo.videosData.value.videos) {
      Video video = e;
      try {
        CustomCacheManager.instance.downloadFile(video.url);
      } catch (e) {
        print(e.toString() + "Cache Errors");
      }
    }
    return Future.value();
  }
}
