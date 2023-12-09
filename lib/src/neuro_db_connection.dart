part of "../../neurodb_dart_gdbc.dart";

class NeuroDBConnection extends Connection {
  late Uri address;
  ndb.NeuroDBDriver? ndbDriver;

  NeuroDBConnection._create(this.address, {Map<String, dynamic>? properties});

  Future<void> _open() async {
    ndbDriver = ndb.NeuroDBDriver(address.host, address.port);
  }

  @override
  Future<void> close() async {
    await ndbDriver?.close();
  }

  @override
  Future<void> commit() {
    throw UnimplementedError();
  }

  @override
  Future<Statement> createStatement() {
    return Future.value(NeuroDBStatement(this));
  }

  @override
  Future<ResultSet> executeQuery(String gql,
      {Map<String, dynamic>? params}) async {
    if (ndbDriver == null) throw Exception('Connection is not open');
    ndb.ResultSet rs = await ndbDriver!.executeQuery(gql);
    if (rs.msg != null) {
      throw Exception(rs.msg);
    } else {
      return NeuroDBResultSet(rs);
    }
  }

  @override
  Future<int> executeUpdate(String gql) {
    throw UnimplementedError();
  }

  @override
  Future<bool> getAutoCommit() {
    throw UnimplementedError();
  }

  @override
  Future<ResultSetMetaData> getMetaData() {
    throw UnimplementedError();
  }

  @override
  Future<bool> isClosed() {
    throw UnimplementedError();
  }

  @override
  Future<PreparedStatement> prepareStatement(
    String gql, {
    String Function(String, Map<String, dynamic>?)? render,
  }) async {
    return NeuroDbPreparedStatement(this, gql: gql, render: render);
  }

  @override
  Future<PreparedStatement> prepareStatementWithParameters(
      String gql, List<ParameterMetaData> parameters) {
    throw UnimplementedError();
  }

  @override
  Future<void> rollback() {
    // TODO: implement rollback
    throw UnimplementedError();
  }

  @override
  Future<void> setAutoCommit(bool autoCommit) {
    // TODO: implement setAutoCommit
    throw UnimplementedError();
  }
}
