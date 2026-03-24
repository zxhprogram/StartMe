import 'package:app/pages/bookmarks_page.dart';
import 'package:app/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomePage();
      },
      routes: [
        GoRoute(
          path: '/bookmarks',
          builder: (BuildContext context, GoRouterState state) {
            return const BookmarksPage();
          },
        ),
      ],
    ),
  ],
);
