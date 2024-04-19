import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toastification/toastification.dart';

import 'shared.dart';

void showToast(BuildContext context, String message, Color color) {
  toastification.show(
    context: context,
    description: Text(message, style: GoogleFonts.itim(fontSize: 14, fontWeight: FontWeight.w500, color: darkColor)),
    title: Text("Notification", style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: color)),
    autoCloseDuration: 5.seconds,
    backgroundColor: whiteColor,
    type: ToastificationType.info,
    primaryColor: color,
    style: ToastificationStyle.minimal,
    progressBarTheme: ProgressIndicatorThemeData(color: color, linearMinHeight: .5),
    foregroundColor: color,
  );
}

Future<void> init() async {
  Hive.init((await getApplicationDocumentsDirectory()).path);
  user = await Hive.openBox("user");
  await user!.clear();
  if (!user!.containsKey("quotes")) {
    user!.put("quotes", <Map<String, dynamic>>[]);
  }
}
