import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class RecipeListSkeleton extends StatelessWidget {
  const RecipeListSkeleton({super.key, required this.isGrid});

  final bool isGrid;

  @override
  Widget build(BuildContext context) {
    if (isGrid) {
      return GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.74,
        ),
        itemBuilder: (context, index) => const _SkeletonCard(isGrid: true),
        itemCount: 6,
      );
    }
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) => const _SkeletonCard(isGrid: false),
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemCount: 6,
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.isGrid});

  final bool isGrid;

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.white.withValues(alpha: 0.1);
    final highlightColor = Colors.white.withValues(alpha: 0.2);

    final content = isGrid
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 16,
                width: 140,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 14,
                width: 80,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          )
        : Row(
            children: [
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 14,
                      width: 120,
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        padding: EdgeInsets.all(isGrid ? 18 : 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white.withValues(alpha: 0.05),
        ),
        child: content,
      ),
    );
  }
}
