import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audiotags/audiotags.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../utils/helper.dart';
import '../../widgets/snackbar.dart';

class LocalSongsController extends GetxController {
  final RxList<MediaItem> localSongsList = RxList();
  final isFetched = false.obs;

  static const _hiveBox = 'LocalSongs';

  @override
  void onInit() {
    super.onInit();
    _loadFromHive();
  }

  /// Load previously saved local song paths from Hive
  Future<void> _loadFromHive() async {
    final box = await Hive.openBox(_hiveBox);
    final items = <MediaItem>[];
    for (final key in box.keys) {
      final json = box.get(key);
      if (json is Map) {
        try {
          items.add(_fromJson(Map<String, dynamic>.from(json)));
        } catch (e) {
          printERROR('LocalSongs: corrupt entry $key: $e');
        }
      }
    }
    localSongsList.value = items;
    isFetched.value = true;
  }

  /// Let the user pick audio files from the device
  Future<void> pickAndAddFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return;

    final box = await Hive.openBox(_hiveBox);
    int added = 0;
    for (final file in result.files) {
      if (file.path == null) continue;
      final path = file.path!;
      // Avoid duplicates
      if (localSongsList.any((s) => s.id == path)) continue;
      final item = await _buildMediaItem(path);
      if (item != null) {
        box.put(path, _toJson(item));
        localSongsList.add(item);
        added++;
      }
    }
    if (added > 0 && Get.context != null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        snackbar(Get.context!, 'Added $added local song(s)',
            size: SanckBarSize.MEDIUM),
      );
    }
  }

  /// Remove a local song from the list and Hive
  Future<void> removeSong(MediaItem song) async {
    final box = await Hive.openBox(_hiveBox);
    box.delete(song.id);
    localSongsList.remove(song);
  }

  /// Build a MediaItem from a local file path, reading ID3 tags if available
  Future<MediaItem?> _buildMediaItem(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return null;

      String title = path.split(Platform.pathSeparator).last;
      // Remove extension from title
      if (title.contains('.')) {
        title = title.substring(0, title.lastIndexOf('.'));
      }
      String? artist;
      String? album;
      Uri? artUri;

      try {
        final tag = await AudioTags.read(path);
        if (tag != null) {
          if (tag.title != null && tag.title!.isNotEmpty) title = tag.title!;
          artist = tag.trackArtist;
          album = tag.album;
          // Extract embedded artwork if available
          if (tag.pictures.isNotEmpty) {
            // We'll use a data URI for embedded art — not persisted, just in memory
            // For simplicity, leave artUri null; UI will show music note icon
          }
        }
      } catch (_) {
        // AudioTags read failed — use filename as title
      }

      return MediaItem(
        id: path,
        title: title,
        artist: artist ?? 'Unknown Artist',
        album: album,
        artUri: artUri,
        extras: {
          'url': path,
          'isLocal': true,
          'resultType': 'song',
        },
      );
    } catch (e) {
      printERROR('LocalSongs: could not build MediaItem for $path: $e');
      return null;
    }
  }

  MediaItem _fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String?,
      album: json['album'] as String?,
      playable: true,
      extras: Map<String, dynamic>.from(json['extras'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> _toJson(MediaItem item) {
    return {
      'id': item.id,
      'title': item.title,
      'artist': item.artist,
      'album': item.album,
      'extras': item.extras,
    };
  }
}
