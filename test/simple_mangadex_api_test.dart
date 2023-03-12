import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:simple_mangadex_api/api_types.dart';

import 'package:simple_mangadex_api/simple_mangadex_api.dart';

void main() {
  test('Manga class from MangaDex manga ID', () async {
    final printed = <String>[];
    final result = await runZoned(
      () async => await Manga.fromMangaDexMangaIdInfallible(
          "cddd1849-ab36-4304-8103-06ba4062b5e6", "en"),
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) {
          printed.add(line);
        },
      ),
    );

    print(result.formattedTags.toString());
  });
}
