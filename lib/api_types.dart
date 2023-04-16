import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:simple_mangadex_api/exceptions.dart';

class Chapter {
  String id;
  String userSetTitle;
  final Map<String, String> titles;
  final String chapterString;
  final List<String> others;
  final int count;
  final List<Relationship> relationships;
  String? title;
  String? translatedLanguage;
  int? pages;
  int? version;
  List<String>? _imageLinks;
  List<String>? _imageLinksDataSaver;
  String? _coverLink;

  List<String> get infallibleImageLinks {
    if (chapterString == "-1" && count == -1) {
      throw OperationOnErrStateChapterException();
    }
    return _imageLinks!;
  }

  List<String>? get imageLinksFallible {
    return _imageLinks;
  }

  Future<List<String>> get imageLinks async {
    if (chapterString == "-1" && count == -1) {
      throw OperationOnErrStateChapterException();
    }
    if (pages == 0) throw InvalidChapterException();

    if (_imageLinks != null) {
      return _imageLinks!;
    }

    final res = await http.get(
      Uri.parse("https://api.mangadex.org/at-home/server/$id"),
      headers: {
        HttpHeaders.userAgentHeader: 'all_media/1.0',
      },
    );

    if (res.statusCode >= 400) {
      throw res.reasonPhrase.toString();
    }

    final decodedBody = jsonDecode(res.body);

    final baseUrl = decodedBody['baseUrl'] as String;
    final hash = decodedBody['chapter']['hash'] as String;
    final data = (decodedBody['chapter']['data'] as List<dynamic>)
        .cast<String>()
        .map((link) => "$baseUrl/data/$hash/$link")
        .toList();
    final dataSaver = (decodedBody['chapter']['dataSaver'] as List<dynamic>)
        .cast<String>()
        .map((link) => "$baseUrl/data/$hash/$link")
        .toList();

    _imageLinks = data;
    _imageLinksDataSaver = dataSaver;
    _coverLink = data.first;

    return _imageLinks!;
  }

  Future<Chapter> get data async {
    if (chapterString == "-1" && count == -1) {
      throw OperationOnErrStateChapterException();
    }
    if (this.pages != null) return this;

    final getChapterRes = await http
        .get(Uri.parse("https://api.mangadex.org/chapter/$id"), headers: {
      HttpHeaders.userAgentHeader: 'all_media/1.0',
    });

    if (getChapterRes.statusCode >= 400) {
      throw getChapterRes.reasonPhrase.toString();
    }

    final decodeChapterRes = jsonDecode(getChapterRes.body);

    final pages = decodeChapterRes['data']['attributes']['pages'] as int;

    if (pages == 0 && others.isNotEmpty) {
      final getChapterResInner = await http.get(
        Uri.parse("https://api.mangadex.org/chapter/${others.first}"),
        headers: {
          HttpHeaders.userAgentHeader: 'all_media/1.0',
        },
      );

      id = others.first;
      others.remove(id);

      final decodeChapterResInner = jsonDecode(getChapterResInner.body);

      final pages = decodeChapterResInner['data']['attributes']['pages'] as int;
      final version =
          decodeChapterResInner['data']['attributes']['version'] as int;
      final String title =
          decodeChapterResInner['data']['attributes']['title'] ?? "";
      final translatedLanguage = decodeChapterResInner['data']['attributes']
          ['translatedLanguage'] as String;

      this.pages = pages;
      this.version = version;
      this.title = title;
      this.translatedLanguage = translatedLanguage;

      return this;
    }

    final version = decodeChapterRes['data']['attributes']['version'] as int;
    final String title = decodeChapterRes['data']['attributes']['title'] ?? "";
    final translatedLanguage =
        decodeChapterRes['data']['attributes']['translatedLanguage'] as String;

    this.pages = pages;
    this.version = version;
    this.title = title;
    this.translatedLanguage = translatedLanguage;

    return this;
  }

  Future<List<String>> get dataSaveImageLinks async {
    if (chapterString == "-1" && count == -1) {
      throw OperationOnErrStateChapterException();
    }
    if (pages == 0) throw InvalidChapterException();

    if (_imageLinksDataSaver != null) {
      return _imageLinksDataSaver!;
    }

    final res = await http.get(
      Uri.parse("https://api.mangadex.org/at-home/server/$id"),
      headers: {
        HttpHeaders.userAgentHeader: 'all_media/1.0',
      },
    );

    if (res.statusCode >= 400) {
      throw res.reasonPhrase.toString();
    }

    final decodedBody = jsonDecode(res.body);

    final baseUrl = decodedBody['baseUrl'] as String;
    final hash = decodedBody['chapter']['hash'] as String;
    final data = (decodedBody['chapter']['data'] as List<dynamic>)
        .cast<String>()
        .map((link) => "$baseUrl/data/$hash/$link")
        .toList();
    final dataSaver = (decodedBody['chapter']['dataSaver'] as List<dynamic>)
        .cast<String>()
        .map((link) => "$baseUrl/data/$hash/$link")
        .toList();

    _imageLinks = data;
    _imageLinksDataSaver = dataSaver;
    _coverLink = data.first;

    return _imageLinksDataSaver!;
  }

