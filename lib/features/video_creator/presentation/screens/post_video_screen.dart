import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/luxe_theme.dart';
import '../../../explore/presentation/controllers/posts_controller.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../domain/models/video_creation_state.dart';
import '../widgets/cover_picker_dialog.dart';

class PostVideoScreen extends ConsumerStatefulWidget {
  final VideoCreationState creationState;

  const PostVideoScreen({super.key, required this.creationState});

  @override
  ConsumerState<PostVideoScreen> createState() => _PostVideoScreenState();
}

class _PostVideoScreenState extends ConsumerState<PostVideoScreen> {
  late final TextEditingController _captionController;
  late final VideoCreationState _state;

  bool _isPosting = false;
  double _uploadProgress = 0.0;
  String _uploadStatus = 'Preparing video...';

  static const List<String> _suggestedHashtags = [
    '#Dance',
    '#Music',
    '#Tivoo',
    '#Reels',
    '#Viral',
    '#Trending',
    '#Luxury',
    '#GoodVibes',
  ];

  static const List<String> _categories = [
    'Dance',
    'Music',
    'Comedy',
    'Entertainment',
    'Gaming',
    'Fashion & Beauty',
    'Lifestyle',
    'Fitness',
  ];

  static const List<String> _locations = [
    'Add location',
    'Miami Beach, Florida',
    'Los Angeles, CA',
    'New York, NY',
    'Tokyo, Japan',
    'London, UK',
    'Paris, France',
    'Dubai, UAE',
    'Mumbai, India',
  ];

  static const List<String> _friends = [
    'Diya Sharma (@diya_official)',
    'Priya Singh (@priya_star)',
    'Neha Verma (@neha_live)',
    'Arun Kumar (@arun_k)',
    'Vicky (@vicky_vibes)',
    'Sneha (@sneha_dance)',
    'Karthik (@karthik_pro)',
  ];

