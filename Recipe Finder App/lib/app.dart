import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'backend/domain/entities/recipe.dart';
import 'features/recipes/presentation/screens/home_shell_screen.dart';
import 'features/recipes/presentation/screens/recipe_detail_screen.dart';

class RecipeFinderApp extends ConsumerWidget {
  const RecipeFinderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_routerProvider);
    final themeMode = ref.watch(themeControllerProvider);
    return MaterialApp.router(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

final _routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeShellScreen(),
      ),
      GoRoute(
        path: '/recipe/:id',
        name: 'recipe-detail',
        pageBuilder: (context, state) {
          final recipe = state.extra as Recipe?;
          if (recipe == null) {
            return CustomTransitionPage(
              child: const Scaffold(
                body: Center(child: Text('Recipe not found')),
              ),
              transitionsBuilder: _fadeTransition,
            );
          }
          return CustomTransitionPage(
            child: RecipeDetailScreen(recipe: recipe),
            transitionsBuilder: _fadeTransition,
          );
        },
      ),
    ],
  );
});

Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
    child: child,
  );
}
