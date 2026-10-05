import '../../core/constants/app_assets.dart';
import '../models/chat_message.dart';
import '../models/live_stream.dart';

/// Static seed data standing in for the backend (images are bundled assets). Replace the repositories'
/// bodies with real API calls; nothing in the UI depends on this file.
abstract final class MockData {
  static const _imageDir = 'assets/images/streamers';
  static String _avatar(String key) => '$_imageDir/${key}_avatar.jpg';
  static String _thumbnail(String key) => '$_imageDir/${key}_thumb.jpg';

  static final currentUserAvatar = _avatar('me');

  static const _seed = <(String name, String title, String category, int viewers)>[
    ('Neha', 'Good Vibes Only ✨', 'Singing & Chill Vibes', 8400),
    ('Arun', "Let's Vibe Together 💛", 'Game Streaming', 5200),
    ('Priya', 'Dance & Chill 💃', 'Dance & Fun', 3600),
    ('Karthik', 'Guitar Under the Sky 🎸', 'Music Vibes', 2800),
    ('Diya', 'Late Night Talks 🌙', 'Late Night Talks', 2400),
    ('Ananya', 'Wander With Me ✈️', 'Travel Diaries', 2100),
    ('Sanjay', 'Unboxing Live 📦', 'Tech & Gadgets', 1900),
    ('Meera', 'Glow Up Time 💄', 'Makeup Magic', 1750),
    ('Vikram', 'Laugh Out Loud 😂', 'Stand-up Comedy', 1600),
    ('Kavya', 'Words From the Heart 💌', 'Poetry Hour', 1400),
    ('Aditi', 'Sketch With Me 🎨', 'Art & Sketching', 1250),
    ('Rohan', 'Morning Burn 🔥', 'Fitness Live', 1100),
    ('Isha', 'City Lights Walk 🌆', 'Street Vibes', 980),
    ('Shena', 'Fashion & Fun 👑', 'Fashion Talk', 870),
    ('Lakshmi', 'Cooking Love 🍲', 'Cooking Live', 760),
    ('Rahul', 'Beats & Chill 🎧', 'Beats & Chill', 640),
  ];

  static final List<LiveStream> streams = List.unmodifiable([
    for (var i = 0; i < _seed.length; i++)
      LiveStream(
        id: 'stream_$i',
        streamer: Streamer(
          id: 'user_$i',
          name: _seed[i].$1,
          avatar: _avatar(_seed[i].$1.toLowerCase()),
        ),
        title: _seed[i].$2,
        category: _seed[i].$3,
        thumbnail: _thumbnail(_seed[i].$1.toLowerCase()),
        viewers: _seed[i].$4,
        videoAsset: i.isEven ? AppAssets.reel1 : AppAssets.reel2,
      ),
  ]);

  static const gifts = <Gift>[
    Gift(id: 'rose', name: 'Rose', emoji: '🌹', coins: 1),
    Gift(id: 'love', name: 'Love', emoji: '💖', coins: 5),
    Gift(id: 'icecream', name: 'Ice Cream', emoji: '🍦', coins: 10),
    Gift(id: 'party', name: 'Party', emoji: '🎉', coins: 30),
    Gift(id: 'crown', name: 'Crown', emoji: '👑', coins: 99),
    Gift(id: 'car', name: 'Car', emoji: '🚗', coins: 199),
    Gift(id: 'whale', name: 'Ocean Whale', emoji: '🐳', coins: 299),
    Gift(id: 'angel', name: 'Angel Vehicle', emoji: '🛸', coins: 499),
    Gift(id: 'rocket', name: 'Rocket', emoji: '🚀', coins: 699),
    Gift(id: 'castle', name: 'Castle', emoji: '🏰', coins: 999),
    Gift(id: 'diamond', name: 'Diamond', emoji: '💎', coins: 1499),
    Gift(id: 'galaxy', name: 'Galaxy', emoji: '🌌', coins: 2999),
  ];

  static const comments = <String>[
    'Keep going! ⭐',
    'Love this vibe 💛',
    'Hello from Chennai 👋',
    'Superb 😍🔥',
    'Followed! 💜',
    'One more song please 🎶',
    'Semma performance 🔥',
    'You are amazing ✨',
    '👏👏👏',
    'Best live today 💯',
  ];

  static const pkComments = <String>[
    'Let\'s win this! 🔥',
    'Go go go 💪',
    'Send more gifts team! 🎁',
    'We got this 💛',
    'Comeback time 🚀',
  ];
}
