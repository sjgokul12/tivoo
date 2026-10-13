import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/app_settings_model.dart';

class SettingsController extends StateNotifier<AppSettingsState> {
  SettingsController() : super(const AppSettingsState());

  // Privacy & Security
  void togglePrivateAccount(bool value) {
    state = state.copyWith(
      privacy: state.privacy.copyWith(isPrivateAccount: value),
    );
  }

  void toggleActivityStatus(bool value) {
    state = state.copyWith(
      privacy: state.privacy.copyWith(showActivityStatus: value),
    );
  }

  void toggle2FA(bool value) {
    state = state.copyWith(
      privacy: state.privacy.copyWith(is2FAEnabled: value),
    );
  }

  void unblockUser(String userId) {
    final updatedList =
        state.privacy.blockedUsers.where((u) => u.id != userId).toList();
    state = state.copyWith(
      privacy: state.privacy.copyWith(blockedUsers: updatedList),
    );
  }

  // Notifications
  void toggleMuteAll(bool value) {
    state = state.copyWith(
      notifications: state.notifications.copyWith(
        muteAll: value,
        likes: !value,
        comments: !value,
        followers: !value,
        directMessages: !value,
        liveAlerts: !value,
        giftsReceived: !value,
      ),
    );
  }

  void toggleNotificationLikes(bool value) {
    state = state.copyWith(
      notifications: state.notifications.copyWith(likes: value),
    );
  }

  void toggleNotificationComments(bool value) {
    state = state.copyWith(
      notifications: state.notifications.copyWith(comments: value),
    );
  }

  void toggleNotificationFollowers(bool value) {
    state = state.copyWith(
      notifications: state.notifications.copyWith(followers: value),
    );
  }

  void toggleNotificationMessages(bool value) {
    state = state.copyWith(
      notifications: state.notifications.copyWith(directMessages: value),
    );
  }

  void toggleNotificationLiveAlerts(bool value) {
    state = state.copyWith(
      notifications: state.notifications.copyWith(liveAlerts: value),
    );
  }

  void toggleNotificationGifts(bool value) {
    state = state.copyWith(
      notifications: state.notifications.copyWith(giftsReceived: value),
    );
  }

  // Live & Content
  void toggleAllowComments(bool value) {
    state = state.copyWith(
      liveContent: state.liveContent.copyWith(allowComments: value),
    );
  }

  void toggleAllowLiveInvitations(bool value) {
    state = state.copyWith(
      liveContent: state.liveContent.copyWith(allowLiveInvitations: value),
    );
  }

  void toggleAcceptVirtualGifts(bool value) {
    state = state.copyWith(
      liveContent: state.liveContent.copyWith(acceptVirtualGifts: value),
    );
  }

  void toggleFilterMatureContent(bool value) {
    state = state.copyWith(
      liveContent: state.liveContent.copyWith(filterMatureContent: value),
    );
  }

  void setContentLanguage(String language) {
    state = state.copyWith(
      liveContent: state.liveContent.copyWith(contentLanguage: language),
    );
  }

  void toggleAutoplayWifiOnly(bool value) {
    state = state.copyWith(
      liveContent: state.liveContent.copyWith(autoplayWifiOnly: value),
    );
  }

  // Storage & Language
  void setAppLanguage(String language) {
    state = state.copyWith(
      storageLanguage: state.storageLanguage.copyWith(appLanguage: language),
    );
  }

  void toggleDataSaver(bool value) {
    state = state.copyWith(
      storageLanguage: state.storageLanguage.copyWith(isDataSaver: value),
    );
  }

  void setVideoQuality(String quality) {
    state = state.copyWith(
      storageLanguage: state.storageLanguage.copyWith(videoQuality: quality),
    );
  }

  void clearCache() {
    state = state.copyWith(
      storageLanguage: state.storageLanguage.copyWith(cacheSizeMB: 0.0),
    );
  }

  // Account
  void deactivateAccount() {
    state = state.copyWith(isAccountDeactivated: true);
  }

  void deleteAccountPermanently() {
    state = state.copyWith(isAccountDeactivated: true);
  }
}

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, AppSettingsState>((ref) {
  return SettingsController();
});
