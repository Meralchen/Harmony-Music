import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/utils/helper.dart';
import 'package:harmonymusic/utils/lang_mapping.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/app_constants.dart';
import '../../widgets/common_dialog_widget.dart';
import '../../widgets/cust_switch.dart';
import '../../widgets/export_file_dialog.dart';
import '../../widgets/backup_dialog.dart';
import '../../widgets/new_version_dialog.dart';
import '../../widgets/restore_dialog.dart';
import '../Library/library_controller.dart';
import '../../widgets/snackbar.dart';
import '/ui/widgets/link_piped.dart';
import '/services/music_service.dart';
import '/ui/player/player_controller.dart';
import '/ui/utils/theme_controller.dart';
import 'components/custom_expansion_tile.dart';
import 'settings_screen_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, this.isBottomNavActive = false});
  final bool isBottomNavActive;

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsScreenController>();
    final topPadding = context.isLandscape ? 50.0 : 90.0;
    final isDesktop = GetPlatform.isDesktop;
    return Padding(
      padding: isBottomNavActive
          ? EdgeInsets.only(left: 20, top: topPadding, right: 15)
          : EdgeInsets.only(top: topPadding, left: 5, right: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "settings".tr,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
              child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 200, top: 20),
            children: [
              Obx(
                () => settingsController.isNewVersionAvailable.value
                    ? Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, right: 10, bottom: 8.0),
                        child: Material(
                          type: MaterialType.transparency,
                          child: ListTile(
                            onTap: () {
                              final url = settingsController
                                      .releaseUrl.value.isNotEmpty
                                  ? settingsController.releaseUrl.value
                                  : appReleasesUrl;
                              launchUrl(
                                Uri.parse(url),
                                mode: LaunchMode.externalApplication,
                              );
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            tileColor: Theme.of(context).colorScheme.secondary,
                            contentPadding:
                                const EdgeInsets.only(left: 8, right: 10),
                            leading:
                                const CircleAvatar(child: Icon(Icons.download)),
                            title: Text(
                              settingsController
                                      .latestVersion.value.isNotEmpty
                                  ? "${"newVersionAvailable".tr} (${settingsController.latestVersion.value})"
                                  : "newVersionAvailable".tr,
                            ),
                            visualDensity: const VisualDensity(horizontal: -2),
                            subtitle: Text(
                              "goToDownloadPage".tr,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color: Colors.white70, fontSize: 13),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              CustomExpansionTile(
                title: "personalisation".tr,
                icon: Icons.palette,
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.only(left: 5, right: 10),
                    title: Text("themeMode".tr),
                    subtitle: Obx(
                      () => Text(
                          settingsController.themeModetype.value ==
                                  ThemeType.dynamic
                              ? "dynamic".tr
                              : settingsController.themeModetype.value ==
                                      ThemeType.system
                                  ? "systemDefault".tr
                                  : settingsController.themeModetype.value ==
                                          ThemeType.dark
                                      ? "dark".tr
                                      : "light".tr,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => const ThemeSelectorDialog(),
                    ),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.only(left: 5, right: 10),
                    title: Text("language".tr),
                    subtitle: Text("languageDes".tr,
                        style: Theme.of(context).textTheme.bodyMedium),
                    trailing: Obx(
                      () => DropdownButton(
                        menuMaxHeight: Get.height - 250,
                        dropdownColor: Theme.of(context).cardColor,
                        underline: const SizedBox.shrink(),
                        style: Theme.of(context).textTheme.titleSmall,
                        value: settingsController.currentAppLanguageCode.value,
                        items: langMap.entries
                            .map((lang) => DropdownMenuItem(
                                  value: lang.key,
                                  child: Text(lang.value),
                                ))
                            .whereType<DropdownMenuItem<String>>()
                            .toList(),
                        selectedItemBuilder: (context) =>
                            langMap.entries.map<Widget>((item) {
                          return Container(
                            alignment: Alignment.centerRight,
                            constraints: const BoxConstraints(minWidth: 50),
                            child: Text(
                              item.value,
                            ),
                          );
                        }).toList(),
                        onChanged: settingsController.setAppLanguage,
                      ),
                    ),
                  ),
                  if (!isDesktop)
                    ListTile(
                      contentPadding: const EdgeInsets.only(left: 5, right: 10),
                      title: Text("playerUi".tr),
                      subtitle: Text("playerUiDes".tr,
                          style: Theme.of(context).textTheme.bodyMedium),
                      trailing: Obx(
                        () => DropdownButton(
                          dropdownColor: Theme.of(context).cardColor,
                          underline: const SizedBox.shrink(),
                          value: settingsController.playerUi.value,
                          items: [
                            DropdownMenuItem(
                                value: 0, child: Text("standard".tr)),
                            DropdownMenuItem(
                              value: 1,
                              child: Text("gesture".tr),
                            ),
                          ],
                          onChanged: settingsController.setPlayerUi,
                        ),
                      ),
                    ),
                  if (!isDesktop)
                    ListTile(
                        contentPadding:
                            const EdgeInsets.only(left: 5, right: 10),
                        title: Text("enableBottomNav".tr),
                        subtitle: Text("enableBottomNavDes".tr,
                            style: Theme.of(context).textTheme.bodyMedium),
                        trailing: Obx(
                          () => CustSwitch(
                              value: settingsController
                                  .isBottomNavBarEnabled.isTrue,
                              onChanged: settingsController.enableBottomNavBar),
                        )),
                  ListTile(
                      contentPadding: const EdgeInsets.only(left: 5, right: 10),
                      title: Text("disableTransitionAnimation".tr),
                      subtitle: Text("disableTransitionAnimationDes".tr,
                          style: Theme.of(context).textTheme.bodyMedium),
                      trailing: Obx(
                        () => CustSwitch(
                            value: settingsController
                                .isTransitionAnimationDisabled.isTrue,
                            onChanged:
                                settingsController.disableTransitionAnimation),
                      )),
                  ListTile(
                      contentPadding: const EdgeInsets.only(left: 5, right: 10),
                      title: Text("enableSlidableAction".tr),
                      subtitle: Text("enableSlidableActionDes".tr,
                          style: Theme.of(context).textTheme.bodyMedium),
                      trailing: Obx(
                        () => CustSwitch(
                            value:
                                settingsController.slidableActionEnabled.isTrue,
                            onChanged: settingsController.toggleSlidableAction),
                      )),
                ],
              ),
              CustomExpansionTile(
                  title: "content".tr,
                  icon: Icons.music_video,
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.only(left: 5, right: 10),
                      title: Text("setDiscoverContent".tr),
                      subtitle: Obx(() => Text(
                          settingsController.discoverContentType.value == "QP"
                              ? "quickpicks".tr
                              : settingsController.discoverContentType.value ==
                                      "TMV"
                                  ? "topmusicvideos".tr
                                  : settingsController
                                              .discoverContentType.value ==
                                          "TR"
                                      ? "trending".tr
                                      : "basedOnLast".tr,
                          style: Theme.of(context).textTheme.bodyMedium)),
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) =>
                            const DiscoverContentSelectorDialog(),
                      ),
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.only(left: 5, right: 10),
                      title: Text("homeContentCount".tr),
                      subtitle: Text("homeContentCountDes".tr,
                          style: Theme.of(context).textTheme.bodyMedium),
                      trailing: Obx(
                        () => DropdownButton(
                          dropdownColor: Theme.of(context).cardColor,
                          underline: const SizedBox.shrink(),
                          value: settingsController.noOfHomeScreenContent.value,
                          items: ([3, 5, 7, 9, 11])
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text("$e")))
                              .toList(),
                          onChanged: settingsController.setContentNumber,
                        ),
                      ),
                    ),
                    ListTile(
                        contentPadding:
                            const EdgeInsets.only(left: 5, right: 10),
                        title: Text("cacheHomeScreenData".tr),
                        subtitle: Text("cacheHomeScreenDataDes".tr,
                            style: Theme.of(context).textTheme.bodyMedium),
                        trailing: Obx(
                          () => CustSwitch(
                              value:
                                  settingsController.cacheHomeScreenData.value,
                              onChanged:
                                  settingsController.toggleCacheHomeScreenData),
                        )),
                    ListTile(
                      contentPadding:
                          const EdgeInsets.only(left: 5, right: 10, top: 0),
                      title: Text("Piped".tr),
                      subtitle: Text("linkPipedDes".tr,
                          style: Theme.of(context).textTheme.bodyMedium),
                      trailing: TextButton(
                          child: Obx(() => Text(
                                settingsController.isLinkedWithPiped.value
                                    ? "unLink".tr
                                    : "link".tr,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(fontSize: 15),
                              )),
                          onPressed: () {
                            if (settingsController.isLinkedWithPiped.isFalse) {
                              showDialog(
                                context: context,
                                builder: (context) => const LinkPiped(),
                              ).whenComplete(
                                  () => Get.delete<PipedLinkedController>());
                            } else {
                              settingsController.unlinkPiped();
                            }
                          }),
                    ),
                    Obx(() => (settingsController.isLinkedWithPiped.isTrue)
                        ? ListTile(
                            contentPadding: const EdgeInsets.only(
                                left: 5, right: 10, top: 0),
                            title: Text("resetblacklistedplaylist".tr),
                            subtitle: Text("resetblacklistedplaylistDes".tr,
                                style: Theme.of(context).textTheme.bodyMedium),
                            trailing: TextButton(
                                child: Text(
                                  "reset".tr,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(fontSize: 15),
                                ),
                                onPressed: () async {
                                  await Get.find<LibraryPlaylistsController>()
                                      .resetBlacklistedPlaylist();
                                  ScaffoldMessenger.of(Get.context!)
                                      .showSnackBar(snackbar(Get.context!,
                                          "blacklistPlstResetAlert".tr,
                                          size: SanckBarSize.MEDIUM));
                                }),
                          )
                        : const SizedBox.shrink()),
                    ListTile(
                      contentPadding: const EdgeInsets.only(left: 5, right: 10),
                      title: Text("clearImgCache".tr),
                      subtitle: Text(
                        "clearImgCacheDes".tr,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      isThreeLine: true,
                      onTap: () {
                        settingsController.clearImagesCache().then((value) =>
                            ScaffoldMessenger.of(Get.context!).showSnackBar(
                                snackbar(Get.context!, "clearImgCacheAlert".tr,
                                    size: SanckBarSize.BIG)));
                      },
                    ),
                  ]),
              CustomExpansionTile(
                title: "music&Playback".tr,
                icon: Icons.music_note,
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.only(left: 5, right: 10),
                    title: Text("streamingQuality".tr),
                    subtitle: Text("streamingQualityDes".tr,
                        style: Theme.of(context).textTheme.bodyMedium),
                    trailing: Obx(
                      () => DropdownButton(
                        dropdownColor: Theme.of(context).cardColor,
                        underline: const SizedBox.shrink(),
                        value: settingsController.streamingQuality.value,
                        items: [
                          DropdownMenuItem(
                              value: AudioQuality.Low, child: Text("low".tr)),
                          DropdownMenuItem(
                            value: AudioQuality.High,
                            child: Text("high".tr),
                          ),
                        ],
                        onChanged: settingsController.setStreamingQuality,
                      ),
                    ),
                  ),
                  if (GetPlatform.isAndroid)
                    ListTile(
                        contentPadding:
                            const EdgeInsets.only(left: 5, right: 10),
                        title: Text("loudnessNormalization".tr),
                        subtitle: Text("loudnessNormalizationDes".tr,
                            style: Theme.of(context).textTheme.bodyMedium),
                        trailing: Obx(
                          () => CustSwitch(
                              value: settingsController
                                  .loudnessNormalizationEnabled.value,
                              onChanged: settingsController
                                  .toggleLoudnessNormalization),
                        )),
                  if (!isDesktop)
                    ListTile(
                        contentPadding:
                            const EdgeInsets.only(left: 5, right: 10),
                        title: Text("cacheSongs".tr),
                        subtitle: Text("cacheSongsDes".tr,
                            style: Theme.of(context).textTheme.bodyMedium),
                        trailing: Obx(
                          () => CustSwitch(
                              value: settingsController.cacheSongs.value,
                              onChanged:
                                  settingsController.toggleCachingSongsValue),
                        )),
                  if (!isDesktop)
                    ListTile(
                        contentPadding:
                            const EdgeInsets.only(left: 5, right: 10),
                        title: Text("skipSilence".tr),
                        subtitle: Text("skipSilenceDes".tr,
                            style: Theme.of(context).textTheme.bodyMedium),
                        trailing: Obx(
                          () => CustSwitch(
                              value:
                                  settingsController.skipSilenceEnabled.value,
                              onChanged: settingsController.toggleSkipSilence),
                        )),
                  if (isDesktop)
                    ListTile(
                        contentPadding:
                            const EdgeInsets.only(left: 5, right: 10),
                        title: Text("backgroundPlay".tr),
                        subtitle: Text("backgroundPlayDes".tr,
                            style: Theme.of(context).textTheme.bodyMedium),
                        trailing: Obx(
                          () => CustSwitch(
                              value: settingsController
                                  .backgroundPlayEnabled.value,
                              onChanged:
                                  settingsController.toggleBackgroundPlay),
                        )),
                  ListTile(
                      contentPadding: const EdgeInsets.only(left: 5, right: 10),
                      title: Text("keepScreenOnWhilePlaying".tr),
                      subtitle: Text("keepScreenOnWhilePlayingDes".tr,
                          style: Theme.of(context).textTheme.bodyMedium),
                      trailing: Obx(
                        () => CustSwitch(
                            value: settingsController.keepScreenAwake.value,
                            onChanged:
                                settingsController.toggleKeepScreenAwake),
                      )),
                  ListTile(
                      contentPadding: const EdgeInsets.only(left: 5, right: 10),
                      title: Text("restoreLastPlaybackSession".tr),
                      subtitle: Text("restoreLastPlaybackSessionDes".tr,
                          style: Theme.of(context).textTheme.bodyMedium),
                      trailing: Obx(
                        () => CustSwitch(
                            value:
                                settingsController.restorePlaybackSession.value,
                            onChanged: settingsController
                                .toggleRestorePlaybackSession),
                      )),
                  ListTile(
                    contentPadding: const EdgeInsets.only(left: 5, right: 10),
                    title: Text("autoOpenPlayer".tr),
                    subtitle: Text("autoOpenPlayerDes".tr,
                        style: Theme.of(context).textTheme.bodyMedium),
                    trailing: Obx(
                      () => CustSwitch(
                          value: settingsController.autoOpenPlayer.value,
                          onChanged: settingsController.toggleAutoOpenPlayer),
                    ),
                  ),
                  if (!isDesktop)
                    ListTile(
                      contentPadding:
                          const EdgeInsets.only(left: 5, right: 10, top: 0),
                      title: Text("equalizer".tr),
                      subtitle: Text("equalizerDes".tr,
                          style: Theme.of(context).textTheme.bodyMedium),
                      onTap: () async {
                        try {
                          await Get.find<PlayerController>().openEqualizer();
                        } catch (e) {
                          printERROR(e);
                        }
                      },
                    ),
                  if (!isDesktop)
                    ListTile(
                      contentPadding: const EdgeInsets.only(left: 5, right: 10),
                      title: Text("stopMusicOnTaskClear".tr),
                      subtitle: Text("stopMusicOnTaskClearDes".tr,
                          style: Theme.of(context).textTheme.bodyMedium),
                      trailing: Obx(
                        () => CustSwitch(
                            value: settingsController
                                .stopPlyabackOnSwipeAway.value,
                            onChanged: settingsController
                                .toggleStopPlyabackOnSwipeAway),
                      ),
                    ),
                  GetPlatform.isAndroid
                      ? Obx(
                          () => ListTile(
                            contentPadding:
                                const EdgeInsets.only(left: 5, right: 10),
                            title: Text("ignoreBatOpt".tr),
                            onTap: settingsController
                                    .isIgnoringBatteryOptimizations.isFalse
                                ? settingsController
                                    .enableIgnoringBatteryOptimizations
                                : null,
                            subtitle: Obx(() => RichText(
                                  text: TextSpan(
                                    text:
                                        "${"status".tr}: ${settingsController.isIgnoringBatteryOptimizations.isTrue ? "enabled".tr : "disabled".tr}\n",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(fontWeight: FontWeight.bold),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: "ignoreBatOptDes".tr,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium),
                                    ],
                                  ),
                                )),
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
              CustomExpansionTile(
                title: "download".tr,
                icon: Icons.download,
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.only(left: 5, right: 10),
                    title: Text("autoDownFavSong".tr),
                    subtitle: Text("autoDownFavSongDes".tr,
                        style: Theme.of(context).textTheme.bodyMedium),
                    trailing: Obx(
                      () => CustSwitch(
                          value: settingsController
                              .autoDownloadFavoriteSongEnabled.value,
                          onChanged: settingsController
                              .toggleAutoDownloadFavoriteSong),
                    ),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.only(left: 5, right: 10),
                    title: Text("downloadingFormat".tr),
                    subtitle: Text("downloadingFormatDes".tr,
                        style: Theme.of(context).textTheme.bodyMedium),
                    trailing: Obx(
                      () => DropdownButton(
                        dropdownColor: Theme.of(context).cardColor,
                        underline: const SizedBox.shrink(),
                        value: settingsController.downloadingFormat.value,
                        items: const [
                          DropdownMenuItem(
                              value: "opus", child: Text("Opus/Ogg")),
                          DropdownMenuItem(
                            value: "m4a",
                            child: Text("M4a"),
                          ),
                        ],
                        onChanged: settingsController.changeDownloadingFormat,
                      ),
                    ),
                  ),
                  ListTile(
                    trailing: TextButton(
                      child: Text(
                        "reset".tr,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(fontSize: 15),
                      ),
                      onPressed: () {
                        settingsController.resetDownloadLocation();
                      },
                    ),
                    contentPadding:
                        const EdgeInsets.only(left: 5, right: 10, top: 0),
                    title: Text("downloadLocation".tr),
                    subtitle: Obx(() => Text(
                        settingsController.isCurrentPathsupportDownDir
                            ? "In App storage directory"
                            : settingsController.downloadLocationPath.value,
                        style: Theme.of(context).textTheme.bodyMedium)),
                    onTap: () async {
                      settingsController.setDownloadLocation();
                    },
                  ),
                  if (GetPlatform.isAndroid)
                    ListTile(
                      contentPadding: const EdgeInsets.only(left: 5, right: 10),
                      title: Text("exportDowloadedFiles".tr),
                      subtitle: Text(
                        "exportDowloadedFilesDes".tr,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      isThreeLine: true,
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) => const ExportFileDialog(),
                      ).whenComplete(
                          () => Get.delete<ExportFileDialogController>()),
                    ),
                  if (GetPlatform.isAndroid)
                    ListTile(
                      contentPadding:
                          const EdgeInsets.only(left: 5, right: 10, top: 0),
                      title: Text("exportedFileLocation".tr),
                      subtitle: Obx(() => Text(
                          settingsController.exportLocationPath.value,
                          style: Theme.of(context).textTheme.bodyMedium)),
                      onTap: () async {
                        settingsController.setExportedLocation();
                      },
                    ),
                ],
              ),
              CustomExpansionTile(
                  title: "${"backup".tr} & ${"restore".tr}",
                  icon: Icons.restore,
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.only(left: 5, right: 10),
                      title: Text("backupAppData".tr),
                      subtitle: Text(
                        "backupSettingsAndPlaylistsDes".tr,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      isThreeLine: true,
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) => const BackupDialog(),
                      ).whenComplete(
                          () => Get.delete<BackupDialogController>()),
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.only(left: 5, right: 10),
                      title: Text("restoreAppData".tr),
                      subtitle: Text(
                        "restoreSettingsAndPlaylistsDes".tr,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      isThreeLine: true,
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) => const RestoreDialog(),
                      ).whenComplete(
                          () => Get.delete<RestoreDialogController>()),
                    ),
                  ]),
              CustomExpansionTile(
                  icon: Icons.miscellaneous_services,
                  title: "misc".tr,
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.only(left: 5, right: 10),
                      title: Text("resetToDefault".tr),
                      subtitle: Text(
                        "resetToDefaultDes".tr,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      onTap: () {
                        settingsController
                            .resetAppSettingsToDefault()
                            .then((_) {
                          ScaffoldMessenger.of(Get.context!).showSnackBar(
                              snackbar(Get.context!, "resetToDefaultMsg".tr,
                                  size: SanckBarSize.BIG,
                                  duration: const Duration(seconds: 2)));
                        });
                      },
                    ),
                  ]),
              CustomExpansionTile(
                icon: Icons.info_outline_rounded,
                title: "appInfo".tr,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF070B0E),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                          width: 1.0,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          // Diffused ambient glow: center Alignment(0.0, -0.6), radius 0.9
                          Positioned.fill(
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: RadialGradient(
                                  center: Alignment(0.0, -0.6),
                                  radius: 0.9,
                                  colors: [
                                    Color(0x3300E5FF),
                                    Color(0x1500B4D8),
                                    Colors.transparent,
                                  ],
                                  stops: [0.0, 0.45, 1.0],
                                ),
                              ),
                            ),
                          ),
                          // Foreground Content
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18.0, vertical: 24.0),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final isWide = constraints.maxWidth > 640;
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // 1. Header Branding (Cyan Waveform + HARMONY MUSIC + Version Pill)
                                    _buildAmbientHeroHeader(
                                        context, settingsController),
                                    const SizedBox(height: 20),

                                    // 2. Hero Developer Glass Card (Maintainer & Signature)
                                    _buildDualDeveloperCard(context, isWide),
                                    const SizedBox(height: 20),

                                    // 3. Bottom Cards Grid (2 columns on wide, stacked on mobile)
                                    if (isWide)
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 5,
                                            child:
                                                _buildContributorsCard(context),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            flex: 5,
                                            child: Column(
                                              children: [
                                                _buildGitHubCard(context),
                                                const SizedBox(height: 12),
                                                _buildUpdatesCard(
                                                    context, settingsController),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    else
                                      Column(
                                        children: [
                                          _buildContributorsCard(context),
                                          const SizedBox(height: 12),
                                          _buildGitHubCard(context),
                                          const SizedBox(height: 12),
                                          _buildUpdatesCard(
                                              context, settingsController),
                                        ],
                                      ),
                                    const SizedBox(height: 12),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          )),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Center(
              child: Obx(
                () => Text(
                  "Harmony Music ${settingsController.formattedVersion} • $appGithubUser",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(120),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientHeroHeader(
      BuildContext context, SettingsScreenController settingsController) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Glowing cyan audio waveform (#00F5FF) with soft glow BoxShadow
        Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x6600E5FF),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/branding_waveform_cyan.png',
            height: 52,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 14),

        // App Title: "HARMONY MUSIC"
        // Sizing: 26sp, bold, uppercase, letter-spacing: 2.5, color: Colors.white
        SizedBox(
          height: 32,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Image.asset(
              'assets/images/branding_harmony_music.png',
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Version Badge: "v1.24.0" inside capsule pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0x2000E5FF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0x4000E5FF),
              width: 1,
            ),
          ),
          child: Obx(
            () => Text(
              settingsController.formattedVersion,
              style: const TextStyle(
                color: Color(0xFF00F5FF),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDualDeveloperCard(BuildContext context, bool isWide) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isWide ? 16 : 0,
        vertical: 12,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.02),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.14),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 32 : 18,
              vertical: isWide ? 28 : 22,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // LEFT: "Maintained by NPP" (SliceyHeallow font)
                Flexible(
                  flex: 5,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      'assets/images/branding_maintained_by_npp.png',
                      height: isWide ? 62 : 46,
                      fit: BoxFit.contain,
                      color: Colors.white,
                    ),
                  ),
                ),
                // DO NOT put any vertical divider line between them
                // RIGHT: "Narayan" signature (BastligaOne font, Electric Neon Cyan #00F5FF)
                Flexible(
                  flex: 5,
                  child: Container(
                    alignment: Alignment.centerRight,
                    child: Image.asset(
                      'assets/images/branding_signature_cyan_glow.png',
                      height: isWide ? 95 : 74,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContributorsCard(BuildContext context) {
    return FrostedGlassBox(
      padding: const EdgeInsets.all(20),
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0x2500E5FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0x5000E5FF),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.people_rounded,
                  color: Color(0xFF00F5FF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Contributors",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Maintainer: NPP-exe
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => launchUrl(
              Uri.parse("https://github.com/NPP-exe"),
              mode: LaunchMode.externalApplication,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  const Text(
                    "• ",
                    style: TextStyle(
                      color: Color(0xFF00F5FF),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "NPP-exe",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildRoleBadge("Maintainer", const Color(0xFF00F5FF)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Original Creator: anandnet
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => launchUrl(
              Uri.parse("https://github.com/anandnet"),
              mode: LaunchMode.externalApplication,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  const Text(
                    "• ",
                    style: TextStyle(
                      color: Color(0xFF00F5FF),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "anandnet",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildRoleBadge("Original Creator", const Color(0xFF00F5FF)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Community Contributors & Beta Testers
          Row(
            children: const [
              Text(
                "• ",
                style: TextStyle(
                  color: Color(0xFF00F5FF),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Text(
                  "Community Contributors & Beta Testers",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Avatar Dots
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildAvatarDot(
                  handle: "@BandhanPramanik",
                  label: "BP",
                  role: "Core Contributor",
                  color: const Color(0xFF38BDF8),
                  url: "https://github.com/BandhanPramanik",
                ),
                _buildAvatarDot(
                  handle: "@Meralchen",
                  label: "M",
                  role: "macOS, iOS & Web",
                  color: const Color(0xFF34D399),
                  url: "https://github.com/Meralchen",
                ),
                _buildAvatarDot(
                  handle: "@theblackcoderbr",
                  label: "TC",
                  role: "Nix Packaging",
                  color: const Color(0xFFF59E0B),
                  url: "https://github.com/theblackcoderbr",
                ),
                _buildAvatarDot(
                  handle: "@jaxenisr",
                  label: "J",
                  role: "Contributor",
                  color: const Color(0xFFA855F7),
                  url: "https://github.com/jaxenisr",
                ),
                _buildAvatarDot(
                  handle: "Community",
                  label: "❤",
                  role: "Translators & Testers",
                  color: const Color(0xFFEC4899),
                  url: "https://github.com/NPP-exe/Harmony-Music/graphs/contributors",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGitHubCard(BuildContext context) {
    return FrostedGlassBox(
      padding: EdgeInsets.zero,
      borderRadius: 22,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => launchUrl(
            Uri.parse(appGithubUrl),
            mode: LaunchMode.externalApplication,
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.14),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Ionicons.logo_github,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "GitHub Repository",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "$appGithubUser / $appGithubRepo • Original by $appOriginalAuthor",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.open_in_new_rounded,
                  size: 20,
                  color: Colors.white.withOpacity(0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpdatesCard(
      BuildContext context, SettingsScreenController settingsController) {
    return FrostedGlassBox(
      padding: EdgeInsets.zero,
      borderRadius: 22,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () async {
            final info = await settingsController.manualCheckNewVersion();
            if (info.isAvailable) {
              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (context) => const NewVersionDialog(),
                );
              }
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  snackbar(
                    context,
                    "You are on the latest version (${settingsController.formattedVersion})",
                    size: SanckBarSize.MEDIUM,
                  ),
                );
              }
            }
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.20),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF10B981).withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF10B981),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Check for Updates",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Obx(
                        () => Text(
                          settingsController.isNewVersionAvailable.value
                              ? "New version ${settingsController.latestVersion.value} is available!"
                              : "Harmony Music is up to date",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: settingsController.isNewVersionAvailable.value
                                ? Colors.amber[300]
                                : Colors.white.withOpacity(0.55),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.auto_awesome,
                  size: 20,
                  color: const Color(0xFF00F5FF).withOpacity(0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.65),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildAvatarDot({
    required String handle,
    required String label,
    required String role,
    required Color color,
    required String url,
  }) {
    return Tooltip(
      message: "$handle • $role",
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        ),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color.withOpacity(0.85),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.35),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}

class FrostedGlassBox extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;

  const FrostedGlassBox({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.borderRadius = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: width,
            height: height,
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.09),
                  Colors.white.withOpacity(0.02),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.13),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}


class ThemeSelectorDialog extends StatelessWidget {
  const ThemeSelectorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsScreenController>();
    return CommonDialog(
      child: Container(
        height: 300,
        //color: Theme.of(context).cardColor,
        padding: const EdgeInsets.only(top: 30, left: 5, right: 30, bottom: 10),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0, bottom: 5),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "themeMode".tr,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          radioWidget(
            label: "dynamic".tr,
            controller: settingsController,
            value: ThemeType.dynamic,
          ),
          radioWidget(
              label: "systemDefault".tr,
              controller: settingsController,
              value: ThemeType.system),
          radioWidget(
              label: "dark".tr,
              controller: settingsController,
              value: ThemeType.dark),
          radioWidget(
              label: "light".tr,
              controller: settingsController,
              value: ThemeType.light),
          Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("cancel".tr),
                ),
                onTap: () => Navigator.of(context).pop(),
              ))
        ]),
      ),
    );
  }
}

class DiscoverContentSelectorDialog extends StatelessWidget {
  const DiscoverContentSelectorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsScreenController>();
    return CommonDialog(
      child: Container(
        height: 300,
        //color: Theme.of(context).cardColor,
        padding: const EdgeInsets.only(top: 30, left: 5, right: 30, bottom: 10),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0, bottom: 5),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "setDiscoverContent".tr,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          SizedBox(
            height: 180,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  radioWidget(
                      label: "quickpicks".tr,
                      controller: settingsController,
                      value: "QP"),
                  radioWidget(
                      label: "topmusicvideos".tr,
                      controller: settingsController,
                      value: "TMV"),
                  radioWidget(
                      label: "trending".tr,
                      controller: settingsController,
                      value: "TR"),
                  radioWidget(
                      label: "basedOnLast".tr,
                      controller: settingsController,
                      value: "BOLI"),
                ],
              ),
            ),
          ),
          const Expanded(child: SizedBox()),
          Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("cancel".tr),
                ),
                onTap: () => Navigator.of(context).pop(),
              ))
        ]),
      ),
    );
  }
}

Widget radioWidget(
    {required String label,
    required SettingsScreenController controller,
    required value}) {
  return Obx(() => ListTile(
        visualDensity: const VisualDensity(vertical: -4),
        onTap: () {
          if (value.runtimeType == ThemeType) {
            controller.onThemeChange(value);
          } else {
            controller.onContentChange(value);
            Navigator.of(Get.context!).pop();
          }
        },
        leading: Radio(
            value: value,
            groupValue: value.runtimeType == ThemeType
                ? controller.themeModetype.value
                : controller.discoverContentType.value,
            onChanged: value.runtimeType == ThemeType
                ? controller.onThemeChange
                : controller.onContentChange),
        title: Text(label),
      ));
}
