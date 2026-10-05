import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/chat_message.dart';
import '../providers/wallet_provider.dart';

/// Glass bottom sheet with the gift catalogue. Returns the chosen gift;
/// the caller is responsible for charging the wallet and sending it.
class GiftSheet extends ConsumerStatefulWidget {
  const GiftSheet({super.key, this.recipients = const []});

  /// Optional recipients (e.g. the two PK teams) shown as a selector.
  final List<String> recipients;

  static Future<GiftSelection?> show(BuildContext context, {List<String> recipients = const []}) {
    return showModalBottomSheet<GiftSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black38,
      builder: (_) => GiftSheet(recipients: recipients),
    );
  }

  @override
  ConsumerState<GiftSheet> createState() => _GiftSheetState();
}

class _GiftSheetState extends ConsumerState<GiftSheet> {
  static const _quantities = [1, 10, 99];

  int _giftIndex = 0;
  int _quantity = 1;
  int _recipient = 0;

  @override
  Widget build(BuildContext context) {
    final balance = ref.watch(walletProvider);
    final selection = GiftSelection(
      gift: MockData.gifts[_giftIndex],
      quantity: _quantity,
      recipientIndex: _recipient,
    );
    final affordable = selection.totalCoins <= balance;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Center(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xE6221654), Color(0xF20A0A22)],
                ),
                border: Border(top: BorderSide(color: Color(0x88B44CFF), width: 1.2)),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 10, 16, 16 + bottomInset),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Text(
                          'Send a Gift',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        _CoinChip(balance: balance),
                      ],
                    ),
                    if (widget.recipients.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          for (var i = 0; i < widget.recipients.length; i++) ...[
                            if (i > 0) const SizedBox(width: 8),
                            ChoiceChip(
                              label: Text(widget.recipients[i]),
                              selected: _recipient == i,
                              onSelected: (_) => setState(() => _recipient = i),
                              selectedColor: i == 0 ? AppColors.pink : AppColors.blue,
                              backgroundColor: AppColors.glassFill,
                              labelStyle: const TextStyle(color: Colors.white, fontSize: 13),
                              showCheckmark: false,
                              shape: const StadiumBorder(side: BorderSide(color: AppColors.glassBorder)),
                            ),
                          ],
                        ],
                      ),
                    ],
                    const SizedBox(height: 14),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: MockData.gifts.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.82,
                      ),
                      itemBuilder: (_, i) => _GiftTile(
                        gift: MockData.gifts[i],
                        selected: i == _giftIndex,
                        onTap: () => setState(() => _giftIndex = i),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        for (final q in _quantities) ...[
                          _QuantityChip(
                            quantity: q,
                            selected: q == _quantity,
                            onTap: () => setState(() => _quantity = q),
                          ),
                          const SizedBox(width: 8),
                        ],
                        const SizedBox(width: 4),
                        Expanded(
                          child: GradientButton(
                            label: affordable ? 'Send · ${Formatters.grouped(selection.totalCoins)}' : 'Not enough coins',
                            height: 46,
                            trailing: null,
                            onPressed: affordable ? () => Navigator.of(context).pop(selection) : null,
                          ),
                        ),
                      ],
                    ),
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

class _GiftTile extends StatelessWidget {
  const _GiftTile({required this.gift, required this.selected, required this.onTap});

  final Gift gift;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: selected ? const Color(0x33FF3FA4) : AppColors.glassFill,
          border: Border.all(color: selected ? AppColors.pink : Colors.transparent, width: 1.4),
          boxShadow: selected
              ? const [BoxShadow(color: Color(0x88FF3FA4), blurRadius: 14, blurStyle: BlurStyle.outer)]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.15 : 1,
              duration: const Duration(milliseconds: 180),
              child: Text(gift.emoji, style: const TextStyle(fontSize: 32)),
            ),
            const SizedBox(height: 4),
            Text(
              gift.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
            ),
            Text(
              '🪙 ${gift.coins}',
              style: const TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityChip extends StatelessWidget {
  const _QuantityChip({required this.quantity, required this.selected, required this.onTap});

  final int quantity;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: selected ? AppColors.pinkPurpleGradient : null,
          color: selected ? null : AppColors.glassFill,
        ),
        child: Text(
          'x$quantity',
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _CoinChip extends StatelessWidget {
  const _CoinChip({required this.balance});

  final int balance;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0x33FFC83D),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: Text(
          '🪙 ${Formatters.grouped(balance)}',
          style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
    );
  }
}
