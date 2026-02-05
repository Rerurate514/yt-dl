import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:yt_dl/utils.dart';

class YtDownloader {
  final YoutubeExplode _yt = YoutubeExplode();

  Future<bool> downloadMp3FromYt(String url) async {
    final videoId = VideoId.parseVideoId(url.trim());

    if (videoId == null) {
      debugPrint('[Error] YouTube URLを解析できませんでした: $url');
      return false;
    }

    try {
      final video = await _yt.videos.get(videoId);
      debugPrint('--- Video Details ---');
      debugPrint('ID: ${video.id}');
      debugPrint('Title: ${video.title}');
      debugPrint('Author: ${video.author}');
      debugPrint('Duration: ${video.duration}');
      debugPrint('----------------------');

      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      final audio = manifest.audioOnly.withHighestBitrate();
      
      debugPrint('--- Stream Details ---');
      debugPrint('Codec: ${audio.audioCodec}');
      debugPrint('Container: ${audio.container.name}');
      debugPrint('Bitrate: ${audio.bitrate}');
      debugPrint('Size: ${(audio.size.totalMegaBytes).toStringAsFixed(2)} MB');
      debugPrint('----------------------');

      final audioStream = _yt.videos.streamsClient.get(audio);
      final totalSize = audio.size.totalBytes;
      int downloadedBytes = 0;

      final musicPath = await getMusicPath();
      final directory = Directory(musicPath);
      if (!await directory.exists()) {
        debugPrint('[Info] ディレクトリが存在しないため作成します: ${directory.path}');
        await directory.create(recursive: true);
      }

      final safeTitle = video.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final filePath = join(directory.path, '$safeTitle.mp3');
      debugPrint('[Path] Target: $filePath');

      final file = File(filePath);
      final fileStream = file.openWrite();

      debugPrint("[Process] ダウンロード開始...");

      await for (final data in audioStream) {
        downloadedBytes += data.length;
        
        final ratio = downloadedBytes / totalSize;
        final percent = (ratio * 100).toStringAsFixed(1);
        final barLength = (ratio * 20).toInt();
        final progressBar = '[${'=' * barLength}${' ' * (20 - barLength)}]';
        
        debugPrint('$progressBar $percent% ($downloadedBytes / $totalSize bytes)');
        
        fileStream.add(data);
      }

      await fileStream.flush();
      await fileStream.close();

      debugPrint("[Success] ダウンロード完了: $filePath");
      return true;

    } catch (e, stackTrace) {
      debugPrint("[Critical Error] ${e.toString()}");
      debugPrint("Stack Trace:\n$stackTrace");
      return false;
    }
  }
}
