import 'package:neurodb_dart_gdbc/neurodb_dart_gdbc.dart';

class NeuroDbPreparedStatement extends NeuroDBStatement
    implements PreparedStatement {
  List<ParameterMetaData>? parameters;
  String gql;
  String Function(String, Map<String, dynamic>?)? render;

  NeuroDbPreparedStatement(super.conn,
      {this.parameters, required this.gql, this.render});

  @override
  Future<bool> execute({String? gql, Map<String, dynamic>? params}) async {
    var rs = await executeQuery(gql: gql, params: params);
    return rs.success;
  }

  @override
  Future<ResultSet> executeQuery(
      {String? gql, Map<String, dynamic>? params}) async {
    if (params != null && render != null) {
      gql = render?.call(gql ?? this.gql, params);
    }
    return super.executeQuery(gql: gql ?? this.gql, params: params);
  }

  @override
  Future<int> executeUpdate({String? gql, Map<String, dynamic>? params}) async {
    return super.executeUpdate(gql: gql, params: params);
  }
}
