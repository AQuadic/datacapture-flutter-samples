/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2021- Scandit AG. All rights reserved.
 */

import 'package:BarcodeCaptureSettingsSample/settings/main/bloc/main_settings_bloc.dart';
import 'package:BarcodeCaptureSettingsSample/settings/main/model/setting_item.dart';
import 'package:flutter/material.dart';

class MainSettingsView extends StatefulWidget {
  final String title;

  MainSettingsView(this.title, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MainSettingsViewState(MainSettingsBloc());
  }
}

class _MainSettingsViewState extends State<MainSettingsView>
    with WidgetsBindingObserver {
  final MainSettingsBloc _bloc;

  _MainSettingsViewState(this._bloc);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          child: Text(widget.title),
          onDoubleTap: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) => Padding(
                    padding: EdgeInsets.all(1.0),
                    child: ListTile(
                      title: Text(
                        _bloc.settings[index].title,
                      ),
                      onTap: () {
                        _onClick(context, _bloc.settings[index]);
                      },
                    )),
                itemCount: _bloc.settings.length,
              ),
            ),
            Text('Plugin Version: ${_bloc.pluginVersion}'),
          ],
        ),
      ),
    );
  }

  void _onClick(BuildContext context, SettingItem item) async {
    await Navigator.pushNamed(context, item.navigationRoute);
  }
}
