import '../../../core/constants/app_assets.dart';

/// A party room shown in the room list.
class ChatRoom {
  final String id;
  final String hostName;
  final String tagline;
  final String tag;
  final String tagIcon;
  final String avatar;
  final bool isVerified;
  final bool isVideo;
  final int members;
  final int viewers;

  static const int seatCount = 9;

  const ChatRoom({
    required this.id,
    required this.hostName,
    required this.tagline,
    required this.tag,
    required this.avatar,
    required this.members,
    required this.viewers,
    this.tagIcon = '👑',
    this.isVerified = false,
    this.isVideo = false,
  });

  String get capacity => '$members/$seatCount';

  ChatRoom copyWith({int? members}) => ChatRoom(
    id: id,
    hostName: hostName,
    tagline: tagline,
    tag: tag,
    tagIcon: tagIcon,
    avatar: avatar,
    isVerified: isVerified,
    isVideo: isVideo,
    members: members ?? this.members,
    viewers: viewers,
  );
}

/// A speaker on one of the nine audio seats.
class ChatSeat {
  final String name;
  final String avatar;
  final bool isHost;
  final bool micOn;

  const ChatSeat({required this.name, required this.avatar, this.isHost = false, this.micOn = true});

  String get status {
    if (isHost) return micOn ? 'Active' : 'Muted';
    return micOn ? 'Speaking' : 'Listening';
  }

  ChatSeat copyWith({bool? micOn}) => ChatSeat(name: name, avatar: avatar, isHost: isHost, micOn: micOn ?? this.micOn);
}

/// Someone asking the host for a speaker seat.
class JoinRequest {
  final String name;
  final String avatar;
  final String level;
  const JoinRequest({required this.name, required this.avatar, required this.level});
}

class ChatRoomData {
  ChatRoomData._();

  static const List<String> tags = ['Dream Team', 'Friends', 'Music', 'Chill Chat', 'Happy Family'];

  static const List<ChatRoom> rooms = [
    ChatRoom(
      id: 'room_1',
      hostName: 'Diya_Official',
      tagline: "Let's talk & be friends 💕",
      tag: 'Dream Team',
      avatar: AppAssets.avatarDiya,
      members: 8,
      viewers: 128,
    ),
    ChatRoom(
      id: 'room_2',
      hostName: 'Arun_kumar',
      tagline: 'Good Vibes Only ✨',
      tag: 'Friends',
      tagIcon: '👥',
      avatar: AppAssets.avatarArun,
      members: 6,
      viewers: 96,
    ),
    ChatRoom(
      id: 'room_3',
      hostName: 'Sneha_Live',
      tagline: 'Chill Chat 🥰',
      tag: 'Happy Family',
      avatar: AppAssets.avatarMeena,
      members: 7,
      viewers: 142,
    ),
    ChatRoom(
      id: 'room_4',
      hostName: 'Vicky_143',
      tagline: 'Music & Friends 🎵',
      tag: 'Rockers',
      avatar: AppAssets.avatarVicky,
      members: 5,
      viewers: 88,
      isVideo: true,
    ),
    ChatRoom(
      id: 'room_5',
      hostName: 'Priya_S',
      tagline: 'Feel Free to Talk 💕',
      tag: 'Sweet Hearts',
      tagIcon: '👥',
      avatar: AppAssets.avatarNeha,
      members: 8,
      viewers: 115,
      isVerified: true,
    ),
    ChatRoom(
      id: 'room_6',
      hostName: 'Karthik_99',
      tagline: 'Gaming & Friends 🎮',
      tag: 'Legends',
      avatar: AppAssets.avatarKarthik,
      members: 4,
      viewers: 74,
    ),
  ];

  /// Seats 1–8 are taken; the ninth (null) is the Invite slot.
  static const List<ChatSeat?> seats = [
    ChatSeat(name: 'Diya', avatar: AppAssets.avatarDiya, isHost: true, micOn: true),
    ChatSeat(name: 'Arun', avatar: AppAssets.avatarArun, micOn: true),
    ChatSeat(name: 'Sneha', avatar: AppAssets.avatarPriya, micOn: false),
    ChatSeat(name: 'Karthik', avatar: AppAssets.avatarKarthik, micOn: false),
    ChatSeat(name: 'Neha', avatar: AppAssets.avatarNeha, micOn: false),
    ChatSeat(name: 'Vicky', avatar: AppAssets.avatarVicky, micOn: false),
    ChatSeat(name: 'Saran', avatar: AppAssets.avatarSaran, micOn: false),
    ChatSeat(name: 'Meena', avatar: AppAssets.avatarMeena, micOn: false),
    null,
  ];

  static const JoinRequest pendingRequest = JoinRequest(
    name: 'Karthi',
    avatar: AppAssets.avatarKarthik,
    level: 'Lv.12',
  );
}
