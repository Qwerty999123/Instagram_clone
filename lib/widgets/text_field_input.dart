
import 'package:flutter/material.dart';

class TextFieldInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final String hint;
  final TextInputType textInputType;

  const TextFieldInput({
    super.key, 
    required this.textEditingController, 
    this.isPass = false, 
    required this.hint, 
    required this.textInputType
  });

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderSide: Divider.createBorderSide(context)
    );
    return TextField(
      controller: textEditingController,
      decoration: InputDecoration(
        fillColor: const Color.fromRGBO(27, 27, 27, 1),
        hintText: hint,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder,
        border: inputBorder,
        filled: true,
        contentPadding: const EdgeInsets.all(8.0)
      ),
      obscureText: isPass,
      keyboardType: textInputType,
    );
  }
}