import 'package:flutter/material.dart';

class OptionTile extends StatelessWidget {
  final String optionText;
  final VoidCallback onTap;

  const OptionTile({required this.optionText, required this.onTap, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(optionText),
        onTap: onTap,
      ),
    );
  }
}
