import 'package:flutter/material.dart';

import '/constants/medication_constants.dart';

class MedicationInputField extends StatelessWidget {
  final TextEditingController controller;
  
  const MedicationInputField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        fontSize: 18,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: 'Nama obat...',
        hintStyle: TextStyle(
          color: Colors.grey.shade500,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: MedicationConstants.inputPadding,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MedicationConstants.inputBorderRadius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}