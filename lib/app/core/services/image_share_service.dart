import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ImageShareService {
  // Base URL for Github Raw images
  static String githubBaseUrl = "https://raw.githubusercontent.com/TaherSalah/shareCardImage/master/"; 

  // Custom Cache Manager for long-term persistence (90 days)
  static final CacheManager customCacheManager = CacheManager(
    Config(
      'shareImagesCache',
      stalePeriod: const Duration(days: 90),
      maxNrOfCacheObjects: 100,
    ),
  );

  // Core images that stay inside the app
  static final List<String> localBackgrounds = [
    "assets/images/beautiful-view-sunset-light.jpg",
    "assets/images/inspiring-view-morning-light.jpg",
    "assets/images/natural-view-night_1112329-37092.jpg",
  ];

  // List of remote image filenames (from 1.webp to 34.webp)
  static final List<String> remoteFilenames = List.generate(34, (i) => "${i + 1}.webp");

  static List<ShareImageItem> getAllBackgrounds() {
    List<ShareImageItem> items = [];
    
    // Add local items
    for (var path in localBackgrounds) {
      items.add(ShareImageItem(path: path, isRemote: false));
    }
    
    // Add remote items if base url is provided
    if (githubBaseUrl.isNotEmpty) {
      for (var filename in remoteFilenames) {
        items.add(ShareImageItem(path: "$githubBaseUrl$filename", isRemote: true));
      }
    }
    
    return items;
  }
  
  static void updateBaseUrl(String url) {
    if (!url.endsWith('/')) {
      githubBaseUrl = '$url/';
    } else {
      githubBaseUrl = url;
    }
  }
}

class ShareImageItem {
  final String path;
  final bool isRemote;

  ShareImageItem({required this.path, required this.isRemote});
  
  ImageProvider getProvider() {
    if (isRemote) {
      return CachedNetworkImageProvider(path);
    } else {
      return AssetImage(path);
    }
  }
}
