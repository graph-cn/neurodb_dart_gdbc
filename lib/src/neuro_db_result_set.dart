part of neurodb_dart_gdbc;

class NeuroDBResultSet extends ResultSet {
  @override
  List<ValueMetaData> metas = [];

  @override
  List<List> rows = [];

  NeuroDBResultSet(ndb.ResultSet rs) {
    ValueMetaData? meta = ValueMetaData();
    List<List>? rows = _handleValue(rs.recordSet, meta);
    success = true;
    metas = meta.submetas;
    this.rows = rows ?? [];
  }

  static dynamic _handleValue(
    dynamic v,
    ValueMetaData meta, {
    ValueMetaData? parent,
    List? parentVal,
    String? Function(int, dynamic)? nameGetter,
  }) {
    var type = typeGetter.entries.firstWhere((getter) => getter.value(v)).key;
    meta.type = type;
    var val = typeHandler[type]?.call(v, meta, nameGetter);
    parent?.addSubmeta(meta, parentVal, val);
    return val;
  }

/*
  const int VO_STRING = 1;
  const int VO_NUM = 2;
  const int VO_STRING_ARRY = 3;
  const int VO_NUM_ARRY = 4;
  const int VO_NODE = 5;
  const int VO_LINK = 6;
  const int VO_PATH = 7;
  const int VO_VAR = 8;
  const int VO_VAR_PATTERN = 9;
*/
  static Map<GdbTypes, bool Function(dynamic)> typeGetter = {
    GdbTypes.none: (dynamic p0) =>
        p0 == null || (p0 is ndb.ColVal && p0.val == null),
    GdbTypes.prop: (v) => v is Map<String, dynamic>,
    GdbTypes.string: (dynamic p0) =>
        (p0 is ndb.ColVal && p0.type == ndb.VO_STRING) || p0 is String,
    GdbTypes.dataSet: (v) => v is ndb.RecordSet,
    GdbTypes.int: (dynamic p0) => p0 is int,
    GdbTypes.double: (dynamic p0) => p0.type == ndb.VO_NUM || p0 is num,
    GdbTypes.list: (dynamic p0) =>
        p0.type == ndb.VO_STRING_ARRY || p0.type == ndb.VO_NUM_ARRY,
    GdbTypes.node: (dynamic p0) => p0.type == ndb.VO_NODE,
    GdbTypes.relationship: (dynamic p0) => p0.type == ndb.VO_LINK,
    GdbTypes.path: (dynamic p0) => p0.type == ndb.VO_PATH,
    GdbTypes.unknown: (dynamic p0) => true,
  };

  static Map<
          GdbTypes,
          dynamic Function(
              dynamic, ValueMetaData, String? Function(int, dynamic)? nget)>
      typeHandler = {
    GdbTypes.none: (v, m, nget) => null,
    GdbTypes.prop: (v, m, nget) => _handleProp(v, m),
    GdbTypes.string: (v, m, nget) => v is ndb.ColVal ? v.getString() : v,
    GdbTypes.dataSet: (v, m, nget) => _handleDataSet(v, m, nget),
    GdbTypes.int: (v, m, nget) => v,
    GdbTypes.double: (v, m, nget) =>
        v is ndb.ColVal ? (v.val is double ? v.val : v.getNum()) : v,
    GdbTypes.list: (v, m, nget) => _handleList(v, m, nget),
    GdbTypes.node: (v, m, nget) => _handleNode(v.getNode(), m, nget),
    GdbTypes.relationship: (v, m, nget) =>
        _handleRelationship(v.getLink(), m, nget),
    GdbTypes.path: (v, m, nget) => _handlePath(v.getPath(), m, nget),
    GdbTypes.unknown: (v, m, nget) => v is ndb.ColVal ? v.val : v,
  };

  static _handleList(ndb.ColVal col, ValueMetaData meta,
      String? Function(int p1, dynamic p2)? nget) {
    var values = col.type == ndb.VO_STRING_ARRY
        ? col.getStringArry()
        : col.getNumArray();
    var list = [];
    for (var v in values) {
      ValueMetaData valueMeta = ValueMetaData()
        ..name = nget?.call(values.indexOf(v), v)
        ..type = GdbTypes.unknown;
      _handleValue(v, valueMeta, parent: meta, parentVal: list);
    }
    return list;
  }

  static _handleNode(
    ndb.Node v,
    ValueMetaData meta,
    String? Function(int p1, dynamic p2)? nget,
  ) {
    var nodeData = [];

    // handle id
    ValueMetaData idMeta = ValueMetaData()..name = MetaKey.nodeId;
    var idVal = _handleValue(v.id, idMeta);
    meta.addSubmeta(idMeta, nodeData, idVal);

    // handle labels
    for (var i = 0; i < v.labels.length; i++) {
      ValueMetaData tagMeta = ValueMetaData()..name = v.labels[i];
      var tagVal = _handleValue(v.properties, tagMeta);
      meta.addSubmeta(tagMeta, nodeData, tagVal);
    }

    return nodeData;
  }

  static _handleRelationship(
    ndb.Link v,
    ValueMetaData meta,
    String? Function(int p1, dynamic p2)? nget,
  ) {
    var edgeData = [];
    ValueMetaData startNodeId = ValueMetaData()..name = MetaKey.startId;
    _handleValue(v.startNodeId, startNodeId, parent: meta, parentVal: edgeData);

    ValueMetaData idMeta = ValueMetaData()..name = MetaKey.relationshipId;
    _handleValue(v.id, idMeta, parent: meta, parentVal: edgeData);

    ValueMetaData endNodeId = ValueMetaData()..name = MetaKey.endId;
    _handleValue(v.endNodeId, endNodeId, parent: meta, parentVal: edgeData);

    ValueMetaData edgeMeta = ValueMetaData()..name = v.type;
    _handleValue(v.properties, edgeMeta, parent: meta, parentVal: edgeData);

    return edgeData;
  }

  static _handlePath(
      v, ValueMetaData m, String? Function(int p1, dynamic p2)? nget) {}

  static _handleProp(Map<String, dynamic> props, ValueMetaData meta) {
    var propsVal = [];
    props.forEach((key, value) {
      var submeta = ValueMetaData()..name = key;
      var val = _handleValue(value, submeta);
      meta.addSubmeta(submeta, propsVal, val);
    });
    return propsVal;
  }

  static _handleDataSet(ndb.RecordSet? dataSet, ValueMetaData meta,
      String? Function(int p1, dynamic p2)? nget) {
    if (dataSet == null) {
      return [];
    }
    var rows = [];
    var colLen = dataSet.records.isNotEmpty ? dataSet.records[0].length : 0;

    var cols = List.filled(colLen, '');
    // var cols = dataSet.keyNames;
    meta.submetas.addAll(
      cols
          .map(
            (e) => ValueMetaData()
              ..name = e
              ..type = GdbTypes.unknown,
          )
          .toList(),
    );

    rows = dataSet.records
        .map((row) => List<dynamic>.filled(cols.length, null))
        .toList();

    for (var r = 0; r < dataSet.records.length; r++) {
      for (var c = 0; c < dataSet.records[r].length; c++) {
        var value = dataSet.records[r][c];
        var submeta = meta.submetas[c];
        rows[r][c] = _handleValue(value, submeta);
      }
    }
    return rows;
  }
}
