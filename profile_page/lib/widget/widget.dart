import 'package:flutter/material.dart';

class BuildTextFormField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final bool obscureText;
  final Function(String?)? change;
  final bool? readOnly;

  const BuildTextFormField(
      {super.key,
      required this.label,
      this.controller,
      this.obscureText = false,
      this.change,
      this.readOnly});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.059,
        child: TextFormField(
          controller: controller,
          readOnly: readOnly ?? false,
          obscureText: obscureText,
          onChanged: (value) {
            change!(value);
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade200,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Theme.of(context).focusColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Theme.of(context).focusColor),
            ),
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
