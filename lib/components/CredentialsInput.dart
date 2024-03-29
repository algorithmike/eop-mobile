import 'package:flutter/material.dart';

import 'package:eop_mobile/utils/constants.dart';

class CredentialsInput extends StatelessWidget {
  const CredentialsInput(
      {Key key,
      this.label,
      this.controller,
      this.obscureText = false,
      this.longText = false})
      : super(key: key);
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final bool longText;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 40.0,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          maxLines: (longText) ? null : 1,
          maxLength: (longText) ? 128 : 32,
          obscureText: obscureText,
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            counterText: (longText) ? null : "",
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.all(
                Radius.circular(6.0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: kHighlightsColor),
              borderRadius: BorderRadius.all(
                Radius.circular(6.0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
