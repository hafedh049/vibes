import 'package:date_format/date_format.dart';
import 'package:emoji_selector/emoji_selector.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:vibes/utils/helpers/errored.dart';
import 'package:vibes/utils/helpers/loading.dart';
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

  final GlobalKey<State<StatefulWidget>> _reactsKey = GlobalKey<State<StatefulWidget>>();
  final GlobalKey<State<StatefulWidget>> _messagesKey = GlobalKey<State<StatefulWidget>>();

  Future<bool> _load() async {
    _quotes = user!.get("quotes").map((dynamic e) => QuoteModel.fromJson(e)).toList().cast<QuoteModel>();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      floatingActionButton: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: scaffoldColor, border: Border.all(width: .5, color: whiteColor)),
                    child: TextField(
                      style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: whiteColor),
                      controller: _authorController,
                      onChanged: (String value) {},
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(16),
                        border: InputBorder.none,
                        hintText: "From",
                        hintStyle: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: whiteColor),
                        prefix: _authorController.text.trim().isEmpty ? : ,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        child: LottieBuilder.asset("assets/lotties/add.json", reverse: true, width: 80, height: 80),
      ),
      body: Padding(
        padding: const EdgeInsets.all(36),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: darkColor, borderRadius: BorderRadius.circular(15)),
          child: FutureBuilder<bool>(
              future: _load(),
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                return snapshot.hasError
                    ? Errored(error: snapshot.error.toString())
                    : snapshot.connectionState == ConnectionState.waiting
                        ? const Center(child: Loading())
                        : _quotes.isEmpty
                            ? Center(child: LottieBuilder.asset("assets/lotties/empty.json"))
                            : StatefulBuilder(
                                key: _messagesKey,
                                builder: (BuildContext context, void Function(void Function()) _) {
                                  return ListView.separated(
                                    itemBuilder: (BuildContext context, int index) => Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(color: scaffoldColor, borderRadius: BorderRadius.circular(15)),
                                      child: Stack(
                                        children: <Widget>[
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text(
                                                _computeTimestamp(_quotes[index].timestamp),
                                                style: GoogleFonts.itim(fontSize: 12, fontWeight: FontWeight.w500, color: whiteColor.withOpacity(.8)),
                                              ),
                                              const SizedBox(height: 10),
                                            ],
                                          ),
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                InkWell(
                                                  splashColor: transparentColor,
                                                  hoverColor: transparentColor,
                                                  highlightColor: transparentColor,
                                                  onTap: () {},
                                                  child: IconButton(
                                                    onPressed: () async {
                                                      Clipboard.setData(ClipboardData(text: _quotes[index].toString()));
                                                      // ignore: use_build_context_synchronously
                                                      showToast(context, "Text copied to clipboard", greenColor);
                                                    },
                                                    icon: const Icon(Bootstrap.clipboard, size: 20, color: pinkColor),
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
                                                                  _messagesKey.currentState!.setState(() {});
                                                                  Navigator.pop(contextt);
                                                                },
                                                                child: Text("Apply", style: GoogleFonts.itim(fontSize: 14, fontWeight: FontWeight.w500, color: whiteColor)),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    icon: const Icon(Bootstrap.x_octagon_fill, size: 20, color: pinkColor),
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
                                                            color: scaffoldColor,
                                                            padding: const EdgeInsets.all(24),
                                                            height: 300,
                                                            child: SingleChildScrollView(
                                                              child: EmojiSelector(
                                                                withTitle: true,
                                                                onSelected: (EmojiData emoji) {
                                                                  _quotes[index].emojies.add(emoji.char);
                                                                  user!.put("quotes", user!.get("quotes")..update("emojies", (dynamic value) => _quotes[index].emojies));
                                                                  _reactsKey.currentState!.setState(() {});
                                                                  Navigator.of(context).pop();
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      icon: const Icon(Bootstrap.emoji_smile, size: 20, color: pinkColor)),
                                                ),
                                                StatefulBuilder(
                                                  key: _reactsKey,
                                                  builder: (BuildContext context, void Function(void Function()) _) {
                                                    return _quotes[index].emojies.isEmpty
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
                                                          );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 30),
                                    itemCount: _quotes.length,
                                  );
                                });
              }),
        ),
      ),
    );
  }
}
