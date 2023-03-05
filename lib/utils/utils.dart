import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 复制字符串到剪贴板
void copyToClipboard(String text) {
  Clipboard.setData(ClipboardData(text: text));
}

void onCopy(BuildContext context, dynamic content) {
  copyToClipboard(content);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.of(context).pop();
      });
      return const AlertDialog(
        title: Text('已复制'),
      );
    },
  );
}
