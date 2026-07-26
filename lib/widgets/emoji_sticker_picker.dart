import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A sticker the user can send — either a bundled gif asset or an emoji glyph.
class StickerItem {
  const StickerItem.gif(this.assetPath) : emoji = null;
  const StickerItem.emoji(this.emoji) : assetPath = null;

  final String? assetPath;
  final String? emoji;

  bool get isGif => assetPath != null;
}

/// Bottom panel with two tabs: an offline emoji keyboard and an offline
/// sticker grid. Emojis are inserted into [controller]; stickers are sent
/// immediately via [onStickerSelected].
class EmojiStickerPicker extends StatefulWidget {
  const EmojiStickerPicker({
    super.key,
    required this.controller,
    required this.onStickerSelected,
    this.height = 300,
  });

  final TextEditingController controller;
  final ValueChanged<StickerItem> onStickerSelected;
  final double height;

  @override
  State<EmojiStickerPicker> createState() => _EmojiStickerPickerState();
}

class _EmojiStickerPickerState extends State<EmojiStickerPicker>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<StickerItem> _stickers = const [];

  /// Built-in offline emoji stickers, used when no gif assets are bundled.
  static const List<String> _emojiStickers = [
    '👍', '❤️', '😂', '🎉', '🏠', '🔥',
    '😍', '🙏', '👏', '😎', '🥳', '✅',
    '👋', '💯', '🤝', '🗝️', '📍', '🛏️',
    '🚿', '🍽️', '🌟', '💰', '📄', '😊',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStickers();
  }

  Future<void> _loadStickers() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final gifs = manifest
          .listAssets()
          .where((a) =>
              a.startsWith('assets/gifs/') && a.toLowerCase().endsWith('.gif'))
          .map(StickerItem.gif)
          .toList();
      if (gifs.isNotEmpty && mounted) {
        setState(() => _stickers = gifs);
        return;
      }
    } catch (_) {
      // fall through to emoji stickers
    }
    if (mounted) {
      setState(() => _stickers =
          _emojiStickers.map(StickerItem.emoji).toList(growable: false));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: widget.height,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            indicatorColor: theme.colorScheme.primary,
            tabs: const [
              Tab(icon: Icon(Icons.emoji_emotions_outlined), text: 'Emoji'),
              Tab(icon: Icon(Icons.gif_box_outlined), text: 'Stickers'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                EmojiPicker(
                  textEditingController: widget.controller,
                  config: Config(
                    height: widget.height - 48,
                    emojiViewConfig: const EmojiViewConfig(
                      emojiSizeMax: 28,
                      backgroundColor: Colors.transparent,
                    ),
                    categoryViewConfig: CategoryViewConfig(
                      backgroundColor: theme.colorScheme.surface,
                      iconColor: theme.colorScheme.onSurfaceVariant,
                      iconColorSelected: theme.colorScheme.primary,
                      indicatorColor: theme.colorScheme.primary,
                    ),
                    bottomActionBarConfig: const BottomActionBarConfig(
                      enabled: false,
                    ),
                  ),
                ),
                _StickerGrid(
                  stickers: _stickers,
                  onSelected: widget.onStickerSelected,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StickerGrid extends StatelessWidget {
  const _StickerGrid({required this.stickers, required this.onSelected});

  final List<StickerItem> stickers;
  final ValueChanged<StickerItem> onSelected;

  @override
  Widget build(BuildContext context) {
    if (stickers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: stickers.length,
      itemBuilder: (context, index) {
        final sticker = stickers[index];
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => onSelected(sticker),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: sticker.isGif
                ? Image.asset(sticker.assetPath!, fit: BoxFit.contain)
                : Text(sticker.emoji!, style: const TextStyle(fontSize: 34)),
          ),
        );
      },
    );
  }
}
