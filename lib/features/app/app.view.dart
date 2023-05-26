import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:nextcloudnotes/core/services/di/di.dart';
import 'package:nextcloudnotes/core/shared/components/scaffold.component.dart';
import 'package:nextcloudnotes/features/app/controllers/app.controller.dart';

@RoutePage()
class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  final AppViewController _appViewController = getIt<AppViewController>();

  bool stateInited = false;

  @override
  void initState() {
    super.initState();

    _appViewController.initState(context).then((value) {
      setState(() {
        stateInited = true;
      });
    });
  }

  @override
  void dispose() {}

  @override
  Widget build(BuildContext context) {
    if (stateInited) {
      return const AutoRouter();
    }
    return const AppScaffold(
        body: Center(
      child: CircularProgressIndicator.adaptive(),
    ));
  }
}
