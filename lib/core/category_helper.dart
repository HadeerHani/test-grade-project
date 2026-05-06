import 'package:flutter/material.dart';

class CategoryHelper {
  static IconData getIcon(String categoryName) {
    final String name = categoryName.toLowerCase();
    
    if (name.contains("repair") || name.contains("home") || name.contains("maintenance")) {
      return Icons.build_rounded;
    } else if (name.contains("cleaning") || name.contains("laundry")) {
      return Icons.cleaning_services_rounded;
    } else if (name.contains("personal") || name.contains("beauty") || name.contains("salon")) {
      return Icons.face_rounded;
    } else if (name.contains("vehicle") || name.contains("car") || name.contains("auto")) {
      return Icons.directions_car_rounded;
    } else if (name.contains("moving") || name.contains("delivery") || name.contains("shipping")) {
      return Icons.local_shipping_rounded;
    } else if (name.contains("painting")) {
      return Icons.format_paint_rounded;
    } else if (name.contains("electric") || name.contains("wiring")) {
      return Icons.electrical_services_rounded;
    } else if (name.contains("plumbing") || name.contains("water")) {
      return Icons.plumbing_rounded;
    } else if (name.contains("gardening") || name.contains("outdoor")) {
      return Icons.yard_rounded;
    } else if (name.contains("ac") || name.contains("cooling") || name.contains("hvac")) {
      return Icons.ac_unit_rounded;
    } else if (name.contains("tech") || name.contains("it") || name.contains("computer")) {
      return Icons.computer_rounded;
    } else {
      return Icons.miscellaneous_services_rounded;
    }
  }
}
