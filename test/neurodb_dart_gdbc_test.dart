// Copyright (c) 2023- All nebula_dart_gdbc authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:neurodb_dart_gdbc/neurodb_dart_gdbc.dart';
import 'package:test/test.dart';

void main() async {
  DriverManager.registerDriver(NeuroDBDriver());

  var conn = await DriverManager.getConnection(
    'gdbc.neuro://127.0.0.1:8839',
  );

  var stmt = await conn.createStatement();

  test('Test List', () async {
    var rs = await conn.executeQuery('match (n)-[r]->(m) return n,r,m');
    print(rs);
  });

  test('Test PING', () async {
    var rs = await conn.executeQuery('RETURN 1');
    print(rs);
  });

  test('Test space', () async {
    var rs = await conn.executeQuery('show databases');
    print(rs);
  });

  test('Test stmt', () async {
    var rs = await stmt.executeQuery(gql: 'show databases');
    print(rs);
  });
}
