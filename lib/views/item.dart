import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/quote_model.dart';
import '../utils/shared.dart';
import 'menu.dart';

class Item extends StatefulWidget {
  const Item({super.key, required this.quotes, required this.index});

  final List<QuoteModel> quotes;
  final int index;

  @override
  State<Item> createState() => _ItemState();
}

class _ItemState extends State<Item> {
  String _computeTimestamp(DateTime timestamp) {
    final DateTime now = DateTime.now();
    if (now.day == timestamp.day && now.month == timestamp.month && now.year == timestamp.year) {
      return formatDate(timestamp, const <String>["Today at ", HH, ':', nn, ' ', am]);
    } else if (now.month == timestamp.month && now.year == timestamp.year && now.subtract(1.days).day == timestamp.day) {
      return formatDate(timestamp, const <String>["Yesterday at ", HH, ':', nn, ' ', am]);
    } else {
      return formatDate(timestamp, const <String>[D, ", ", dd, " ", MM, " ", yyyy, "[ ", HH, ":", nn, " ", am, " ]"]).toUpperCase();
    }
  }

  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: darkColor,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(5),
          bottomRight: Radius.circular(5),
          bottomLeft: Radius.circular(5),
        ),
      ),
      child: InkWell(
        highlightColor: transparentColor,
        splashColor: transparentColor,
        hoverColor: transparentColor,
        onHover: (bool value) => setState(() => _isHovered = value),
        onTap: () {},
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: darkColor, borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5))),
              child: Text(
                _computeTimestamp(widget.quotes[widget.index].timestamp),
                style: GoogleFonts.itim(fontSize: 12, fontWeight: FontWeight.w500, color: whiteColor.withOpacity(.8)),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Spacer(),
                    AnimatedOpacity(
                      opacity: _isHovered ? 1 : 0,
                      duration: 300.ms,
                      child: Menu(index: widget.index, quotes: widget.quotes),
                    ),
                    widget.quotes[widget.index].emojies.isEmpty
                        ? const SizedBox()
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(width: 2, color: scaffoldColor), color: darkColor),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      <String>[
                                        for (final MapEntry<String, String> entry in <String, String>{
                                          for (final String emoji in widget.quotes[widget.index].emojies) emoji: widget.quotes[widget.index].emojies.where((dynamic element) => element == emoji).length.toString(),
                                        }.entries)
                                          "${entry.key} ${entry.value}"
                                      ].join("  "),
                                      style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: whiteColor),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(widget.quotes[widget.index].author, style: GoogleFonts.itim(fontSize: 18, fontWeight: FontWeight.w500, color: whiteColor.withOpacity(.8))),
                const SizedBox(height: 20),
                Text(widget.quotes[widget.index].quote, style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: whiteColor.withOpacity(.8))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
