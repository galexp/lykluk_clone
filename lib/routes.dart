import 'package:flutter/material.dart';
import 'package:lykluk_clone/views/dashboard_view.dart';


class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/dashboard':
        return MaterialPageRoute(builder: (_) => DashboardView());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: SafeArea(
              child: Center(
                child: Text('Route Error'),
              ),
            ),
          ),
        );
    }
  }
}
