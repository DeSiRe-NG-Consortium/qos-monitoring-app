import 'package:flutter/material.dart';

class DialogService {
  
  static showSnackbar(context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(
            255, 55, 55, 55),
        //behavior: SnackBarBehavior.floating, // Optional: Schwebende Snackbar
        duration: const Duration(seconds: 1),
        /*
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        */
      ),
    );
  }

}
