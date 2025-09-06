import 'package:flutter/material.dart';

extension ExtendedNavigator on BuildContext {
  // Push page dengan nama route yang jelas
  Future<T?> push<T extends Object?>(Widget page, {String? name}) async {
    return Navigator.push<T>(
      this,
      MaterialPageRoute(
        builder: (_) => page,
        settings: RouteSettings(name: name ?? page.runtimeType.toString()),
      ),
    );
  }

  // Push dan replace halaman saat ini
  Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    Widget page, {
    String? name,
    TO? result,
  }) async {
    return Navigator.pushReplacement<T, TO>(
      this,
      MaterialPageRoute(
        builder: (_) => page,
        settings: RouteSettings(name: name ?? page.runtimeType.toString()),
      ),
      result: result,
    );
  }

  // Push named route dengan arguments
  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) async {
    return Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);
  }

  // Push replacement named route
  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
    TO? result,
  }) async {
    return Navigator.of(this).pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  // Pop sampai route tertentu lalu push baru
  Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String newRouteName,
    RoutePredicate predicate, {
    Object? arguments,
  }) async {
    return Navigator.of(
      this,
    ).pushNamedAndRemoveUntil<T>(newRouteName, predicate, arguments: arguments);
  }

  // Hapus semua route dan push baru
  Future<T?> pushNamedAndRemoveAll<T extends Object?>(
    String newRouteName, {
    Object? arguments,
  }) async {
    return Navigator.of(this).pushNamedAndRemoveUntil<T>(
      newRouteName,
      (route) => false,
      arguments: arguments,
    );
  }

  // Pop halaman saat ini
  void pop<T extends Object?>([T? result]) {
    Navigator.of(this).pop<T>(result);
  }

  // Cek bisa pop atau tidak
  bool canPop() {
    return Navigator.of(this).canPop();
  }

  // Pop sampai halaman tertentu
  void popUntil(String routeName) {
    Navigator.of(this).popUntil(ModalRoute.withName(routeName));
  }
}
