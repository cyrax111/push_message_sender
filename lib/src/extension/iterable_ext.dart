/// Separate this iterable on parts with [partLength] length,
/// push them to [separator] then the result concatenated
extension Separator<E> on Iterable<E> {
  Future<Iterable<T>> separate<T>({
    required int partLength,
    required Future<T> Function(Iterable<E> part) separator,
  }) async {
    final partsAmount = (length / partLength).ceil();
    final results = <T>[];
    for (var part = 0; part < partsAmount; part++) {
      final from = partLength * part;
      final to = partLength * (part + 1);
      final iterablePart = skip(from).take(to);
      results.add(await separator(iterablePart));
    }
    return results;
  }
}
