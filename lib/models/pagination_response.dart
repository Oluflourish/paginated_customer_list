class PaginationResponse<T> {
  final T items;
  final int total;
  final int skip;
  final int limit;

  PaginationResponse({
    required this.items,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory PaginationResponse.fromJson(Map<String, dynamic> json, T data) {
    return PaginationResponse<T>(
      items: data,
      total: json['total'],
      skip: json['skip'],
      limit: json['limit'],
    );
  }
}
