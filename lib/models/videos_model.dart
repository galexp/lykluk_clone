class VideoModel {
  int totalVideos = 0;
  List<Video> videos = [];

  VideoModel();

  VideoModel.fromJson(Map<String, dynamic> jsonMap) {
   
    if (jsonMap != {}) {
      
      if (jsonMap.containsKey("videos")) totalVideos = jsonMap['videos'] != null ? jsonMap['videos'].length: 0;
      
      if (jsonMap.containsKey("videos")) {
        videos =
            jsonMap['videos'] != null ? parseAttributes(jsonMap['videos']) : [];
      }
     
    } else {}
  }

  static List<Video> parseAttributes(jsonData) {
    List list = jsonData;
    List<Video> attrList = list.map((data) => Video.fromJSON(data)).toList();
    return attrList;
  }
}

class Video {
  int videoId = 0;
  String url = "";
  String videoThumbnail = "";
  int userId = 0;
  // String userDP = "";
  // String soundImageUrl = "";
  // String tags = "";
  // int duration = 0;
  
  Video();

  Video.fromJSON(Map<String, dynamic> json) {
    var urli = "https://cdn.lykluk.com/";
    
    videoId = json["video_id"] ?? 0;
    url = json["key"] == null ? '' : urli + json["key"];
    videoThumbnail = json["thumbNail"] == null ? '' : urli + json["thumbNail"];
    userId = json['user_id'] ?? 0;
    // duration = json["duration"] == null ? 0 : json["duration"];
    // tags = json["tags"] == null ? '' : json["tags"];
    // userDP = json['user_dp'] ?? "";
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data =  new Map<String, dynamic>();
    data['videoId'] = this.videoId;
    data['url'] = this.url;
    data['videoThumbnail'] = this.videoThumbnail;
    data['userId'] = this.userId;
    // data['duration'] = this.duration;
    // data['tags'] = this.tags;
    // data['userDP'] = this.userDP;
    // data['soundImageUrl'] = this.soundImageUrl;
    return data;
  }
}
