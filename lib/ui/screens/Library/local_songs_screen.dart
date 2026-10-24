import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../player/player_controller.dart';
import '../../widgets/image_widget.dart';
import 'local_songs_controller.dart';

class LocalSongsScreen extends StatelessWidget {
  const LocalSongsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Music'),
      ),
      body: const LocalSongsView(),
    );
  }
}

class LocalSongsView extends StatelessWidget {
  const LocalSongsView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<LocalSongsController>()) {
      Get.lazyPut<LocalSongsController>(() => LocalSongsController());
    }
    final controller = Get.find<LocalSongsController>();
    final playerController = Get.find<PlayerController>();

    return Column(
      children: [
        // Search bar or Selection Action Bar
        Obx(() {
          if (controller.isSelectionMode.value) {
            final allSelected = controller.selectedSongIds.length ==
                    controller.filteredSongsList.length &&
                controller.filteredSongsList.isNotEmpty;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    tooltip: 'Cancel selection',
                    onPressed: controller.clearSelection,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${controller.selectedSongIds.length} selected',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      allSelected ? Icons.deselect : Icons.select_all,
                      size: 20,
                    ),
                    tooltip: allSelected ? 'Deselect all' : 'Select all',
                    onPressed: () {
                      if (allSelected) {
                        controller.clearSelection();
                      } else {
                        controller.selectAll();
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.redAccent, size: 20),
                    tooltip: 'Remove selected',
                    onPressed: () => _confirmBatchDelete(context, controller),
                  ),
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: TextField(
                      controller: controller.searchController,
                      onChanged: controller.onSearch,
                      decoration: InputDecoration(
                        hintText: 'Search local songs...',
                        hintStyle:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withAlpha(128),
                                ),
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: Obx(
                          () => controller.searchQuery.value.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: controller.clearSearch,
                                )
                              : const SizedBox.shrink(),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 12),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.secondary,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: 'Add folder',
                  icon: const Icon(Icons.create_new_folder, size: 20),
                  onPressed: controller.pickAndAddFolder,
                ),
                const SizedBox(width: 6),
                IconButton.filledTonal(
                  tooltip: 'Add files',
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: controller.pickAndAddFiles,
                ),
              ],
            ),
          );
        }),

        // Scanning progress bar
        Obx(
          () => controller.isScanning.value
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: LinearProgressIndicator(),
                )
              : const SizedBox.shrink(),
        ),

        // Count header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => Text(
                  '${controller.filteredSongsList.length} local song${controller.filteredSongsList.length == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withAlpha(180),
                      ),
                ),
              ),
            ],
          ),
        ),

        // Content List
        Expanded(
          child: Obx(() {
            if (!controller.isFetched.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.localSongsList.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_open,
                        size: 64,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha(80),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No local songs added',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add a music folder to play your local tracks with lyrics and album art',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withAlpha(160),
                            ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        icon: const Icon(Icons.create_new_folder),
                        label: const Text('Add Music Folder'),
                        onPressed: controller.pickAndAddFolder,
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        icon: const Icon(Icons.audio_file),
                        label: const Text('Add Individual Files'),
                        onPressed: controller.pickAndAddFiles,
                      ),
                    ],
                  ),
                ),
              );
            }

            if (controller.filteredSongsList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No songs match "${controller.searchQuery.value}"',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: controller.clearSearch,
                      child: const Text('Clear search'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(top: 4, bottom: 120),
              itemCount: controller.filteredSongsList.length,
              itemBuilder: (context, index) {
                final song = controller.filteredSongsList[index];
                return Obx(() {
                  final isSelected =
                      controller.selectedSongIds.contains(song.id);
                  final isSelectionMode = controller.isSelectionMode.value;
                  return _LocalSongTile(
                    song: song,
                    isSelected: isSelected,
                    isSelectionMode: isSelectionMode,
                    onTap: () {
                      if (isSelectionMode) {
                        controller.toggleSelection(song.id);
                      } else {
                        playerController.playLocalSong(
                            song, controller.filteredSongsList.toList());
                      }
                    },
                    onLongPress: () {
                      if (!isSelectionMode) {
                        controller.enterSelectionMode(song.id);
                      } else {
                        controller.toggleSelection(song.id);
                      }
                    },
                    onDelete: () => controller.removeSong(song),
                  );
                });
              },
            );
          }),
        ),
      ],
    );
  }

  void _confirmBatchDelete(
      BuildContext context, LocalSongsController controller) {
    final count = controller.selectedSongIds.length;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Remove from Local Music'),
        content: Text(
          'Remove $count selected song${count == 1 ? '' : 's'} from your local music list?\n\n(Audio files on your device will remain intact.)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              controller.removeSelectedSongs();
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

class _LocalSongTile extends StatelessWidget {
  final MediaItem song;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDelete;

  const _LocalSongTile({
    required this.song,
    this.isSelected = false,
    this.isSelectionMode = false,
    required this.onTap,
    required this.onLongPress,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: isSelected,
      selectedTileColor: Theme.of(context).colorScheme.primary.withAlpha(25),
      leading: isSelectionMode
          ? Checkbox(
              value: isSelected,
              onChanged: (_) => onTap(),
              activeColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            )
          : ImageWidget(
              song: song,
              size: 48,
            ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        song.artist ?? 'Unknown Artist',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withAlpha(180),
            ),
      ),
      trailing: isSelectionMode
          ? null
          : PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'play') {
                  onTap();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'play',
                  child: Row(
                    children: [
                      Icon(Icons.play_arrow, size: 20),
                      SizedBox(width: 8),
                      Text('Play'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 20),
                      SizedBox(width: 8),
                      Text('Remove from local'),
                    ],
                  ),
                ),
              ],
            ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
