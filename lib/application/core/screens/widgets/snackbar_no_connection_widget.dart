import 'package:esara/application/core/constants/colors.dart';
import 'package:flutter/material.dart';

class SnackbarNoConnectionWidget extends StatelessWidget {
  const SnackbarNoConnectionWidget({
    super.key,
    required this.text,
    required this.isNetworkConnected,
  });
  final String text;
  final bool isNetworkConnected;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      child: AnimatedOpacity(
        duration: const Duration(seconds: 2),
        opacity: !isNetworkConnected ? 1 : 0,
        child: Container(
          width: double.infinity,
          height: 75,
          decoration: const BoxDecoration(
              color: tPrimaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              )),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  text,
                  style: const TextStyle(color: Colors.black),
                ),
                const Icon(
                  Icons.settings,
                  size: 25.0,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
