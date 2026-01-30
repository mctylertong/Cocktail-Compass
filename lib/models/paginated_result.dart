/// A generic paginated result wrapper for client-side pagination
class PaginatedResult<T> {
  final List<T> items;
  final int totalItems;
  final int currentPage;
  final int pageSize;
  final int totalPages;

  PaginatedResult({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.pageSize,
  }) : totalPages = (totalItems / pageSize).ceil();

  bool get hasNextPage => currentPage < totalPages;
  bool get hasPreviousPage => currentPage > 1;
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  /// Starting index for display (1-based)
  int get startIndex => totalItems == 0 ? 0 : ((currentPage - 1) * pageSize) + 1;

  /// Ending index for display
  int get endIndex {
    final end = currentPage * pageSize;
    return end > totalItems ? totalItems : end;
  }

  /// Creates a paginated result from a full list
  static PaginatedResult<T> fromList<T>(
    List<T> allItems, {
    int page = 1,
    int pageSize = 10,
  }) {
    final totalItems = allItems.length;
    final startIndex = (page - 1) * pageSize;
    final endIndex = startIndex + pageSize;

    final pageItems = startIndex < totalItems
        ? allItems.sublist(
            startIndex,
            endIndex > totalItems ? totalItems : endIndex,
          )
        : <T>[];

    return PaginatedResult<T>(
      items: pageItems,
      totalItems: totalItems,
      currentPage: page,
      pageSize: pageSize,
    );
  }

  /// Creates an empty paginated result
  static PaginatedResult<T> empty<T>({int pageSize = 10}) {
    return PaginatedResult<T>(
      items: [],
      totalItems: 0,
      currentPage: 1,
      pageSize: pageSize,
    );
  }

  /// Map items to a different type
  PaginatedResult<R> map<R>(R Function(T item) mapper) {
    return PaginatedResult<R>(
      items: items.map(mapper).toList(),
      totalItems: totalItems,
      currentPage: currentPage,
      pageSize: pageSize,
    );
  }

  @override
  String toString() {
    return 'PaginatedResult(page: $currentPage/$totalPages, items: ${items.length}/$totalItems)';
  }
}

/// Pagination state for ViewModels
class PaginationState {
  final int currentPage;
  final int pageSize;
  final int totalItems;
  final bool isLoadingMore;

  const PaginationState({
    this.currentPage = 1,
    this.pageSize = 10,
    this.totalItems = 0,
    this.isLoadingMore = false,
  });

  int get totalPages => totalItems == 0 ? 1 : (totalItems / pageSize).ceil();
  bool get hasNextPage => currentPage < totalPages;
  bool get hasPreviousPage => currentPage > 1;

  PaginationState copyWith({
    int? currentPage,
    int? pageSize,
    int? totalItems,
    bool? isLoadingMore,
  }) {
    return PaginationState(
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      totalItems: totalItems ?? this.totalItems,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  PaginationState reset() {
    return PaginationState(pageSize: pageSize);
  }
}
