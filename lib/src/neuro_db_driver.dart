part of "../../neurodb_dart_gdbc.dart";

class NeuroDBDriver extends Driver {
  @override
  bool acceptsURL(String url) {
    return url.startsWith('gdbc.neuro:');
  }

  @override
  Future<Connection> connect(
    String url, {
    Map<String, dynamic>? properties,
  }) async {
    var address = _parseURL(url);
    address.queryParameters.forEach((key, value) {
      properties![key] = value;
    });
    var conn = NeuroDBConnection._create(address, properties: properties);
    await conn._open();
    return conn;
  }

  Uri _parseURL(String url) {
    var uri = Uri.parse(url);
    if (uri.scheme != 'gdbc.neuro' || uri.host.isEmpty || uri.port <= 0) {
      throw ArgumentError('Invalid URL: $url');
    }
    return uri;
  }
}
