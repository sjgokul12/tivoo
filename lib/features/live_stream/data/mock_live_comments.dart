import '../../gift/gift_options.dart';
import '../domain/models/live_comment.dart';

class MockLiveComments {
  MockLiveComments._();

  static List<LiveComment> get initialComments => [
        LiveComment(
          id: 'comm_1',
          userName: 'LeoBeats',
          userAvatarUrl:
              'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=150&auto=format&fit=crop&q=80',
          message: "Vocals on point! 🔥🔥 let's gooo",
          timestamp: DateTime.now().subtract(const Duration(seconds: 25)),
        ),
        LiveComment(
          id: 'comm_star_1',
          userName: 'Maya Vibes',
          userAvatarUrl:
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop&q=80',
          message: 'sent 200 Stars! 🌟',
          type: LiveCommentType.star,
          starsCount: 200,
          timestamp: DateTime.now().subtract(const Duration(seconds: 20)),
        ),
        LiveComment(
          id: 'comm_like_1',
          userName: 'DarkKnight22',
          userAvatarUrl:
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
          message: 'liked the LIVE stream ❤️',
          type: LiveCommentType.like,
          timestamp: DateTime.now().subtract(const Duration(seconds: 15)),
        ),
        LiveComment(
          id: 'comm_2',
          userName: 'Maya Vibes',
          userAvatarUrl:
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop&q=80',
          message: 'I love your setup! So cozy ✨',
          timestamp: DateTime.now().subtract(const Duration(seconds: 10)),
        ),
        LiveComment(
          id: 'comm_3',
          userName: 'DarkKnight22',
          userAvatarUrl:
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
          message: 'This beat is hitting hard 💥',
          timestamp: DateTime.now().subtract(const Duration(seconds: 5)),
        ),
        LiveComment(
          id: 'comm_4',
          userName: 'KoffeeKat',
          userAvatarUrl:
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
          message: 'Your voice is pure magic 💕',
          timestamp: DateTime.now(),
        ),
      ];

  static final List<LiveComment> automatedIncomingPool = [
    LiveComment(
      id: 'pool_1',
      userName: 'Sam_99',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&auto=format&fit=crop&q=80',
      message: 'Play my favorite track please! 🎸',
      timestamp: DateTime.now(),
    ),
    LiveComment(
      id: 'pool_2',
      userName: 'Aurora_X',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150&auto=format&fit=crop&q=80',
      message: 'Sent a Rose 🌹✨',
      timestamp: DateTime.now(),
    ),
    LiveComment(
      id: 'pool_3',
      userName: 'Lucas_Gamer',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150&auto=format&fit=crop&q=80',
      message: 'Subscribed for 6 months! 🏆',
      timestamp: DateTime.now(),
    ),
    LiveComment(
      id: 'pool_4',
      userName: 'Chloe_DJ',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=150&auto=format&fit=crop&q=80',
      message: 'This remix is fire 🔥🔥',
      timestamp: DateTime.now(),
    ),
    LiveComment(
      id: 'pool_5',
      userName: 'Noah_Vibes',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150&auto=format&fit=crop&q=80',
      message: 'Greetings from Los Angeles! 🌴',
      timestamp: DateTime.now(),
    ),
    LiveComment(
      id: 'pool_6',
      userName: 'Elena_R',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&auto=format&fit=crop&q=80',
      message: 'Sent 500 Diamonds 💎💎',
      timestamp: DateTime.now(),
    ),
    LiveComment(
      id: 'pool_7',
      userName: 'Kai_Beats',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
      message: 'Audio quality is unmatched 🎧',
      timestamp: DateTime.now(),
    ),
  ];

  static List<GiftItem> get virtualGifts => GiftCatalog.allGifts;

}
