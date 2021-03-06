import 'package:MinioClient/pages/widgets/DownloadPage.dart';
import 'package:flutter/material.dart';

enum MenuButtonMethod {
  SelectAll,
  CancelAll,
  Delete,
  DeleteAndFile,
  Download,
  STOP,
}

class SelectingHandler extends StatelessWidget {
  final ValueChanged onSelected;
  final ChangeSelecting changeSelecting;
  const SelectingHandler(
      {Key key, @required this.onSelected, this.changeSelecting})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _renderSelectingActions(),
    );
  }

  List<Widget> _renderSelectingActions() {
    return [
      Tooltip(
        message: '取消多选',
        child: IconButton(
          icon: Icon(Icons.cancel),
          onPressed: () {
            this.changeSelecting(false);
          },
        ),
      ),
      PopupMenuButton(
        tooltip: '操作',
        onSelected: onSelected,
        itemBuilder: (context) {
          List<PopupMenuEntry<dynamic>> list = [
            PopupMenuItem(
              child: Text('选择全部'),
              value: MenuButtonMethod.SelectAll,
            ),
            PopupMenuItem(
              child: Text('取消选择'),
              value: MenuButtonMethod.CancelAll,
            ),
            PopupMenuItem(
              child: Text('下载'),
              value: MenuButtonMethod.Download,
            ),
            PopupMenuItem(
              child: Text('停止'),
              value: MenuButtonMethod.STOP,
            ),
            PopupMenuItem(
              child: Text('删除记录'),
              value: MenuButtonMethod.Delete,
            ),
            PopupMenuItem(
              child: Text('删除记录和文件'),
              value: MenuButtonMethod.DeleteAndFile,
            ),
          ];
          return list;
        },
      )
    ];
  }
}
