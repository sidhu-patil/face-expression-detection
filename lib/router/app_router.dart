import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fer_detection_app/router/app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: HomeRoute.page, path: "/home", initial: true),
    AutoRoute(page: CameraRoute.page, path: "/camera"),
    AutoRoute(page: ReportRoute.page, path: "/report"),
  ];
}

final appRouterProvider = Provider<AppRouter>((ref) {
  return AppRouter();
});
