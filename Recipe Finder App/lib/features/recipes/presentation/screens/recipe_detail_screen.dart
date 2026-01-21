import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../backend/domain/entities/recipe.dart';
import '../controllers/favorites_controller.dart';
import '../widgets/favorite_button.dart';
import '../widgets/glass_icon_button.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  const RecipeDetailScreen({super.key, required this.recipe});

  final Recipe recipe;

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late int _currentTabIndex;
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentTabIndex = 0;
    _tabController.addListener(() {
      if (_currentTabIndex != _tabController.index) {
        setState(() => _currentTabIndex = _tabController.index);
      }
    });
    final videoId = _extractVideoId(widget.recipe.videoUrl);
    if (videoId != null) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          enableCaption: true,
          mute: false,
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favoritesController = ref.watch(favoritesControllerProvider.notifier);
    final favorites = ref.watch(favoritesControllerProvider);
    final isFavorite = favorites.containsKey(widget.recipe.id);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _HeroSection(
                  recipe: widget.recipe,
                  isFavorite: isFavorite,
                  onBack: () => Navigator.of(context).maybePop(),
                  onToggleFavorite: () =>
                      favoritesController.toggleFavorite(widget.recipe),
                  onImageTap: () => _openImageViewer(context),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.recipe.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _InfoChip(label: widget.recipe.category),
                            _InfoChip(label: widget.recipe.area),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _GlassTabsDelegate(tabController: _tabController),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                sliver: SliverToBoxAdapter(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _TabContent(
                      key: ValueKey(_currentTabIndex),
                      tabIndex: _currentTabIndex,
                      recipe: widget.recipe,
                      youtubeController: _youtubeController,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openImageViewer(BuildContext context) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Stack(
            children: [
              InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(
                  child: Hero(
                    tag: 'recipe-image-${widget.recipe.id}',
                    child: CachedNetworkImage(
                      imageUrl: widget.recipe.thumbnail,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 24,
                right: 24,
                child: GlassIconButton(
                  icon: Icons.close_rounded,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.recipe,
    required this.isFavorite,
    required this.onBack,
    required this.onToggleFavorite,
    required this.onImageTap,
  });

  final Recipe recipe;
  final bool isFavorite;
  final VoidCallback onBack;
  final VoidCallback onToggleFavorite;
  final VoidCallback onImageTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onImageTap,
          child: Hero(
            tag: 'recipe-image-${recipe.id}',
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(42),
                bottomRight: Radius.circular(42),
              ),
              child: CachedNetworkImage(
                imageUrl: recipe.thumbnail,
                height: 320,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.6),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Positioned(
          top: 24,
          left: 16,
          child: GlassIconButton(
            icon: Icons.arrow_back_rounded,
            onPressed: onBack,
          ),
        ),
        Positioned(
          top: 24,
          right: 16,
          child: FavoriteButton(
            isFavorite: isFavorite,
            onToggle: onToggleFavorite,
          ),
        ),
      ],
    );
  }
}

class _GlassTabsDelegate extends SliverPersistentHeaderDelegate {
  _GlassTabsDelegate({required this.tabController});

  final TabController tabController;

  @override
  double get minExtent => 72;

  @override
  double get maxExtent => 72;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final activeStyle = textTheme.titleSmall?.copyWith(
      fontSize: 10,
      letterSpacing: 0.2,
      fontWeight: FontWeight.w600,
    );
    final inactiveStyle = textTheme.titleSmall?.copyWith(
      fontSize: 9,
      letterSpacing: 0.2,
      fontWeight: FontWeight.w500,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        borderRadius: 24,
        child: TabBar(
          controller: tabController,
          indicator: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.7),
          labelStyle: activeStyle,
          unselectedLabelStyle: inactiveStyle,
          tabs: const [
            Tab(
              child: Text(
                AppStrings.overview,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Tab(
              child: Text(
                AppStrings.ingredientsSection,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Tab(
              child: Text(
                AppStrings.instructions,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _GlassTabsDelegate oldDelegate) {
    return oldDelegate.tabController != tabController;
  }
}

class _TabContent extends StatelessWidget {
  const _TabContent({
    super.key,
    required this.tabIndex,
    required this.recipe,
    required this.youtubeController,
  });

  final int tabIndex;
  final Recipe recipe;
  final YoutubePlayerController? youtubeController;

  @override
  Widget build(BuildContext context) {
    switch (tabIndex) {
      case 0:
        return _OverviewSection(
          recipe: recipe,
          youtubeController: youtubeController,
        );
      case 1:
        return _IngredientsSection(recipe: recipe);
      case 2:
        return _InstructionsSection(recipe: recipe);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({required this.recipe, this.youtubeController});

  final Recipe recipe;
  final YoutubePlayerController? youtubeController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassContainer(
          padding: const EdgeInsets.all(18),
          child: Text(
            recipe.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        if (youtubeController != null) ...[
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: YoutubePlayer(
              controller: youtubeController!,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ] else if (recipe.videoUrl != null) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => _launchUrl(context, recipe.videoUrl!),
            icon: const Icon(Icons.play_circle_fill),
            label: const Text('Watch on YouTube'),
          ),
        ],
      ],
    );
  }
}

class _IngredientsSection extends StatelessWidget {
  const _IngredientsSection({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...recipe.ingredients.map(
            (ingredient) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Container(
                    height: 6,
                    width: 6,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      ingredient.name,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  Text(
                    ingredient.measure,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionsSection extends StatelessWidget {
  const _InstructionsSection({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ...recipe.instructions.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                    ),
                    child: Text(
                      '${entry.key + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: Colors.white),
      ),
    );
  }
}

String? _extractVideoId(String? url) {
  if (url == null || url.isEmpty) return null;
  return YoutubePlayer.convertUrlToId(url);
}

void _launchUrl(BuildContext context, String url) {
  Clipboard.setData(ClipboardData(text: url));
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Video link copied to clipboard')),
  );
}
