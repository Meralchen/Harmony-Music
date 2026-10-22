import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../player/player_controller.dart';
import 'local_songs_controller.dart';

class LocalSongsScreen extends StatelessWidget {
  const LocalSongsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<LocalSongsController>()) {
      Get.lazyPut<LocalSongsController>(() => LocalSongsController());
    }
    final controller = Get.find<LocalSongsController>();
    final playerController = Get.find<PlayerController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Music'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add audio files',
            onPressed: controller.pickAndAddFiles,
          ),
        ],
      ),
      body: Obx(() {
        if (!controller.isFetched.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.localSongsList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.music_off,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(80),
                ),
                const SizedBox(height: 16),
                Text(
                  'No local songs added',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to add audio files from your device',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha(160),
                      ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Browse Files'),
                  onPressed: controller.pickAndAddFiles,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 120),
          itemCount: controller.localSongsList.length,
          itemBuilder: (context, index) {
            final song = controller.localSongsList[index];
            return _LocalSongTile(
              song: song,
              onTap: () => _playSong(playerController, controller, index),
              onDelete: () => controller.removeSong(song),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.pickAndAddFiles,
        tooltip: 'Add audio files',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _playSong(
    PlayerController playerController,
    LocalSongsController controller,
    int index,
  ) {
    final songs = controller.localSongsList.toList();
    final song = songs[index];
    playerController.playLocalSong(song, songs);
  }
}

class _LocalSongTile extends StatelessWidget {
  final MediaItem song;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _LocalSongTile({
    required this.song,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          Icons.audio_file,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artist ?? 'Unknown Artist',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        tooltip: 'Remove from list',
        onPressed: onDelete,
      ),
      onTap: onTap,
    );
  }
}
