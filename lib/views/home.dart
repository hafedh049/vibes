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
import 'package:vibes/views/item.dart';

import '../models/quote_model.dart';
import '../utils/callbacks.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<QuoteModel> _quotes = <QuoteModel>[];

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
                  ),
                ],
              ),
            ),
          );
        },
        child: LottieBuilder.asset("assets/lotties/add.json", reverse: true, width: 80, height: 80),
      )
          .animate(
            onComplete: (AnimationController controller) => controller.repeat(reverse: true),
          )
          .shakeX(delay: 3.seconds, duration: 500.ms, hz: 8),
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
                      itemBuilder: (BuildContext context, int index) => Item(quotes: _quotes, index: index),
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
