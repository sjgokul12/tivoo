import 'package:flutter/foundation.dart';

/// One page from a paginated endpoint.
@immutable
class PageResult<T> {
  const PageResult({required this.items, required this.hasMore});

  final List<T> items;
  final bool hasMore;
}
