import 'package:equatable/equatable.dart';

/// Represents a user profile
class ProfileModel extends Equatable {
  const ProfileModel({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.isKidsProfile = false,
    this.providerId,
    this.parentalPin,
    this.lockedCategories,
    this.lockedChannelIds,
    this.maxContentRating,
    this.createdAt,
    this.lastUsed,
  });

  final String id;
  final String name;
  final String? avatarUrl;
  final bool isKidsProfile;
  final String? providerId;
  final String? parentalPin;
  final List<String>? lockedCategories;
  final List<String>? lockedChannelIds;
  final String? maxContentRating;
  final DateTime? createdAt;
  final DateTime? lastUsed;

  ProfileModel copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    bool? isKidsProfile,
    String? providerId,
    String? parentalPin,
    List<String>? lockedCategories,
    List<String>? lockedChannelIds,
    String? maxContentRating,
    DateTime? createdAt,
    DateTime? lastUsed,
  }) =>
      ProfileModel(
        id: id ?? this.id,
        name: name ?? this.name,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        isKidsProfile: isKidsProfile ?? this.isKidsProfile,
        providerId: providerId ?? this.providerId,
        parentalPin: parentalPin ?? this.parentalPin,
        lockedCategories: lockedCategories ?? this.lockedCategories,
        lockedChannelIds: lockedChannelIds ?? this.lockedChannelIds,
        maxContentRating: maxContentRating ?? this.maxContentRating,
        createdAt: createdAt ?? this.createdAt,
        lastUsed: lastUsed ?? this.lastUsed,
      );

  /// Check if parental controls are enabled
  bool get hasParentalControls =>
      parentalPin != null && parentalPin!.isNotEmpty;

  /// Verify PIN
  bool verifyPin(String pin) => parentalPin == pin;

  /// Check if category is locked
  bool isCategoryLocked(String categoryId) =>
      lockedCategories?.contains(categoryId) ?? false;

  /// Check if channel is locked
  bool isChannelLocked(String channelId) =>
      lockedChannelIds?.contains(channelId) ?? false;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatarUrl': avatarUrl,
        'isKidsProfile': isKidsProfile,
        'providerId': providerId,
        'parentalPin': parentalPin,
        'lockedCategories': lockedCategories,
        'lockedChannelIds': lockedChannelIds,
        'maxContentRating': maxContentRating,
        'createdAt': createdAt?.toIso8601String(),
        'lastUsed': lastUsed?.toIso8601String(),
      };

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id: json['id'] as String,
        name: json['name'] as String,
        avatarUrl: json['avatarUrl'] as String?,
        isKidsProfile: json['isKidsProfile'] as bool? ?? false,
        providerId: json['providerId'] as String?,
        parentalPin: json['parentalPin'] as String?,
        lockedCategories:
            (json['lockedCategories'] as List<dynamic>?)?.cast<String>(),
        lockedChannelIds:
            (json['lockedChannelIds'] as List<dynamic>?)?.cast<String>(),
        maxContentRating: json['maxContentRating'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        lastUsed: json['lastUsed'] != null
            ? DateTime.parse(json['lastUsed'] as String)
            : null,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        avatarUrl,
        isKidsProfile,
        providerId,
        parentalPin,
        lockedCategories,
        lockedChannelIds,
        maxContentRating,
        createdAt,
        lastUsed,
      ];
}
