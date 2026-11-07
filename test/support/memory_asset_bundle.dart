import 'dart:convert';

import 'package:flutter/services.dart';

class MemoryAssetBundle extends CachingAssetBundle {
  MemoryAssetBundle(this._assets);

  final Map<String, String> _assets;

  @override
  Future<ByteData> load(String key) async {
    final content = _assets[key];

    if (content == null) {
      throw Exception('Asset not found: $key');
    }

    return ByteData.sublistView(Uint8List.fromList(utf8.encode(content)));
  }
}