  Future<String> get coverLink async {
    if (chapterString == "-1" && count == -1) {
      throw OperationOnErrStateChapterException();
    }
    if (pages == 0) throw InvalidChapterException();

    if (_coverLink != null) {
      return _coverLink!;
    }

    final res = await http.get(
      Uri.parse("https://api.mangadex.org/at-home/server/$id"),
      headers: {
        HttpHeaders.userAgentHeader: 'all_media/1.0',
      },
    );

    if (res.statusCode >= 400) {
      throw res.reasonPhrase.toString();
    }

    final decodedBody = jsonDecode(res.body);

    final baseUrl = decodedBody['baseUrl'] as String;
    final hash = decodedBody['chapter']['hash'] as String;
    final data = (decodedBody['chapter']['data'] as List<dynamic>)
        .cast<String>()
        .map((link) => "$baseUrl/data/$hash/$link")
        .toList();
    final dataSaver = (decodedBody['chapter']['dataSaver'] as List<dynamic>)
        .cast<String>()
        .map((link) => "$baseUrl/data/$hash/$link")
        .toList();

    _imageLinks = data;
    _imageLinksDataSaver = dataSaver;
    _coverLink = data.first;

    return _coverLink!;
  }

  static Chapter errState() {
    return Chapter(
      chapterString: "-1",
      count: -1,
      id: "-1",
      others: [],
      titles: {},
      relationships: [],
    );
  }

  Chapter({
    this.userSetTitle = "",
    required this.chapterString,
    required this.count,
    required this.id,
    required this.others,
    required this.titles,
    required this.relationships,
  });
}

class Manga {
  final List<Chapter> chapters;
  final Map<String, String> titles;
  final Map<String, String> description;
  final Map<String, String> links;
  final String id;
  final String coverArtLink;
  final String publicationDemographic;
  final String year;
  final String status;
  final String contentRating;
  final List<Relationship> relationships;
  final List<Tag> tags;

