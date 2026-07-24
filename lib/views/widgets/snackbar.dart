import 'package:flutter/material.dart';

class mostraSnackBar {
  static void show(BuildContext context, String mensagem, bool? isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: isError == true
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
