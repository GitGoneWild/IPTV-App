import 'package:equatable/equatable.dart';

/// Represents a content category
class CategoryModel extends Equatable {
  const CategoryModel({
    required this.id,
    required this.name,
    this.parentId,
    this.iconUrl,
    this.order = 0,
    this.type,
  });

  final String id;
  final String name;
  final String? parentId;
  final String? iconUrl;
  final int order;
  final CategoryType? type;

  CategoryModel copyWith({
    String? id,
    String? name,
    String? parentId,
    String? iconUrl,
    int? order,
    CategoryType? type,
  }) =>
      CategoryModel(
        id: id ?? this.id,
        name: name ?? this.name,
        parentId: parentId ?? this.parentId,
        iconUrl: iconUrl ?? this.iconUrl,
        order: order ?? this.order,
        type: type ?? this.type,
      );

  factory CategoryModel.fromXtream(
    Map<String, dynamic> json,
    CategoryType type,
  ) =>
      CategoryModel(
        id: json['category_id']?.toString() ?? '',
        name: json['category_name']?.toString() ?? '',
        parentId: json['parent_id']?.toString(),
        order: int.tryParse(json['order']?.toString() ?? '0') ?? 0,
        type: type,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'parentId': parentId,
        'iconUrl': iconUrl,
        'order': order,
        'type': type?.name,
      };

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'] as String,
        name: json['name'] as String,
        parentId: json['parentId'] as String?,
        iconUrl: json['iconUrl'] as String?,
        order: json['order'] as int? ?? 0,
        type: json['type'] != null
            ? CategoryType.values.firstWhere(
                (t) => t.name == json['type'],
                orElse: () => CategoryType.live,
              )
            : null,
      );

  @override
  List<Object?> get props => [id, name, parentId, iconUrl, order, type];
}

/// Category type
enum CategoryType {
  live,
  movie,
  series,
}
