import 'package:date_format/date_format.dart';
import 'package:emoji_selector/emoji_selector.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:uuid/uuid.dart';
import 'package:vibes/utils/helpers/loading.dart';
import 'package:vibes/utils/helpers/errored.dart';
import 'package:vibes/utils/shared.dart';
import 'package:flutter/material.dart';

import '../models/quote_model.dart';
import '../utils/callbacks.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<QuoteModel> _quotes = <QuoteModel>[];

  String _computeTimestamp(DateTime timestamp) {
    final DateTime now = DateTime.now();
    if (now.day == timestamp.day && now.month == timestamp.month && now.year == timestamp.year) {
      return formatDate(timestamp, const <String>["Today at ", HH, ':', nn, ' ', am]);
    } else if (now.month == timestamp.month && now.year == timestamp.year && now.subtract(1.days).day == timestamp.day) {
      return formatDate(timestamp, const <String>["Yesterday at ", HH, ':', nn, ' ', am]);
    } else {
      return formatDate(timestamp, const <String>[dd, "/", mm, "/", yyyy, " ", HH, ":", nn, " ", am]);
    }
  }

  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _quoteController = TextEditingController();

  @override
  void dispose() {
    _authorController.dispose();
    _quoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      floatingActionButton: InkWell(
        splashColor: transparentColor,
        highlightColor: transparentColor,
        hoverColor: transparentColor,
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("ADD A QUOTE", style: GoogleFonts.itim(fontSize: 25, fontWeight: FontWeight.w500, color: whiteColor)),
                  const SizedBox(height: 20),
                  StatefulBuilder(
                    builder: (BuildContext context, void Function(void Function()) _) {
                      return Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: scaffoldColor, border: Border.all(width: .5, color: whiteColor)),
                        child: TextField(
                          style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: whiteColor),
                          controller: _authorController,
                          onChanged: (String value) {
                            if (value.length <= 1) {
                              _(() {});
                            }
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(16),
                            border: InputBorder.none,
                            hintText: "Author",
                            hintStyle: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: whiteColor),
                            prefix: _authorController.text.trim().isEmpty ? null : const Icon(FontAwesome.circle_check_solid, color: greenColor, size: 15),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  StatefulBuilder(
                    builder: (BuildContext context, void Function(void Function()) _) {
                      return Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: scaffoldColor, border: Border.all(width: .5, color: whiteColor)),
                        child: TextField(
                          maxLines: 5,
                          style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: whiteColor),
                          controller: _quoteController,
                          onChanged: (String value) {
                            if (value.length <= 1) {
                              _(() {});
                            }
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(16),
                            border: InputBorder.none,
                            hintText: "Quote",
                            hintStyle: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: whiteColor),
                            prefix: _quoteController.text.trim().isEmpty ? null : const Icon(FontAwesome.circle_check_solid, color: greenColor, size: 15),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: <Widget>[
                      InkWell(
                        splashColor: transparentColor,
                        highlightColor: transparentColor,
                        hoverColor: transparentColor,
                        onTap: () {
                          if (_quoteController.text.trim().isEmpty) {
                            showToast(context, "Please enter the quote", redColor);
                          } else {
                            user!.put(
                              "quotes",
                              (_quotes
                                    ..add(
                                      QuoteModel.fromJson(
                                        <String, dynamic>{
                                          'qid': const Uuid().v8g(),
                                          'timestamp': DateTime.now(),
                                          'author': _authorController.text.trim().isEmpty ? "UNKNOWN" : _authorController.text.trim().toUpperCase(),
                                          'quote': _quoteController.text.trim(),
                                          'favorite': false,
                                          'emojies': <String>[],
                                        },
                                      ),
                                    ))
                                  .map((QuoteModel e) => e.toJson())
                                  .toList(),
                            );
                            showToast(context, "quote added successfully", greenColor);
                            _authorController.clear();
                            _quoteController.clear();
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: greenColor),
                          child: Text("CONFIRM", style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: whiteColor)),
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        splashColor: transparentColor,
                        highlightColor: transparentColor,
                        hoverColor: transparentColor,
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: redColor),
                          child: Text("CANCEL", style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: whiteColor)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
        child: LottieBuilder.asset("assets/lotties/add.json", reverse: true, width: 80, height: 80),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<BoxEvent>(
          stream: user!.watch(key: "quotes"),
          builder: (BuildContext context, AsyncSnapshot<BoxEvent> snapshot) {
            if (snapshot.hasData || !snapshot.hasData) {
              _quotes = user!.get("quotes").map((dynamic e) => QuoteModel.fromJson(e)).toList().cast<QuoteModel>();
              return _quotes.isEmpty
                  ? Center(child: LottieBuilder.asset("assets/lotties/empty.json"))
                  : ListView.separated(
                      itemBuilder: (BuildContext context, int index) => Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: darkColor, borderRadius: BorderRadius.circular(5)),
                        child: Stack(
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        _computeTimestamp(_quotes[index].timestamp),
                                        style: GoogleFonts.itim(fontSize: 12, fontWeight: FontWeight.w500, color: whiteColor.withOpacity(.8)),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Wrap(
                                        children: <Widget>[
                                          InkWell(
                                            splashColor: transparentColor,
                                            hoverColor: transparentColor,
                                            highlightColor: transparentColor,
                                            onTap: () {},
                                            child: IconButton(
                                              onPressed: () async {
                                                Clipboard.setData(ClipboardData(text: _quotes[index].toJson().toString()));
                                                // ignore: use_build_context_synchronously
                                                showToast(context, "Text copied to clipboard", greenColor);
                                              },
                                              icon: const Icon(Bootstrap.clipboard2_fill, size: 15, color: pinkColor),
                                            ),
                                          ),
                                          InkWell(
                                            splashColor: transparentColor,
                                            hoverColor: transparentColor,
                                            highlightColor: transparentColor,
                                            onTap: () {},
                                            child: IconButton(
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
                                                            user!.put("quotes", _quotes..removeAt(index));
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
                                          ),
                                          InkWell(
                                            splashColor: transparentColor,
                                            hoverColor: transparentColor,
                                            highlightColor: transparentColor,
                                            onTap: () {},
                                            child: IconButton(
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
                                                          final List<Map<String, dynamic>> data = _quotes.map((QuoteModel e) => e.toJson()).toList();
                                                          data[index].update("emojies", (dynamic value) => value..add(emoji.char));
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
                                          ),
                                          _quotes[index].emojies.isEmpty
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
                                                                for (final String emoji in _quotes[index].emojies) emoji: _quotes[index].emojies.where((dynamic element) => element == emoji).length.toString(),
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
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Text(_quotes[index].author, style: GoogleFonts.itim(fontSize: 18, fontWeight: FontWeight.w500, color: whiteColor.withOpacity(.8))),
                                const SizedBox(height: 20),
                                Text(_quotes[index].quote, style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: whiteColor.withOpacity(.8))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 30),
                      itemCount: _quotes.length,
                    );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Loading());
            } else {
              return Errored(error: snapshot.error.toString());
            }
          },
        ),
      ),
    );
  }
}
