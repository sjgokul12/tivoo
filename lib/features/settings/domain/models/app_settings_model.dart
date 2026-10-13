class BlockedUserModel {
  final String id;
  final String name;
  final String username;
  final String avatarUrl;

  const BlockedUserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.avatarUrl,
  });
}

class PrivacySettings {
  final bool isPrivateAccount;
  final bool showActivityStatus;
  final bool is2FAEnabled;
  final List<BlockedUserModel> blockedUsers;

  const PrivacySettings({
    this.isPrivateAccount = false,
    this.showActivityStatus = true,
    this.is2FAEnabled = false,
    this.blockedUsers = const [
      BlockedUserModel(
        id: 'blocked_1',
        name: 'Alex Spammer',
        username: '@spammer_alex',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
      ),
      BlockedUserModel(
        id: 'blocked_2',
        name: 'Crypto Bot 99',
        username: '@cryptobot_free',
        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
      ),
      BlockedUserModel(
        id: 'blocked_3',
        name: 'Troll Master',
        username: '@troll_anonymous',
        avatarUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=200',
      ),
    ],
  });

  PrivacySettings copyWith({
    bool? isPrivateAccount,
    bool? showActivityStatus,
    bool? is2FAEnabled,
    List<BlockedUserModel>? blockedUsers,
  }) {
    return PrivacySettings(
      isPrivateAccount: isPrivateAccount ?? this.isPrivateAccount,
      showActivityStatus: showActivityStatus ?? this.showActivityStatus,
      is2FAEnabled: is2FAEnabled ?? this.is2FAEnabled,
      blockedUsers: blockedUsers ?? this.blockedUsers,
    );
  }
}

class NotificationSettings {
  final bool muteAll;
  final bool likes;
  final bool comments;
  final bool followers;
  final bool directMessages;
  final bool liveAlerts;
  final bool giftsReceived;

  const NotificationSettings({
    this.muteAll = false,
    this.likes = true,
    this.comments = true,
    this.followers = true,
    this.directMessages = true,
    this.liveAlerts = true,
    this.giftsReceived = true,
  });

  NotificationSettings copyWith({
    bool? muteAll,
    bool? likes,
    bool? comments,
    bool? followers,
    bool? directMessages,
    bool? liveAlerts,
    bool? giftsReceived,
  }) {
    return NotificationSettings(
      muteAll: muteAll ?? this.muteAll,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      followers: followers ?? this.followers,
      directMessages: directMessages ?? this.directMessages,
      liveAlerts: liveAlerts ?? this.liveAlerts,
      giftsReceived: giftsReceived ?? this.giftsReceived,
    );
  }
}

class LiveContentSettings {
  final bool allowComments;
  final bool allowLiveInvitations;
  final bool acceptVirtualGifts;
  final bool filterMatureContent;
  final String contentLanguage;
  final bool autoplayWifiOnly;

  const LiveContentSettings({
    this.allowComments = true,
    this.allowLiveInvitations = true,
    this.acceptVirtualGifts = true,
    this.filterMatureContent = true,
    this.contentLanguage = 'English',
    this.autoplayWifiOnly = false,
  });

  LiveContentSettings copyWith({
    bool? allowComments,
    bool? allowLiveInvitations,
    bool? acceptVirtualGifts,
    bool? filterMatureContent,
    String? contentLanguage,
    bool? autoplayWifiOnly,
  }) {
    return LiveContentSettings(
      allowComments: allowComments ?? this.allowComments,
      allowLiveInvitations: allowLiveInvitations ?? this.allowLiveInvitations,
      acceptVirtualGifts: acceptVirtualGifts ?? this.acceptVirtualGifts,
      filterMatureContent: filterMatureContent ?? this.filterMatureContent,
      contentLanguage: contentLanguage ?? this.contentLanguage,
      autoplayWifiOnly: autoplayWifiOnly ?? this.autoplayWifiOnly,
    );
  }
}

class StorageLanguageSettings {
  final String appLanguage;
  final bool isDataSaver;
  final String videoQuality;
  final double cacheSizeMB;

  const StorageLanguageSettings({
    this.appLanguage = 'English',
    this.isDataSaver = false,
    this.videoQuality = 'Auto (1080p Recommended)',
    this.cacheSizeMB = 148.6,
  });

  StorageLanguageSettings copyWith({
    String? appLanguage,
    bool? isDataSaver,
    String? videoQuality,
    double? cacheSizeMB,
  }) {
    return StorageLanguageSettings(
      appLanguage: appLanguage ?? this.appLanguage,
      isDataSaver: isDataSaver ?? this.isDataSaver,
      videoQuality: videoQuality ?? this.videoQuality,
      cacheSizeMB: cacheSizeMB ?? this.cacheSizeMB,
    );
  }
}

class AppSettingsState {
  final PrivacySettings privacy;
  final NotificationSettings notifications;
  final LiveContentSettings liveContent;
  final StorageLanguageSettings storageLanguage;
  final bool isAccountDeactivated;

  const AppSettingsState({
    this.privacy = const PrivacySettings(),
    this.notifications = const NotificationSettings(),
    this.liveContent = const LiveContentSettings(),
    this.storageLanguage = const StorageLanguageSettings(),
    this.isAccountDeactivated = false,
  });

  AppSettingsState copyWith({
    PrivacySettings? privacy,
    NotificationSettings? notifications,
    LiveContentSettings? liveContent,
    StorageLanguageSettings? storageLanguage,
    bool? isAccountDeactivated,
  }) {
    return AppSettingsState(
      privacy: privacy ?? this.privacy,
      notifications: notifications ?? this.notifications,
      liveContent: liveContent ?? this.liveContent,
      storageLanguage: storageLanguage ?? this.storageLanguage,
      isAccountDeactivated: isAccountDeactivated ?? this.isAccountDeactivated,
    );
  }
}
