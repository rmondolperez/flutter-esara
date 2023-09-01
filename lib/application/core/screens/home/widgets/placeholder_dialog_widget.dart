import 'package:flutter/material.dart';

class PlaceholderDialog extends StatelessWidget {
  const PlaceholderDialog({
    this.icon,
    this.title,
    this.message,
    this.actions = const [],
    Key? key,
  }) : super(key: key);

  final Widget? icon;
  final String? title;
  final String? message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      icon: icon,
      title: title == null
          ? null
          : Text(
              title!,
              textAlign: TextAlign.center,
            ),
      //titleTextStyle: AppStyle.bodyBlack,
      content: message == null
          ? null
          : SingleChildScrollView(
              child: Text(
                message!,
                textAlign: TextAlign.justify,
              ),
            ),
      //contentTextStyle: AppStyle.textBlack,
      actionsOverflowButtonSpacing: 8.0,
      actions: actions,
    );
  }
}
