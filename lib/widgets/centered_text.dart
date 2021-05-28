import 'package:flutter/material.dart';

class CenteredText extends StatelessWidget {
  final String text;

  const CenteredText({@required this.text, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16.0),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
