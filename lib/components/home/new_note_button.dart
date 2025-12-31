import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:saber/components/navbar/horizontal_navbar.dart';
import 'package:saber/components/theming/saber_theme.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/routes.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:saber/pages/editor/editor.dart';

import 'new_folder_dialog.dart';

class NewNoteButton extends StatefulWidget {
  const NewNoteButton({
    super.key,
    required this.cupertino,
    this.path,
    this.onCreateFolder,
  });

  final bool cupertino;
  final String? path;
  final VoidCallback? onCreateFolder;

  @override
  State<NewNoteButton> createState() => _NewNoteButtonState();
}

class _NewNoteButtonState extends State<NewNoteButton> {
  final ValueNotifier<bool> isDialOpen = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final materialBorderRadius = BorderRadius.circular(16);
    return SpeedDial(
      spacing: 3,
      mini: true,
      openCloseDial: isDialOpen,
      childPadding: const .all(5),
      spaceBetweenChildren: 4,
      switchLabelPosition: Directionality.of(context) == .rtl,
      shape: widget.cupertino
          ? const CircleBorder()
          : RoundedRectangleBorder(borderRadius: materialBorderRadius),
      dialRoot: (context, open, toggleChildren) {
        final platform = Theme.of(context).platform;
        return GlassyContainer(
          height: 56,
          borderRadius: platform.isCupertino ? null : materialBorderRadius,
          child: AspectRatio(
            aspectRatio: 1,
            child: IconButton(
              onPressed: toggleChildren,
              tooltip: t.home.tooltips.newNote,
              visualDensity: VisualDensity.compact,
              style: IconButton.styleFrom(
                padding: .zero,
                shape: platform.isCupertino
                    ? const CircleBorder()
                    : RoundedRectangleBorder(
                        borderRadius: materialBorderRadius,
                      ),
              ),
              icon: const Center(child: Icon(Icons.add)),
            ),
          ),
        );
      },
      children: [
        SpeedDialChild(
          child: const Icon(Icons.create),
          label: t.home.create.newNote,
          onTap: () async {
            if (widget.path == null) {
              context.push(RoutePaths.edit);
            } else {
              final newFilePath = await FileManager.newFilePath(
                '${widget.path}/',
              );
              if (!context.mounted) return;
              context.push(RoutePaths.editFilePath(newFilePath));
            }
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.note_add),
          label: t.home.create.importNote,
          onTap: () async {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.any,
              allowMultiple: false,
              withData: false,
            );
            if (result == null) return;

            final filePath = result.files.single.path;
            final fileName = result.files.single.name;
            if (filePath == null) return;

            if (filePath.toLowerCase().endsWith('.sbn') ||
                filePath.toLowerCase().endsWith('.sbn2') ||
                filePath.toLowerCase().endsWith('.sba')) {
              final path = await FileManager.importFile(
                filePath,
                '${widget.path ?? ''}/',
              );
              if (path == null) return;
              if (!context.mounted) return;

              context.push(RoutePaths.editFilePath(path));
            } else if (filePath.toLowerCase().endsWith('.pdf')) {
              if (!Editor.canRasterPdf) return;
              if (!mounted) return;

              final fileNameWithoutExtension = fileName.substring(
                0,
                fileName.length - '.pdf'.length,
              );
              final sbnFilePath =
                  await FileManager.suffixFilePathToMakeItUnique(
                    '${widget.path ?? ''}/$fileNameWithoutExtension',
                  );
              if (!context.mounted) return;

              context.push(RoutePaths.editImportPdf(sbnFilePath, filePath));
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(t.home.invalidFormat)));
              }
              throw 'Invalid file type';
            }
          },
        ),
        // Folder creation should be available in root (path == null or empty) and subfolders
        SpeedDialChild(
          child: const Icon(Icons.create_new_folder),
          label: t.home.newFolder.newFolder,
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => NewFolderDialog(
                createFolder: (folderName) async {
                  // If path is null or empty, we are at root, so just use /folderName
                  final basePath = (widget.path == null || widget.path!.isEmpty) ? '' : widget.path;
                  final folderPath = '$basePath/$folderName';
                  await FileManager.createFolder(folderPath);
                  widget.onCreateFolder?.call();
                },
                doesFolderExist: (folderName) {
                  final basePath = (widget.path == null || widget.path!.isEmpty) ? '' : widget.path;
                  return FileManager.isDirectory('$basePath/$folderName');
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
