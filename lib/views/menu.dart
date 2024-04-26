import 'package:emoji_selector/emoji_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';

import '../models/quote_model.dart';
import '../utils/callbacks.dart';
import '../utils/shared.dart';

class Menu extends StatefulWidget {
  const Menu({super.key, required this.quotes, required this.index});

  final List<QuoteModel> quotes;
  final int index;

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          onPressed: () async {
            Clipboard.setData(ClipboardData(text: widget.quotes[widget.index].toJson().toString()));
            // ignore: use_build_context_synchronously
            showToast(context, "Text copied to clipboard", greenColor);
          },
          icon: const Icon(Bootstrap.clipboard2_fill, size: 15, color: pinkColor),
        ),
        IconButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext contextt) => Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: <Widget>[
                    TextButton(
                      style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(scaffoldColor)),
                      onPressed: () => Navigator.pop(context),
                      child: Text("Cancel", style: GoogleFonts.itim(fontSize: 14, fontWeight: FontWeight.w500, color: whiteColor)),
                    ),
                    const Spacer(),
                    TextButton(
                      style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(pinkColor)),
                      onPressed: () {
                        user!.put("quotes", widget.quotes..removeAt(widget.index));
                        Navigator.pop(contextt);
                      },
                      child: Text("Apply", style: GoogleFonts.itim(fontSize: 14, fontWeight: FontWeight.w500, color: whiteColor)),
                    ),
                  ],
                ),
              ),
            );
          },
          icon: const Icon(Bootstrap.x_octagon_fill, size: 15, color: pinkColor),
        ),
        IconButton(
          onPressed: () {
            showBottomSheet(
              enableDrag: true,
              context: context,
              builder: (BuildContext context) => Container(
                decoration: BoxDecoration(color: darkColor, borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.all(24),
                height: 300,
                child: SingleChildScrollView(
                  child: EmojiSelector(
                    withTitle: true,
                    onSelected: (EmojiData emoji) {
                      final List<Map<String, dynamic>> data = widget.quotes.map((QuoteModel e) => e.toJson()).toList();
                      data[widget.index].update("emojies", (dynamic value) => value..add(emoji.char));
                      user!.put("quotes", data);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            );
          },
          icon: const Icon(Bootstrap.emoji_smile_fill, size: 15, color: pinkColor),
        ),
      ],
    );
  }
}
