import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/custom_avatar.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int _selectedTab = 0; // 0: Moment, 1: Popularity
  int _selectedTopicIndex = 0;

  final List<Map<String, String>> _topics = [
    {'icon': '🎉', 'title': 'Event'},
    {'icon': '🔥', 'title': 'Trending'},
    {'icon': '✨', 'title': 'Daily Life'},
    {'icon': '🎵', 'title': 'Music & Singing'},
    {'icon': '💃', 'title': 'Dance'},
    {'icon': '🐾', 'title': 'Cute Pets'},
  ];

  final List<Map<String, dynamic>> _posts = [
    {
      'id': 'post_1',
      'authorName': 'Corey Coleman',
      'authorAvatar': AppAssets.status3,
      'badge': 'SSVIP 70',
      'photo': AppAssets.status1,
      'caption':
          'The morning light filters through the leaves, soft shadows on the quiet path. A gentle breeze carrying peaceful memories... ✨🌿',
      'timeAgo': '10 menit yang lalu',
      'likes': 88,
      'comments': 14,
      'shares': 99,
      'isLiked': false,
    },
    {
      'id': 'post_2',
      'authorName': 'Elena Rostova',
      'authorAvatar': AppAssets.status4,
      'badge': 'VIP 32',
      'photo': AppAssets.status2,
      'caption': 'Acoustic vibes on sunset terrace. Thank you all for stopping by during the live stream today! 🌸🎸',
      'timeAgo': '25 menit yang lalu',
      'likes': 214,
      'comments': 38,
      'shares': 42,
      'isLiked': true,
    },
    {
      'id': 'post_3',
      'authorName': 'Marcus Cole',
      'authorAvatar': AppAssets.status2,
      'badge': 'MVP 99',
      'photo': AppAssets.status5,
      'caption': 'Late night sound studio production complete! Big drop coming soon for all my supporters! 🔥🎧',
      'timeAgo': '1 jam yang lalu',
      'likes': 560,
      'comments': 72,
      'shares': 110,
      'isLiked': false,
    },
  ];

  void _handleLike(int index) {
    setState(() {
      final post = _posts[index];
      post['isLiked'] = !post['isLiked'];
      post['likes'] += post['isLiked'] ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C091A),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. Header (Title & Subtitle + Tab Switcher)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subtitle "Share Sincerely, Connect Warmly"
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Community',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Share Sincerely, Connect Warmly',
                                  style: TextStyle(
                                    color: Color(0xFFB388FF),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            // Topic Filter Button
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.tune_rounded, color: Colors.white70, size: 20),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Moment | Popularity Tabs
                        Row(
                          children: [
                            _buildSubTab(
                              title: 'Moment',
                              isSelected: _selectedTab == 0,
                              onTap: () => setState(() => _selectedTab = 0),
                            ),
                            const SizedBox(width: 12),
                            _buildSubTab(
                              title: 'Popularity',
                              isSelected: _selectedTab == 1,
                              onTap: () => setState(() => _selectedTab = 1),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Suggest Topics Carousel
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'SUGGEST TOPICS',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 38,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: _topics.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final topic = _topics[index];
                              final isSelected = _selectedTopicIndex == index;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedTopicIndex = index),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF00B0FF)])
                                        : null,
                                    color: isSelected ? null : Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF00E5FF)
                                          : Colors.white.withValues(alpha: 0.12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(topic['icon']!, style: const TextStyle(fontSize: 13)),
                                      const SizedBox(width: 6),
                                      Text(
                                        topic['title']!,
                                        style: TextStyle(
                                          color: isSelected ? Colors.black87 : Colors.white,
                                          fontSize: 12,
                                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. Post Feed Cards
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final post = _posts[index];
                      return _buildPostCard(post, index);
                    }, childCount: _posts.length),
                  ),
                ),
              ],
            ),

            // Floating 3D Cute Stickers matching Image 4
            Positioned(
              top: 140,
              right: 18,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withValues(alpha: 0.35)),
                  child: const Text('🚀⭐', style: TextStyle(fontSize: 22)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubTab({required String title, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white54,
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: isSelected ? 22 : 0,
            height: 2.5,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF00B0FF)]),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF161229),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 0.8),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Row
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CustomAvatar(radius: 18, assetPath: post['authorAvatar']),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              post['authorName'],
                              style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFFFF4081), Color(0xFFE040FB)]),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              post['badge'],
                              style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(post['timeAgo'], style: const TextStyle(color: Colors.white38, fontSize: 10.5)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: Colors.white38, size: 20),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Post Photo
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              height: 230,
              width: double.infinity,
              child: Image.asset(post['photo'], fit: BoxFit.cover),
            ),
          ),

          // Caption
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Text(post['caption'], style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.35)),
          ),

          // Interaction Bar (Likes, Comments, Shares)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Row(
              children: [
                // Heart Like
                GestureDetector(
                  onTap: () => _handleLike(index),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        post['isLiked'] ? Icons.favorite : Icons.favorite_border_rounded,
                        color: post['isLiked'] ? const Color(0xFFFF2D55) : Colors.white60,
                        size: 20,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${post['likes']}',
                        style: TextStyle(
                          color: post['isLiked'] ? const Color(0xFFFF2D55) : Colors.white70,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 20),

                // Comment
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white60, size: 18),
                    const SizedBox(width: 5),
                    Text(
                      '${post['comments']}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),

                const SizedBox(width: 20),

                // Share
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.share_outlined, color: Colors.white60, size: 18),
                    const SizedBox(width: 5),
                    Text(
                      '${post['shares']}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
