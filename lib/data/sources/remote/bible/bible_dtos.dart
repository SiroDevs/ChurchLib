// Package imports:
import 'package:json_annotation/json_annotation.dart';

part 'bible_dtos.g.dart';

@JsonSerializable()
class BibleLangDto {
  final String id;
  final String name;
  final String script;
  final String scriptDirection;

  BibleLangDto({
    this.id = '',
    this.name = '',
    this.script = '',
    this.scriptDirection = 'LTR',
  });

  factory BibleLangDto.fromJson(Map<String, dynamic> json) =>
      _$BibleLangDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BibleLangDtoToJson(this);
}

@JsonSerializable()
class BibleCountryDto {
  final String id;
  final String name;

  BibleCountryDto({this.id = '', this.name = ''});

  factory BibleCountryDto.fromJson(Map<String, dynamic> json) =>
      _$BibleCountryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BibleCountryDtoToJson(this);
}

/// One entry from `{group}/info.json`. `path` is the folder segment used
/// to fetch that translation's books/chapters/verses; falls back to
/// [abbreviation] when blank, same as Android's `resolvePath`.
@JsonSerializable()
class BibleInfoDto {
  final String name;
  final String description;
  final String abbreviation;
  final String tagline;
  final BibleLangDto language;
  final List<BibleCountryDto> countries;
  final String info;
  final String path;

  BibleInfoDto({
    this.name = '',
    this.description = '',
    this.abbreviation = '',
    this.tagline = '',
    BibleLangDto? language,
    this.countries = const [],
    this.info = '',
    this.path = '',
  }) : language = language ?? BibleLangDto();

  factory BibleInfoDto.fromJson(Map<String, dynamic> json) =>
      _$BibleInfoDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BibleInfoDtoToJson(this);

  /// First listed country's name, or "Other" — ported from
  /// Android's `BibleInfoDto.primaryCountryName()`.
  String get primaryCountryName {
    final first = countries.isNotEmpty ? countries.first.name : '';
    return first.trim().isNotEmpty ? first : 'Other';
  }
}

@JsonSerializable()
class BookDto {
  final String id;
  final String bibleId;
  final String abbreviation;
  final String name;
  final String nameLong;

  BookDto({
    this.id = '',
    this.bibleId = '',
    this.abbreviation = '',
    this.name = '',
    this.nameLong = '',
  });

  factory BookDto.fromJson(Map<String, dynamic> json) =>
      _$BookDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BookDtoToJson(this);
}

@JsonSerializable()
class ChapterDto {
  final String id;
  final String bibleId;
  final String bookId;
  final String number;
  final String reference;

  ChapterDto({
    this.id = '',
    this.bibleId = '',
    this.bookId = '',
    this.number = '',
    this.reference = '',
  });

  factory ChapterDto.fromJson(Map<String, dynamic> json) =>
      _$ChapterDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChapterDtoToJson(this);
}

/// A node in a chapter's rendered content tree (`{path}/verses/{book}/{n}.json`).
/// Mirrors Android's `ContentItemDto` — a `tag` node of name "verse" marks
/// where a new verse begins; `text` nodes carry the actual words, tagged
/// with a `verseId` attr; nodes can nest arbitrarily via [items].
///
/// [attrs] is parsed manually (not via json_serializable) because the
/// source JSON's attribute values are sometimes numbers or booleans, not
/// just strings — ported from Android's `LenientAttrsAdapter`, which
/// coerces every value to its string form rather than failing to parse.
class ContentItemDto {
  final String? name;
  final String type;
  final String? text;
  final Map<String, String>? attrs;
  final List<ContentItemDto>? items;

  ContentItemDto({
    this.name,
    this.type = '',
    this.text,
    this.attrs,
    this.items,
  });

  factory ContentItemDto.fromJson(Map<String, dynamic> json) {
    return ContentItemDto(
      name: json['name'] as String?,
      type: json['type'] as String? ?? '',
      text: json['text'] as String?,
      attrs: _parseLenientAttrs(json['attrs']),
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => ContentItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'text': text,
        'attrs': attrs,
        'items': items?.map((e) => e.toJson()).toList(),
      };

  static Map<String, String>? _parseLenientAttrs(dynamic raw) {
    if (raw == null) return null;
    if (raw is! Map) return null;
    final result = <String, String>{};
    raw.forEach((key, value) {
      if (value == null) {
        result[key.toString()] = '';
      } else {
        result[key.toString()] = value.toString();
      }
    });
    return result;
  }
}

/// Full content for one chapter (`{path}/verses/{book}/{n}.json`). Manually
/// implemented, like [ContentItemDto], rather than code-generated.
class ChapterContentDto {
  final String id;
  final String bibleId;
  final String number;
  final String bookId;
  final String reference;
  final int verseCount;
  final List<ContentItemDto> content;

  ChapterContentDto({
    this.id = '',
    this.bibleId = '',
    this.number = '',
    this.bookId = '',
    this.reference = '',
    this.verseCount = 0,
    this.content = const [],
  });

  factory ChapterContentDto.fromJson(Map<String, dynamic> json) {
    return ChapterContentDto(
      id: json['id'] as String? ?? '',
      bibleId: json['bibleId'] as String? ?? '',
      number: json['number'] as String? ?? '',
      bookId: json['bookId'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      verseCount: json['verseCount'] as int? ?? 0,
      content: (json['content'] as List<dynamic>? ?? [])
          .map((e) => ContentItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'bibleId': bibleId,
        'number': number,
        'bookId': bookId,
        'reference': reference,
        'verseCount': verseCount,
        'content': content.map((e) => e.toJson()).toList(),
      };
}
