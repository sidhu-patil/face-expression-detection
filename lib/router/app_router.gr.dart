// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i4;
import 'package:fer_detection_app/features/camera/camera_page.dart' as _i1;
import 'package:fer_detection_app/features/home/home_page.dart' as _i2;
import 'package:fer_detection_app/features/report/report_page.dart' as _i3;
import 'package:flutter/material.dart' as _i5;

/// generated route for
/// [_i1.CameraPage]
class CameraRoute extends _i4.PageRouteInfo<void> {
  const CameraRoute({List<_i4.PageRouteInfo>? children})
    : super(CameraRoute.name, initialChildren: children);

  static const String name = 'CameraRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return const _i1.CameraPage();
    },
  );
}

/// generated route for
/// [_i2.HomePage]
class HomeRoute extends _i4.PageRouteInfo<void> {
  const HomeRoute({List<_i4.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return const _i2.HomePage();
    },
  );
}

/// generated route for
/// [_i3.ReportPage]
class ReportRoute extends _i4.PageRouteInfo<ReportRouteArgs> {
  ReportRoute({
    _i5.Key? key,
    required String imagePath,
    List<_i4.PageRouteInfo>? children,
  }) : super(
         ReportRoute.name,
         args: ReportRouteArgs(key: key, imagePath: imagePath),
         initialChildren: children,
       );

  static const String name = 'ReportRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ReportRouteArgs>();
      return _i3.ReportPage(key: args.key, imagePath: args.imagePath);
    },
  );
}

class ReportRouteArgs {
  const ReportRouteArgs({this.key, required this.imagePath});

  final _i5.Key? key;

  final String imagePath;

  @override
  String toString() {
    return 'ReportRouteArgs{key: $key, imagePath: $imagePath}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ReportRouteArgs) return false;
    return key == other.key && imagePath == other.imagePath;
  }

  @override
  int get hashCode => key.hashCode ^ imagePath.hashCode;
}
