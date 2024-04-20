import 'package:minesweeper/core/route/app_route_name.dart';
import 'package:go_router/go_router.dart';
import 'package:minesweeper/feature/home/home_page.dart';

class AppRoute {
  AppRoute._();

  static final GoRouter router = GoRouter(
    initialLocation: "/home",
    routes: [
      GoRoute(
        name: AppRouteName.home,
        path: "/home",
        builder: (context, state) {
          return const HomePage();
        },
      )
    ],
  );
}
