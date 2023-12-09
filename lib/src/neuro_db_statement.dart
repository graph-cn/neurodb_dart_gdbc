part of "../../neurodb_dart_gdbc.dart";

class NeuroDBStatement extends Statement {
  final NeuroDBConnection _conn;
  NeuroDBStatement(this._conn);

  @override
  Future<bool> execute({Map<String, dynamic>? params, String? gql}) async {
    var rs = await executeQuery(gql: gql);
    return rs.success;
  }

  @override
  Future<ResultSet> executeQuery(
      {Map<String, dynamic>? params, String? gql}) async {
    if (gql == null) {
      throw GdbcQueryException(message: 'gql is null');
    }
    return await _conn.executeQuery(gql, params: params);
  }

  @override
  Future<int> executeUpdate({Map<String, dynamic>? params, String? gql}) {
    // TODO: implement executeUpdate
    throw UnimplementedError();
  }
}
