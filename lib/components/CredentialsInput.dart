import 'package:flutter/material.dart';

class CredentialsInput extends StatelessWidget {
  const CredentialsInput(
      {Key key, this.label, this.controller, this.obscureText = false})
      : super(key: key);
  final String label;
  final TextEditingController controller;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 40.0,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          obscureText: obscureText,
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.all(
                Radius.circular(6.0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.teal[200]),
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
