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
      avatar: AppAssets.avatarSneha,
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
    ),
    ChatRoom(
      id: 'room_5',
      hostName: 'Priya_S',
      tagline: 'Feel Free to Talk 💕',
      tag: 'Sweet Hearts',
      tagIcon: '👥',
      avatar: AppAssets.avatarPriya,
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

  /// Pool of available speakers across rooms.
  static const List<ChatSeat> speakerPool = [
    ChatSeat(name: 'Arun', avatar: AppAssets.avatarArun, micOn: true),
    ChatSeat(name: 'Sneha', avatar: AppAssets.avatarSneha, micOn: false),
    ChatSeat(name: 'Karthik', avatar: AppAssets.avatarKarthik, micOn: true),
    ChatSeat(name: 'Neha', avatar: AppAssets.avatarNeha, micOn: false),
    ChatSeat(name: 'Vicky', avatar: AppAssets.avatarVicky, micOn: false),
    ChatSeat(name: 'Priya', avatar: AppAssets.avatarPriya, micOn: true),
    ChatSeat(name: 'Saran', avatar: AppAssets.avatarSaran, micOn: false),
    ChatSeat(name: 'Meena', avatar: AppAssets.avatarMeena, micOn: false),
    ChatSeat(name: 'Diya', avatar: AppAssets.avatarDiya, micOn: true),
    ChatSeat(name: 'Lucas', avatar: AppAssets.status3, micOn: false),
    ChatSeat(name: 'Aurora', avatar: AppAssets.status4, micOn: true),
    ChatSeat(name: 'Sam', avatar: AppAssets.status5, micOn: false),
    ChatSeat(name: 'Chloe', avatar: AppAssets.status2, micOn: true),
  ];

  /// Dynamically generates exactly 9 seat slots matching the room's actual host and member count:
  /// - Seat 0: Always the room's actual host ([room.hostName] with [room.avatar] and [isHost] = true).
  /// - Seats 1 to [room.members - 1]: Filled with active speakers from the pool.
  /// - Remaining seats up to 9: Empty invite slots (null).
  static List<ChatSeat?> generateSeatsForRoom(ChatRoom room) {
    final List<ChatSeat?> slots = List<ChatSeat?>.filled(ChatRoom.seatCount, null);

    // Seat 0: The actual host of this room
    slots[0] = ChatSeat(
      name: room.hostName,
      avatar: room.avatar,
      isHost: true,
      micOn: true,
    );

    // Occupied speaker count (capped between 1 and 9)
    final occupiedCount = room.members.clamp(1, ChatRoom.seatCount);

    // Pool of speakers excluding anyone sharing the host's identity
    final hostLower = room.hostName.toLowerCase();
    final available = speakerPool.where((s) {
      final sLower = s.name.toLowerCase();
      return !hostLower.contains(sLower) && !sLower.contains(hostLower);
    }).toList();

    var poolIdx = 0;
    for (var i = 1; i < occupiedCount; i++) {
      if (poolIdx < available.length) {
        slots[i] = available[poolIdx++];
      }
    }

    return slots;
  }

  /// Default seats getter for backward compatibility.
  static List<ChatSeat?> get seats => generateSeatsForRoom(rooms.first);

  static const JoinRequest pendingRequest = JoinRequest(
    name: 'Karthi',
    avatar: AppAssets.avatarKarthik,
    level: 'Lv.12',
  );
}
