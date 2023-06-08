part of neurodb_dart_gdbc;

class NeuroDBStatement extends Statement {
  NeuroDBStatement(NeuroDBConnection neuroDBConnection);

  @override
  Future<bool> execute({required String gql}) {
    // TODO: implement execute
    throw UnimplementedError();
  }

  @override
  Future<ResultSet> executeQuery({required String gql}) {
    // TODO: implement executeQuery
    throw UnimplementedError();
  }

  @override
  Future<int> executeUpdate({required String gql}) {
    // TODO: implement executeUpdate
    throw UnimplementedError();
  }
}
