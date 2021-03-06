import 'package:MinioClient/minio/DownloadController.dart';
import 'package:MinioClient/pages/widgets/ConfirmDialog.dart';
import 'package:MinioClient/pages/widgets/SelectingHandler.dart';
import 'package:MinioClient/utils/file.dart';
import 'package:MinioClient/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' show basename;
import 'package:rxdart/rxdart.dart';

typedef ChangeSelecting = void Function([bool value]);

class DownloadPage extends StatefulWidget {
  final bool selecting;
  final ChangeSelecting changeSelecting;
  MenuButtonMethod eventType;
  DownloadPage({
    Key key,
    this.selecting,
    this.changeSelecting,
    this.eventType,
  }) : super(key: key);

  @override
  _DownloadPageState createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  DownloadController downloadController;
  // ignore: close_sinks
  ReplaySubject<List<DownloadFileInstance>> _stream;

  /// 多选值
  final Map<int, DownloadFileInstance> selectingValues = new Map();

  _DownloadPageState() {
    this.downloadController = createDownloadInstance();
    this._stream = this.downloadController.downloadStream;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(DownloadPage oldWidget) {
    // 触发事件， 没想到更简单的方式
    if (oldWidget.eventType != widget.eventType && widget.eventType != null) {
      this.callMethod(widget.eventType);
    }
    // 置空多选的数据
    if (widget.selecting == false) {
      setState(() {
        this.selectingValues.clear();
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: this._stream,
        builder: (context, AsyncSnapshot<List<DownloadFileInstance>> builder) {
          final data = builder.data ?? [];
          if (!builder.hasData) {
            return FlatButton(
                child: Text('没有数据我添加试试看'),
                onPressed: () {
                  this._stream.add([
                    DownloadFileInstance(
                        1, 'image', '123', 10000, 1000000, 1000, 100)
                  ]);
                });
          }
          return data.length == 0
              ? Container(
                  alignment: Alignment.center,
                  child: Text(
                    '你还没下载过东西！',
                    style: TextStyle(fontSize: 20),
                  ),
                )
              : Container(
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final current = data[index];
                      final filename = basename(current.filename);
                      return Column(
                        children: [
                          ListTile(
                              onLongPress: () => _onLongPress(current),
                              onTap: () => _onTap(current),
                              leading:
                                  _renderLeading(selectingValues[current.id]),
                              title: Text(filename),
                              subtitle: _renderSubtitle(current),
                              trailing: _renderTrailing(current)),
                          if (current.state == DownloadState.DOWNLOAD)
                            LinearProgressIndicator(
                              value: current.downloadSize / current.fileSize,
                            )
                        ],
                      );
                    },
                  ),
                );
        });
  }

  _renderSubtitle(DownloadFileInstance current) {
    final progress = (100 * (current.downloadSize / current.fileSize)).toInt();
    String text;

    TextStyle textStyle;
    switch (current.state) {
      case DownloadState.DOWNLOAD:
        text =
            '${byteToSize(current.downloadSize)}/${byteToSize(current.fileSize)} 已完成$progress%';
        break;
      case DownloadState.COMPLETED:
        text = '下载完成，可进行预览';
        break;
      case DownloadState.ERROR:
        text = 'Error: ${current.stateText}';
        textStyle = TextStyle(color: Colors.red);
        break;
      case DownloadState.PAUSE:
        text = '正在等待下载';
        break;
      case DownloadState.STOP:
        text = '已停止下载 已完成$progress%';
        break;
    }
    return Text(
      text,
      style: textStyle,
    );
  }

  _renderTrailing(DownloadFileInstance current) {
    switch (current.state) {
      case DownloadState.DOWNLOAD:
        return FlatButton.icon(
          label: Text('暂停'),
          icon: Icon(Icons.stop_circle),
          onPressed: () async {
            await this.downloadController.stopDownload(current);
            toast('暂停成功');
          },
        );
        break;
      case DownloadState.STOP:
        return FlatButton.icon(
            label: Text('下载'),
            icon: Icon(Icons.play_circle_outline),
            onPressed: () {
              this.downloadController.reDownload(current);
              toast('继续下载');
            });
        break;
      case DownloadState.COMPLETED:
        return FlatButton.icon(
            label: Text('预览'),
            icon: Icon(Icons.preview_outlined),
            onPressed: () {
              if (hasFileExists(current.filePath)) {
                OpenFile.open(current.filePath);
              } else {
                this.downloadController.updateDownloadState(
                    current, DownloadState.ERROR,
                    stateText: '预览失败，文件已失效，请重新下载');
                // toastError('预览失败，下载的文件已被删除');
              }
            });
        break;
      case DownloadState.PAUSE:
        return FlatButton.icon(
            label: Text('等待'),
            icon: Icon(Icons.play_circle_outline),
            onPressed: () {
              this.downloadController.advanceDownload(current);
              toast('继续下载');
            });
      case DownloadState.ERROR:
        return FlatButton.icon(
            icon: Icon(Icons.refresh),
            label: Text('重新下载'),
            onPressed: () {
              showConfirmDialog(this.context,
                  title: '重新下载', content: Text('是否要重新下载此文件？'), onConfirm: () {
                removeFile(current.filePath).then((res) {
                  this.downloadController.reDownload(current);
                });
              });
            });
      default:
        Text('下载错误，请重新下载');
    }
  }

  Widget _renderLeading(value) {
    if (!this.widget.selecting) {
      return null;
    }
    if (value == null) {
      value = false;
    }
    return AbsorbPointer(
      child: SizedBox(
        width: 25,
        height: 25,
        child: Checkbox(
          value: value is DownloadFileInstance ? true : false,
          // onChanged: (value) => (widget.checkboxChanged(current.eTag, value)),
          onChanged: (value) => null,
        ),
      ),
    );
  }

  void _onLongPress(DownloadFileInstance instance) {
    widget.changeSelecting(true);
    this.selectingValues[instance.id] = instance;
  }

  void callMethod(MenuButtonMethod eventType) {
    switch (eventType) {
      case MenuButtonMethod.SelectAll:
        Iterable<MapEntry<int, DownloadFileInstance>> _mapEntry =
            this.downloadController.downloadList.map((item) {
          return MapEntry(item.id, item);
        });
        selectingValues.addEntries(_mapEntry);
        break;
      case MenuButtonMethod.CancelAll:
        this.selectingValues.clear();
        break;
      case MenuButtonMethod.DeleteAndFile:
      case MenuButtonMethod.Delete:
        final text = eventType == MenuButtonMethod.DeleteAndFile
            ? '确认删除所选的文件且包括已下载的文件'
            : '确认删除所选的下载记录？';
        Future.delayed(Duration.zero).then((_) {
          showConfirmDialog(this.context, title: '删除文件', content: Text(text),
              onConfirm: () async {
            this.downloadController.deleteDownload(
                this.selectingValues.values.toList(),
                deleteFile:
                    eventType == MenuButtonMethod.DeleteAndFile ? true : false);
            Future.delayed(Duration.zero).then((_) {
              widget.changeSelecting(false);
            });
          });
        });
        break;
      case MenuButtonMethod.Download:
        this.selectingValues.values.forEach((item) {
          if (item.state == DownloadState.STOP)
            this.downloadController.reDownload(item);
        });
        Future.delayed(Duration.zero).then((_) {
          widget.changeSelecting(false);
        });
        break;
      case MenuButtonMethod.STOP:
        this.selectingValues.values.forEach((item) {
          if (item.state == DownloadState.PAUSE ||
              item.state == DownloadState.DOWNLOAD)
            this.downloadController.scheduler.addStop(item);
        });
        Future.delayed(Duration.zero).then((_) {
          widget.changeSelecting(false);
        });
        break;
    }
  }

  void _onTap(DownloadFileInstance current) {
    setState(() {
      if (this.selectingValues.containsKey(current.id)) {
        this.selectingValues.remove(current.id);
        return;
      }
      this.selectingValues[current.id] = current;
    });
  }
}
