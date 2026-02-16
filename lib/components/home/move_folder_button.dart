import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saber/components/home/grid_folders.dart';
import 'package:saber/components/theming/adaptive_alert_dialog.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/i18n/strings.g.dart';

class MoveFolderButton extends StatelessWidget {
  const MoveFolderButton({
    super.key,
    required this.folderToMove,
    required this.currentPath,
    required this.onMove,
  });

  final String folderToMove;
  final String currentPath;
  final VoidCallback onMove;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      tooltip: t.home.moveNote.moveNote,
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return _MoveFolderDialog(
              folderToMove: folderToMove,
              initialParentPath: currentPath,
              onMove: onMove,
            );
          },
        );
      },
      icon: const Icon(Icons.drive_file_move),
    );
  }
}

class _MoveFolderDialog extends StatefulWidget {
  const _MoveFolderDialog({
    required this.folderToMove,
    required this.initialParentPath,
    required this.onMove,
  });

  final String folderToMove;
  final String initialParentPath;
  final VoidCallback onMove;

  @override
  State<_MoveFolderDialog> createState() => _MoveFolderDialogState();
}

class _MoveFolderDialogState extends State<_MoveFolderDialog> {
  late String _currentFolder;

  /// The current folder browsed to in the dialog.
  String get currentFolder => _currentFolder;
  set currentFolder(String folder) {
    _currentFolder = folder;
    currentFolderChildren = null;
    findChildrenOfCurrentFolder();
  }

  /// The children of [currentFolder].
  DirectoryChildren? currentFolderChildren;

  String? newFolderName;
  bool isRenamed = false;

  Future findChildrenOfCurrentFolder() async {
    currentFolderChildren = await FileManager.getChildrenOfDirectory(
      currentFolder,
    );

    String name = widget.folderToMove;
    if (currentFolderChildren?.directories.contains(name) ?? false) {
      int i = 1;
      while (currentFolderChildren?.directories.contains('$name ($i)') ??
          false) {
        i++;
      }
      newFolderName = '$name ($i)';
      isRenamed = true;
    } else {
      newFolderName = name;
      isRenamed = false;
    }

    if (!mounted) return;
    setState(() {});
  }

  Future<void> createFolder(String folderName) async {
    final folderPath = '$currentFolder/$folderName';
    await FileManager.createFolder(folderPath);
    findChildrenOfCurrentFolder();
  }

  late final String sourceFullPath;

  @override
  void initState() {
    String parent = widget.initialParentPath;
    if (!parent.startsWith('/')) parent = '/$parent';
    if (!parent.endsWith('/')) parent = '$parent/';
    currentFolder = parent;
    
    sourceFullPath = '$parent${widget.folderToMove}';

    super.initState();
    findChildrenOfCurrentFolder();
  }

  @override
  Widget build(BuildContext context) {
    // Filter out the folder itself so we can't move it into itself
    final visibleFolders = <String>[];
    if (currentFolderChildren != null) {
      for (final dir in currentFolderChildren!.directories) {
        final dirPath = '$currentFolder$dir';
        // Check if dirPath is the source folder or a subfolder of it
        // Actually, just checking if it IS the source folder is enough because
        // if we don't show the source folder, we can't navigate into it.
        // Also check if we are currently inside the source folder (shouldn't happen if we start at parent)
        
        // However, we start at parent. Parent contains source folder.
        // We shouldn't show source folder in the grid.
        
        // Construct full path of the directory item
        // currentFolder ends with /
        // dir does not start with /
        
        // We only need to hide the folder if we are in its parent.
        // sourceFullPath is like /A/Folder
        // currentFolder is like /A/
        // dir is Folder
        // "$currentFolder$dir" == "/A/Folder" == sourceFullPath
        
        if ('$currentFolder$dir' == sourceFullPath) continue;
        
        visibleFolders.add(dir);
      }
    }

    return AdaptiveAlertDialog(
      title: Text(t.home.moveNote.moveName(f: widget.folderToMove)),
      content: SizedBox(
        width: 300,
        height: 300,
        child: Column(
          children: [
            Text(currentFolder),
            Expanded(
              child: CustomScrollView(
                shrinkWrap: true,
                slivers: [
                  GridFolders(
                    isAtRoot: currentFolder == '/',
                    crossAxisCount: 3,
                    onTap: (String folder) {
                      setState(() {
                        if (folder == '..') {
                          currentFolder = currentFolder.substring(
                            0,
                            currentFolder.lastIndexOf(
                                  '/',
                                  currentFolder.length - 2,
                                ) +
                                1,
                          );
                        } else {
                          currentFolder = '$currentFolder$folder/';
                        }
                      });
                    },
                    createFolder: createFolder,
                    doesFolderExist: (String folderName) {
                      return currentFolderChildren?.directories.contains(
                            folderName,
                          ) ??
                          false;
                    },
                    renameFolder: (String oldName, String newName) async {
                      final oldPath = '$currentFolder$oldName';
                      await FileManager.renameDirectory(oldPath, newName);
                      findChildrenOfCurrentFolder();
                    },
                    isFolderEmpty: (String folderName) async {
                      final folderPath = '$currentFolder$folderName';
                      final children = await FileManager.getChildrenOfDirectory(
                        folderPath,
                      );
                      return children?.isEmpty ?? true;
                    },
                    deleteFolder: (String folderName) async {
                      final folderPath = '$currentFolder$folderName';
                      await FileManager.deleteDirectory(folderPath);
                      findChildrenOfCurrentFolder();
                    },
                    folders: visibleFolders,
                  ),
                ],
              ),
            ),
            if (isRenamed)
              Text(t.home.moveNote.renamedTo(newName: newFolderName!))
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(t.common.cancel),
        ),
        CupertinoDialogAction(
          onPressed: () async {
            if (newFolderName != null) {
                // Remove trailing slash from currentFolder if present and joining
                // But currentFolder is guaranteed to end with slash in setters/initState
                await FileManager.moveDirectory(
                  sourceFullPath,
                  '$currentFolder$newFolderName',
                );
            }
            widget.onMove();
            if (!context.mounted) return;
            Navigator.of(context).pop();
          },
          child: Text(t.home.moveNote.move),
        ),
      ],
    );
  }
}
