import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/tip.dart';

/// Loads the bundled, offline tip content from assets.
class AssetTipSource {
  final String assetPath;
  const AssetTipSource({this.assetPath = 'assets/data/tips.json'});

  Future<List<Tip>> load() async {
    final raw = await rootBundle.loadString(assetPath);
    final list = json.decode(raw) as List<dynamic>;
    return list
        .map((e) => Tip.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }
}
