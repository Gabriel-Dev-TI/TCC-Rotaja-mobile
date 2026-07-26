import 'package:flutter/material.dart';

class mostraSnackBar {
  mostraSnackBar(context, $e, bool bool);

  static void show(BuildContext context, String mensagem, bool? isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: isError == true
            ? Theme.of(context).colorScheme.error
            : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
