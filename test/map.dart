import 'dart:collection';

void main() {
  final map1 = <String, Object>{
    'one': {
      'aaa': 123,
      'bbb': 321,
    },
  };
  final map2 = <String, Object>{
    'two': {
      'aaa': 123,
      'bbb': 321,
    },
  };
  map1.addAll(map2);
  print(map1);

  final d = [];
  ListBase;
  print(d.runtimeType);
}