  static Future<Manga> fromMangaDexMangaIdInfallible(
      String mangaId, String lang) async {
    final res = await http.get(
      Uri.parse("https://api.mangadex.org/manga/$mangaId"),
      headers: {
        HttpHeaders.userAgentHeader: 'all_media/1.0',
      },
    );

    if (res.statusCode >= 400) {
      throw res.reasonPhrase.toString();
    }

    final decodedBody = jsonDecode(res.body);

    final String id = decodedBody['data']['id'];
    final String publicationDemographic =
        decodedBody['data']['attributes']['publicationDemographic'] ?? "N/A";
    final String year =
        ((decodedBody['data']['attributes']['year'] as int?) ?? -1).toString();
    final String status = decodedBody['data']['attributes']['status'] ?? "N/A";
    final String contentRating =
        decodedBody['data']['attributes']['contentRating'] ?? "N/A";
    final Map<String, String> titles = Map.fromEntries(
        (decodedBody['data']['attributes']['altTitles'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map((map) => MapEntry(map.keys.first, map.values.first)));

    final Map<String, String> titleEntry =
        (decodedBody['data']['attributes']['title'] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, value))
            .cast();
    titles.addAll(titleEntry);
    final Map<String, String> descriptions = (decodedBody['data']['attributes']
            ['description'] as Map<String, dynamic>)
        .cast<String, String>();
    final Map<String, String> links =
        (decodedBody['data']['attributes']['links'] as Map<String, dynamic>)
            .cast();

    final List<Relationship> relationships =
        (decodedBody['data']['relationships'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map((relationship) => Relationship.fromMap(relationship))
            .toList();

    final coverArtId =
        relationships.singleWhere((element) => element.type == "cover_art").id;
    final coverArtRes = await http.get(
      Uri.parse("https://api.mangadex.org/cover/$coverArtId"),
      headers: {HttpHeaders.userAgentHeader: 'all_media/1.0'},
    );

    final decodedCoverArtBody = jsonDecode(coverArtRes.body);

    final coverArtFilename =
        decodedCoverArtBody['data']['attributes']['fileName'] as String;
    final coverArtLink =
        "https://uploads.mangadex.org/covers/$id/$coverArtFilename";

    final List<Tag> tags =
        (decodedBody['data']['attributes']['tags'] as List<dynamic>).map((tag) {
      final id = tag['id'] as String;
      final attributes = tag['attributes'];
      final names = attributes['name'] as Map<String, dynamic>;
      final descriptions = attributes['description'] as Map<String, dynamic>;
      final group = attributes['group'] as String;
      final version = attributes['version'] as int;
      final relationships =
          ((attributes['relationships'] as List<dynamic>?) ?? [])
              .map((relationship) => Relationship.fromMap(relationship))
              .toList();

      return Tag(
          group: group,
          id: id,
          tagDescriptions: descriptions.cast(),
          tagNames: names.cast(),
          version: version,
          relationships: relationships);
    }).toList();

    if (!titles.keys.contains(lang)) {
      throw NoTranslatedLanguageException();
    }

    final aggregateRes = await http.get(
      Uri.parse(
          "https://api.mangadex.org/manga/$mangaId/aggregate?translatedLanguage%5B%5D=$lang"),
      headers: {
        HttpHeaders.userAgentHeader: 'all_media/1.0',
      },
    );

    final decodedAggregateRes = jsonDecode(aggregateRes.body);

    // Volumes have:
    //     count -> int,
    //     volume -> String
    // Chapters have:
    //     chapter -> String,
    //     id -> String,
    //     others -> List<String>,
    //     count -> int

    final List<List<Chapter>> chapters = await Future.wait(
        (decodedAggregateRes['volumes'] as Map<String, dynamic>)
            .keys
            .map((volumeKey) async {
      final volume = decodedAggregateRes['volumes'][volumeKey];

      final List<Chapter> volChapters = await Future.wait(
          (volume['chapters'] as Map<String, dynamic>)
              .values
              .map((chaptersVal) async {
        final chapterString = chaptersVal['chapter'] as String;
        String id = chaptersVal['id'] as String;
        final count = chaptersVal['count'] as int;
        final List<String> others =
            (chaptersVal['others'] as List<dynamic>).cast<String>();

        return Chapter(
          chapterString: chapterString,
          count: count,
          id: id,
          others: others,
          titles: titles,
          relationships: relationships,
        );
      }).toList());

      return volChapters;
    }));

    return Manga(
      chapters: chapters
          .fold([], (previousValue, element) => previousValue..addAll(element)),
      contentRating: contentRating,
      description: descriptions,
      id: id,
      links: links,
      coverArtLink: coverArtLink,
      publicationDemographic: publicationDemographic,
      relationships: relationships,
      status: status,
      tags: tags,
      titles: titles,
      year: year,
    );
  }

  List<Chapter> get sortedChapters {
    return chapters.reversed.toList();
  }

  List<String> get formattedTags {
    return tags.map((tag) => tag.tagNames.values).fold<List<String>>(
        [], (previousValue, element) => [...previousValue, ...element]);
  }

  // FIXME
  static Future<bool> isValidId(String mangaId) async {
    final res = await http.get(
      Uri.parse("https://api.mangadex.org/manga/$mangaId"),
      headers: {
        HttpHeaders.userAgentHeader: 'all_media/1.0',
      },
    );

    if (res.statusCode >= 400) {
      return false;
    }

    return true;
  }

  const Manga({
    required this.chapters,
    required this.contentRating,
    required this.coverArtLink,
    required this.description,
    required this.id,
    required this.links,
    required this.publicationDemographic,
    required this.relationships,
    required this.status,
    required this.tags,
    required this.titles,
    required this.year,
  });
}

class Tag {
  final String id;
  final Map<String, String> tagNames;
  final Map<String, String> tagDescriptions;
  final String group;
  final int version;
  final List<Relationship> relationships;

  const Tag({
    required this.group,
    required this.id,
    required this.tagDescriptions,
    required this.tagNames,
    required this.version,
    required this.relationships,
  });
}

class Relationship {
  final String id;
  final String type;
  final Map<String, String> misc;

  static Relationship fromMap(Map<String, dynamic> map) {
    final id = (map['id'] as String?) ?? "N/A";
    final type = (map['type'] as String?) ?? "N/A";

    map.removeWhere((key, value) => key == 'id' || key == 'type');

    return Relationship(id: id, type: type, misc: map.cast<String, String>());
  }

  const Relationship({
    required this.id,
    required this.type,
    required this.misc,
  });
}
