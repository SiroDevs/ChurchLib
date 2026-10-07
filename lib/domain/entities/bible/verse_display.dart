class VerseDisplay {
  final String verseId;
  final int number;
  final String text;
  final String chapterId;
  final String bookId;

  VerseDisplay({
    this.verseId = '',
    this.number = 1,
    this.text = '',
    this.chapterId = '',
    this.bookId = '',
  });

  VerseDisplay copyWith({String? text}) => VerseDisplay(
        verseId: verseId,
        number: number,
        text: text ?? this.text,
        chapterId: chapterId,
        bookId: bookId,
      );

  factory VerseDisplay.fromJson(Map<String, dynamic> json) => VerseDisplay(
        verseId: json['verseId'] as String? ?? '',
        number: json['number'] as int? ?? 1,
        text: json['text'] as String? ?? '',
        chapterId: json['chapterId'] as String? ?? '',
        bookId: json['bookId'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'verseId': verseId,
        'number': number,
        'text': text,
        'chapterId': chapterId,
        'bookId': bookId,
      };
}
