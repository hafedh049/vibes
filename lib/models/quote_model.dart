final class QuoteModel {
  final String qid;
  final DateTime timestamp;
  final String author;
  final String quote;
  final bool favorite;
  List<String> emojies;

  QuoteModel({
    required this.qid,
    required this.timestamp,
    required this.author,
    required this.quote,
    required this.favorite,
    required this.emojies,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      qid: json['qid'],
      timestamp: json['timestamp'],
      author: json['author'],
      quote: json['quote'],
      favorite: json['favorite'],
      emojies: json['emojies'],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'qid': qid,
      'timestamp': timestamp,
      'author': author,
      'quote': quote,
      'favorite': favorite,
      'emojies': emojies,
    };
  }
}
