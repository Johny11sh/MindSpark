// ignore_for_file: file_names

class WatchlistModel {
  final String? id;
  final String? userId;
  final String? itemId;
  final String? itemType;
  final String? itemTitle;
  final String? itemImage;
  final DateTime? addedAt;
  final String? status;

  WatchlistModel({
    this.id,
    this.userId,
    this.itemId,
    this.itemType,
    this.itemTitle,
    this.itemImage,
    this.addedAt,
    this.status,
  });

  factory WatchlistModel.fromJson(Map<String, dynamic> json) {
    return WatchlistModel(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      itemId: json['item_id']?.toString(),
      itemType: json['item_type']?.toString(),
      itemTitle: json['item_title']?.toString(),
      itemImage: json['item_image']?.toString(),
      addedAt: json['added_at'] != null 
          ? DateTime.tryParse(json['added_at'].toString()) 
          : null,
      status: json['status']?.toString() ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'item_id': itemId,
      'item_type': itemType,
      'item_title': itemTitle,
      'item_image': itemImage,
      'added_at': addedAt?.toIso8601String(),
      'status': status,
    };
  }

  WatchlistModel copyWith({
    String? id,
    String? userId,
    String? itemId,
    String? itemType,
    String? itemTitle,
    String? itemImage,
    DateTime? addedAt,
    String? status,
  }) {
    return WatchlistModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      itemId: itemId ?? this.itemId,
      itemType: itemType ?? this.itemType,
      itemTitle: itemTitle ?? this.itemTitle,
      itemImage: itemImage ?? this.itemImage,
      addedAt: addedAt ?? this.addedAt,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'WatchlistModel(id: $id, itemTitle: $itemTitle, itemType: $itemType, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WatchlistModel &&
        other.id == id &&
        other.itemId == itemId &&
        other.itemType == itemType;
  }

  @override
  int get hashCode {
    return id.hashCode ^ itemId.hashCode ^ itemType.hashCode;
  }
}
