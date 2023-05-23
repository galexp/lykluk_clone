import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swiper_plus/flutter_swiper_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:like_button/like_button.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:share/share.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../controllers/dashboard_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../models/videos_model.dart';
import '../repositories/settings_repository.dart' as settingRepo;
import '../repositories/video_repository.dart' as videoRepo;
import '../repositories/video_repository.dart';
import '../widgets/VideoPlayer.dart';

class DashboardView extends StatefulWidget {
  DashboardView({Key? key}) : super(key: key);

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends StateMVC<DashboardView>
    with SingleTickerProviderStateMixin, RouteAware {
  DashboardController _con = DashboardController();
  double hgt = 0;
  late AnimationController musicAnimationController;
  DateTime currentBackPressTime = DateTime.now();
  @override
  Future<void> didChangeMetrics() async {
    final bottomInset = WidgetsBinding.instance!.window.viewInsets.bottom;
    final newValue = bottomInset > 0.0;
    if (newValue != videoRepo.homeCon.value.textFieldMoveToUp) {
      setState(() {
        videoRepo.homeCon.value.textFieldMoveToUp = newValue;
      });
    }
  }

  @override
  void initState() {
    // videoRepo.isOnHomePage.value = true;
    // videoRepo.isOnHomePage.notifyListeners();
    _con = videoRepo.homeCon.value;

    _con.scaffoldKey = GlobalKey<ScaffoldState>(debugLabel: "_dashboardPage");
    musicAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    musicAnimationController.repeat();

    _con.getVideos();
    super.initState();
  }

  // waitForSometime() {
  //   Future.delayed(Duration(seconds: 2));
  // }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state.toString() == "AppLifecycleState.paused" ||
        state.toString() == "AppLifecycleState.inactive" ||
        state.toString() == "AppLifecycleState.detached" ||
        state.toString() == "AppLifecycleState.suspending ") {
      if (!videoRepo.homeCon.value.showFollowingPage.value) {
        if (videoRepo.homeCon.value
                .videoController(videoRepo.homeCon.value.swiperIndex) !=
            null) {
          videoRepo.homeCon.value
              .videoController(videoRepo.homeCon.value.swiperIndex)
              .pause();
        }
      } else {
        if (videoRepo.homeCon.value
                .videoController(videoRepo.homeCon.value.swiperIndex2) !=
            null) {
          videoRepo.homeCon.value
              .videoController(videoRepo.homeCon.value.swiperIndex2)
              .pause();
        }
      }
    } else {
      if (!videoRepo.homeCon.value.showFollowingPage.value) {
        _con.playController(videoRepo.homeCon.value.swiperIndex);
      } else {
        _con.playController2(videoRepo.homeCon.value.swiperIndex);
      }
    }
  }

  @override
  dispose() async {
    musicAnimationController.dispose();
    if (!videoRepo.homeCon.value.showFollowingPage.value &&
        videoRepo.homeCon.value
                .videoController(videoRepo.homeCon.value.swiperIndex) !=
            null) {
      if (videoRepo.homeCon.value
              .videoController(videoRepo.homeCon.value.swiperIndex) !=
          null) {
        videoRepo.homeCon.value
            .videoController(videoRepo.homeCon.value.swiperIndex)
            .pause();
      }
    } else if (videoRepo.homeCon.value
            .videoController(videoRepo.homeCon.value.swiperIndex2) !=
        null) {
      videoRepo.homeCon.value
          .videoController(videoRepo.homeCon.value.swiperIndex2)
          .pause();
    }

    if (!videoRepo.firstLoad.value) {
      int count = 0;
      if (videoRepo.homeCon.value.videoControllers.isNotEmpty) {
        videoRepo.homeCon.value.videoControllers.forEach((key, value) async {
          await value!.dispose();
          videoRepo.homeCon.value.videoControllers
              .remove(videoRepo.videosData.value.videos.elementAt(count).url);
          videoRepo.homeCon.value.initializeVideoPlayerFutures
              .remove(videoRepo.videosData.value.videos.elementAt(count).url);
          videoRepo.homeCon.notifyListeners();
          count++;
        });
      }
      int count1 = 0;
      if (videoRepo.homeCon.value.videoControllers2.isNotEmpty) {
        videoRepo.homeCon.value.videoControllers2.forEach((key, value) async {
          await value!.dispose();
          videoRepo.homeCon.value.videoControllers2.remove(
              videoRepo.loadedVideoData.value.videos.elementAt(count1));
          videoRepo.homeCon.value.initializeVideoPlayerFutures2.remove(
              videoRepo.loadedVideoData.value.videos.elementAt(count1));
          count1++;
        });
      }
    } else {
      videoRepo.firstLoad.value = false;
      videoRepo.firstLoad.notifyListeners();
      videoRepo.homeCon.value.playController(0);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: settingRepo.setting.value.bgColor,
    ));
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
          statusBarColor: settingRepo.setting.value.bgColor,
          statusBarIconBrightness: Brightness.light),
    );
    final viewInsets = EdgeInsets.fromWindowPadding(
        WidgetsBinding.instance!.window.viewInsets,
        WidgetsBinding.instance!.window.devicePixelRatio);

    return WillPopScope(
      onWillPop: () {
        DateTime now = DateTime.now();
        if (videoRepo.homeCon.value != null &&
            videoRepo.homeCon.value.pc != null &&
            videoRepo.homeCon.value.pc.isPanelOpen) {
          videoRepo.homeCon.value.pc.close();
          return Future.value(false);
        }
        if (now.difference(currentBackPressTime) > Duration(seconds: 2)) {
          currentBackPressTime = now;
          Fluttertoast.showToast(msg: "Tap again to exit an app.");
          return Future.value(false);
        }
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        return Future.value(true);
      },
      child: Container(
        color: Colors.black12,
        child: Scaffold(
          key: _con.scaffoldKey,
          backgroundColor: settingRepo.setting.value.bgColor,
          body: ValueListenableBuilder(
              valueListenable: _con.isVideoInitialized,
              builder: (context, bool isVideoInitialized, _) {
                return Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: () {
                        if (!videoRepo.homeCon.value.showFollowingPage.value) {
                          if (videoRepo.homeCon.value.videoController(
                                  videoRepo.homeCon.value.swiperIndex) !=
                              null) {
                            videoRepo.homeCon.value
                                .videoController(
                                    videoRepo.homeCon.value.swiperIndex)
                                .pause();
                          }
                        } else {
                          if (videoRepo.homeCon.value.videoController(
                                  videoRepo.homeCon.value.swiperIndex2) !=
                              null) {
                            videoRepo.homeCon.value
                                .videoController(
                                    videoRepo.homeCon.value.swiperIndex2)
                                .pause();
                          }
                        }
                        return _con.getVideos();
                      },
                      child: Container(
                        padding: EdgeInsets.only(
                            bottom: videoRepo.homeCon.value.paddingBottom),
                        child: homeWidget(),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                    )
                  ],
                );
              }),
        ),
      ),
    );
  }

  bool _keyboardVisible = false;
  Widget homeWidget() {
    {
      _keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
      videoRepo.homeCon.value.loadMoreUpdateView.addListener(() {
        if (videoRepo.homeCon.value.loadMoreUpdateView.value) {
          if (mounted) setState(() {});
        }
      });

      Video? videoObj = Video();
      if (!videoRepo.homeCon.value.showFollowingPage.value) {
        videoObj = (videosData.value.videos.isNotEmpty)
            ? videosData.value.videos
                .elementAt(videoRepo.homeCon.value.videoIndex)
            : null;
      } else {
        videoObj = (loadedVideoData.value.videos.isNotEmpty)
            ? loadedVideoData.value.videos
                .elementAt(videoRepo.homeCon.value.videoIndex)
            : videoObj;

        if (videoObj == Video()) {
          videoObj = (videosData.value.videos.isNotEmpty)
              ? videosData.value.videos
                  .elementAt(videoRepo.homeCon.value.videoIndex)
              : null;
        }
      }

      return (videoObj != null)
          ? SlidingUpPanel(
              controller: videoRepo.homeCon.value.pc,
              minHeight: 0,
              backdropEnabled: true,
              color: Colors.black,
              backdropColor: Colors.white,
              padding: const EdgeInsets.only(top: 20, bottom: 0),
              header: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: .5,
                    color: Colors.white,
                  )
                ],
              ),
              maxHeight:
                  config.App(context).appHeight(_keyboardVisible ? 50 : 70),
              onPanelOpened: () async {},
              onPanelClosed: () {
                videoRepo.homeCon.value.textFieldMoveToUp = false;
                FocusScope.of(context).unfocus();
               
                videoRepo.homeCon.notifyListeners();

                videoRepo.homeCon.value.loadMoreUpdateView.value = false;
                videoRepo.homeCon.value.loadMoreUpdateView.notifyListeners();
              },
              panel: Container(),
              body: ValueListenableBuilder(
                  valueListenable: videoRepo.homeCon.value.showFollowingPage,
                  builder: (context, bool show, _) {
                    return !show
                        ? ValueListenableBuilder(
                            valueListenable: videosData,
                            builder: (context, VideoModel video, _) {
                              return Stack(
                                children: <Widget>[
                                  Swiper(
                                    controller:
                                        videoRepo.homeCon.value.swipeController,
                                    loop: false,
                                    index: videoRepo.homeCon.value.swiperIndex,
                                    control: const SwiperControl(
                                      color: Colors.transparent,
                                    ),
                                    onIndexChanged: (index) {
                                      print("onIndexChanged $index");
                                      if (videoRepo.homeCon.value.swiperIndex >
                                          index) {
                                        print("Prev Code");
                                        videoRepo.homeCon.value
                                            .previousVideo(index);
                                      } else {
                                        print("Next Code");
                                        videoRepo.homeCon.value
                                            .nextVideo(index);
                                      }
                                      videoRepo.homeCon.value
                                          .updateSwiperIndex(index);
                                      if (video.videos.length - index == 3) {
                                        videoRepo.homeCon.value
                                            .listenForMoreVideos()
                                            .whenComplete(() => unawaited(
                                                videoRepo.homeCon.value
                                                    .preCacheVideos()));
                                      }
                                    },
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      print("Swiper index $index");
                                      return GestureDetector(
                                          onTap: () {
                                            print("click Played");
                                            setState(() {
                                              _con.onTap = true;
                                              videoRepo.homeCon
                                                  .notifyListeners();
                                              if (_con
                                                  .videoController(
                                                      _con.swiperIndex)
                                                  .value
                                                  .isPlaying) {
                                                _con
                                                    .videoController(
                                                        _con.swiperIndex)
                                                    .pause();
                                              } else {
                                                // If the video is paused, play it.
                                                _con
                                                    .videoController(
                                                        _con.swiperIndex)
                                                    .play();
                                              }
                                            });
                                          },
                                          child: Stack(
                                            fit: StackFit.loose,
                                            children: <Widget>[
                                              Container(
                                                height: MediaQuery.of(context)
                                                    .size
                                                    .height,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Center(
                                                  child: Container(
                                                    color: settingRepo
                                                        .setting.value.bgColor,
                                                    child: VideoPlayerWidget(
                                                        videoRepo.homeCon.value
                                                            .videoController(
                                                                index),
                                                        video.videos
                                                            .elementAt(index),
                                                        videoRepo.homeCon.value
                                                                .initializeVideoPlayerFutures[
                                                            video.videos
                                                                .elementAt(
                                                                    index)
                                                                .url]!),
                                                  ),
                                                ),
                                              ),
                                              (videoRepo.homeCon.value
                                                              .swiperIndex ==
                                                          0 &&
                                                      !videoRepo.homeCon.value
                                                          .initializePage)
                                                  ? SafeArea(
                                                      child: Container(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height /
                                                            4,
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        color:
                                                            Colors.transparent,
                                                      ),
                                                    )
                                                  : Container(),
                                            ],
                                          ));
                                      // }
                                    },
                                    itemCount: video.videos.length,
                                    scrollDirection: Axis.vertical,
                                  ),
                                  Container(
                                      // valueListenable:
                                      //     videoRepo.homeCon.value.userVideoObj,
                                      child: topSection(video)
                                      ),
                                ],
                              );
                            },
                          )
                        : Container();
                  }),
            )
          : Container(
              decoration: const BoxDecoration(color: Colors.black87),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: Center(
                  child: Helper.showLoaderSpinner(
                      settingRepo.setting.value.iconColor!),
                ),
              ),
            );
    }
  }

  Widget topSection(video) {
    return SafeArea(
      child: Container(
        color: Colors.black12,
        height: 60,
        child: Padding(
          padding: const EdgeInsets.only(top: 25.0, bottom: 0),
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    child: ValueListenableBuilder(
                        valueListenable:
                            videoRepo.homeCon.value.showFollowingPage,
                        builder: (context, bool show, _) {
                          return Text(
                            "Featured Vidoes",
                            style: TextStyle(
                              color: settingRepo.setting.value.textColor,
                              fontWeight:
                                  show ? FontWeight.w400 : FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          );
                        }),
                    onTap: () async {
                      _con.getVideos();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