  @override
  void initState() {
    super.initState();
    _state = widget.creationState;
    _captionController = TextEditingController(text: _state.caption);
    _captionController.addListener(() {
      setState(() => _state.caption = _captionController.text);
    });
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _addHashtag(String tag) {
    HapticFeedback.selectionClick();
    final text = _captionController.text;
    if (text.contains(tag)) return;
    final space = text.isEmpty || text.endsWith(' ') ? '' : ' ';
    _captionController.text = '$text$space$tag ';
    _captionController.selection = TextSelection.collapsed(offset: _captionController.text.length);
  }

  void _showAudienceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131526),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 14),
                const Text('Who can watch this video', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                for (final opt in ['Public', 'Followers Only', 'Only Me'])
                  ListTile(
                    title: Text(opt, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    trailing: _state.audience == opt ? const Icon(Icons.check_circle_rounded, color: LuxeColors.gold) : null,
                    onTap: () {
                      setState(() => _state.audience = opt);
                      Navigator.of(ctx).pop();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCategorySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131526),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 14),
                const Text('Content Category', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _categories.length,
                    itemBuilder: (c, i) {
                      final cat = _categories[i];
                      return ListTile(
                        title: Text(cat, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        trailing: _state.category == cat ? const Icon(Icons.check_circle_rounded, color: Color(0xFFFF2A85)) : null,
                        onTap: () {
                          setState(() => _state.category = cat);
                          Navigator.of(ctx).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLocationSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131526),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 14),
                const Text('Add Location', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _locations.length,
                    itemBuilder: (c, i) {
                      final loc = _locations[i];
                      final isNone = loc == 'Add location';
                      return ListTile(
                        leading: Icon(isNone ? Icons.clear_rounded : Icons.location_on_rounded, color: isNone ? Colors.white38 : LuxeColors.gold, size: 20),
                        title: Text(isNone ? 'Remove location' : loc, style: TextStyle(color: isNone ? Colors.white60 : Colors.white, fontWeight: FontWeight.w600)),
                        onTap: () {
                          setState(() => _state.location = isNone ? null : loc);
                          Navigator.of(ctx).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTagPeopleSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131526),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 14),
                    const Text('Tag Friends in Video', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _friends.length,
                        itemBuilder: (c, i) {
                          final friend = _friends[i];
                          final isTagged = _state.taggedPeople.contains(friend);
                          return CheckboxListTile(
                            activeColor: const Color(0xFFFF2A85),
                            checkColor: Colors.white,
                            title: Text(friend, style: const TextStyle(color: Colors.white, fontSize: 13.5)),
                            value: isTagged,
                            onChanged: (val) {
                              setSheetState(() {
                                if (val == true) {
                                  _state.taggedPeople.add(friend);
                                } else {
                                  _state.taggedPeople.remove(friend);
                                }
                              });
                              setState(() {});
                            },
                          );
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9D4EDD),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handlePost() async {
    if (_isPosting) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _isPosting = true;
      _uploadProgress = 0.15;
      _uploadStatus = 'Optimizing video for Explore...';
    });

    try {
      final caption = _captionController.text.trim();

      await ref.read(postsControllerProvider.notifier).upload(
        _state.videoFile,
        thumbnail: _state.coverThumbnail,
        videoBytes: _state.videoBytes,
        thumbnailBytes: _state.coverBytes,
        caption: caption,
        onProgress: (step, p) {
          if (mounted) {
            setState(() {
              _uploadProgress = 0.2 + p * 0.75;
              _uploadStatus = step == UploadStep.converting ? 'Optimizing 1080p video...' : 'Publishing reel...';
            });
          }
        },
      );

      if (!mounted) return;
      setState(() {
        _uploadProgress = 1.0;
        _uploadStatus = 'Posted successfully!';
      });

      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      // Pop all creator screens back to root
      Navigator.of(context).popUntil((route) => route.isFirst);

      // Switch to Explore or Profile feed
      ref.read(bottomNavIndexProvider.notifier).state = 0;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF00E676), size: 20),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Video posted to Explore & your profile! 🎉',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1B1638),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPosting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Widget _defaultCoverCard() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2C1654), Color(0xFF131526)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.movie_creation_rounded, size: 28, color: Colors.white.withValues(alpha: 0.7)),
            const SizedBox(height: 4),
            Text(
              'Reel',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverThumbnailWidget() {
    if (_state.coverBytes != null) {
      return Image.memory(_state.coverBytes!, fit: BoxFit.cover);
    }
    if (_state.coverPath != null && _state.coverPath!.isNotEmpty) {
      if (kIsWeb) {
        return Image.network(
          _state.coverPath!,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _defaultCoverCard(),
        );
      }
      if (_state.coverPath!.startsWith('blob:') || _state.coverPath!.startsWith('http')) {
        return Image.network(
          _state.coverPath!,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _defaultCoverCard(),
        );
      }
      return Image.file(
        File(_state.coverPath!),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _defaultCoverCard(),
      );
    }
    if (!kIsWeb && _state.coverThumbnail != null) {
      return Image.file(
        _state.coverThumbnail!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _defaultCoverCard(),
      );
    }
    return _defaultCoverCard();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0E17),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Post Video',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14, top: 10, bottom: 10),
            child: GestureDetector(
              onTap: _isPosting ? null : _handlePost,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9D4EDD), Color(0xFFFF2A85)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF2A85).withValues(alpha: 0.4),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: _isPosting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                      )
                    : const Text(
                        'Post',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.3),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16, 12, 16, 24 + mq.padding.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Preview & Caption Row (Matching Image 4)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131526),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Video Cover Thumbnail with Edit Cover button
                      GestureDetector(
                        onTap: () {
                          CoverPickerDialog.show(
                            context,
                            currentCover: _state.coverThumbnail,
                            currentCoverBytes: _state.coverBytes,
                            currentCoverPath: _state.coverPath,
                            videoDuration: _state.duration,
                            onCoverSelected: (file, bytes, path) {
                              setState(() {
                                _state.coverThumbnail = file;
                                _state.coverBytes = bytes;
                                _state.coverPath = path;
                              });
                            },
                          );
                        },
                        child: Container(
                          width: 86,
                          height: 118,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF9D4EDD).withValues(alpha: 0.6), width: 1.5),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: _buildCoverThumbnailWidget(),
                              ),
                              Positioned(
                                left: 6,
                                right: 6,
                                bottom: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.white24, width: 0.8),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Edit Cover',
                                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Caption TextField
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TextField(
                              controller: _captionController,
                              maxLength: 500,
                              maxLines: 4,
                              style: const TextStyle(color: Colors.white, fontSize: 13.5),
                              cursorColor: LuxeColors.gold,
                              decoration: const InputDecoration(
                                hintText: 'Write a caption...',
                                hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                                border: InputBorder.none,
                                counterStyle: TextStyle(color: Colors.white38, fontSize: 11),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Suggested Hashtags Row (Matching Image 4)
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _suggestedHashtags.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final tag = _suggestedHashtags[i];
                      return GestureDetector(
                        onTap: () => _addHashtag(tag),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B1B30),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF9D4EDD).withValues(alpha: 0.4)),
                          ),
                          child: Center(
                            child: Text(
                              tag,
                              style: const TextStyle(
                                color: Color(0xFFD4B2FF),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),

                // Options List (Matching Image 4)
                _buildTile(
                  icon: Icons.public_rounded,
                  title: 'Audience',
                  trailingText: _state.audience,
                  onTap: _showAudienceSheet,
                ),
                _buildSwitchTile(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Comments',
                  value: _state.allowComments,
                  onChanged: (v) => setState(() => _state.allowComments = v),
                ),
                _buildSwitchTile(
                  icon: Icons.file_download_outlined,
                  title: 'Allow Download',
                  value: _state.allowDownload,
                  onChanged: (v) => setState(() => _state.allowDownload = v),
                ),
                _buildSwitchTile(
                  icon: Icons.share_rounded,
                  title: 'Allow Share',
                  value: _state.allowShare,
                  onChanged: (v) => setState(() => _state.allowShare = v),
                ),
                _buildTile(
                  icon: Icons.location_on_outlined,
                  title: 'Location',
                  trailingText: _state.location ?? 'Add location',
                  isMutedTrailing: _state.location == null,
                  onTap: _showLocationSheet,
                ),
                _buildTile(
                  icon: Icons.grid_view_rounded,
                  title: 'Content Category',
                  trailingText: _state.category,
                  onTap: _showCategorySheet,
                ),
                _buildTile(
                  icon: Icons.person_add_alt_rounded,
                  title: 'Tag People',
                  trailingText: _state.taggedPeople.isEmpty ? 'Add people' : '${_state.taggedPeople.length} tagged',
                  isMutedTrailing: _state.taggedPeople.isEmpty,
                  onTap: _showTagPeopleSheet,
                ),
                _buildTile(
                  icon: Icons.settings_outlined,
                  title: 'Advanced Settings',
                  trailingText: '',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ultra-Clarity 1080p hardware encoding enabled by default.'),
                        backgroundColor: Color(0xFF1B1638),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          if (_isPosting)
            Container(
              color: Colors.black87,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131526),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF00E5FF), width: 1.2),
                    boxShadow: const [
                      BoxShadow(color: Color(0x6600E5FF), blurRadius: 20),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Color(0xFFFF2A85)),
                      const SizedBox(height: 18),
                      Text(
                        _uploadStatus,
                        style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: _uploadProgress,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF00E5FF)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String trailingText,
    bool isMutedTrailing = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x1AFFFFFF))),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        leading: Icon(icon, color: Colors.white70, size: 20),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailingText.isNotEmpty)
              Text(
                trailingText,
                style: TextStyle(
                  color: isMutedTrailing ? Colors.white38 : const Color(0xFFFFC928),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white30, size: 12),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x1AFFFFFF))),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        leading: Icon(icon, color: Colors.white70, size: 20),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.white,
          activeTrackColor: const Color(0xFF9D4EDD),
          inactiveThumbColor: Colors.white54,
          inactiveTrackColor: Colors.white12,
        ),
      ),
    );
  }
}
