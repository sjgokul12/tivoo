import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/crown_icon.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/glass_icon_button.dart';
import '../../../core/widgets/glass_text_field.dart';
import '../../../core/widgets/live_badge.dart';
import '../../../core/widgets/state_message.dart';
import '../../../data/models/live_stream.dart';
import '../../live/presentation/live_screen.dart';
import '../providers/search_providers.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  static Route<void> route() => MaterialPageRoute(builder: (_) => const SearchScreen());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GlassIconButton(
                          size: 44,
                          tooltip: 'Back',
                          onTap: () => Navigator.of(context).maybePop(),
                          child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GlassTextField(
                            hint: 'Search creators or categories',
                            prefixIcon: Icons.search_rounded,
                            autofocus: true,
                            verticalPadding: 14,
                            maxLength: 50,
                            textInputAction: TextInputAction.search,
                            onChanged: ref.read(searchQueryProvider.notifier).update,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Expanded(child: _SearchResults()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(searchResultsProvider);
    final results = async.value;

    if (results == null) {
      if (async.hasError) {
        return Center(
          child: StateMessage(
            icon: Icons.wifi_off_rounded,
            title: 'Search failed',
            actionLabel: 'Retry',
            onAction: () => ref.invalidate(searchResultsProvider),
          ),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Keep showing the previous results while the next query loads.
        SizedBox(
          height: 2,
          child: async.isLoading ? const LinearProgressIndicator(backgroundColor: Colors.transparent) : null,
        ),
        Expanded(
          child: results.isEmpty
              ? const Center(
                  child: StateMessage(
                    icon: Icons.search_off_rounded,
                    title: 'No creators found',
                    message: 'Try another name or category.',
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: results.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => _ResultTile(
                    key: ValueKey(results[i].id),
                    stream: results[i],
                  ),
                ),
        ),
      ],
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({super.key, required this.stream});

  final LiveStream stream;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(LiveScreen.route(stream: stream)),
        child: GlassContainer(
          borderRadius: 20,
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Avatar(image: stream.streamer.avatar, size: 50),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            stream.streamer.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const CrownIcon(size: 12),
                      ],
                    ),
                    Text(
                      stream.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const LiveBadge(fontSize: 10),
                  const SizedBox(height: 6),
                  Text(
                    '${Formatters.compact(stream.viewers)} watching',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
