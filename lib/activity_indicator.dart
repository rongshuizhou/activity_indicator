import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';



typedef void UIActivityIndicatorWidgetCreatedCallback(ActivityIndicatorController controller);

class ActivityIndicatorController {
  ActivityIndicatorController._(int id)
      : _channel = MethodChannel('plugins/activity_indicator_$id');

  final MethodChannel _channel;

  Future<void> start() async {
    return _channel.invokeMethod('start');
  }

  Future<void> stop() async {
    return _channel.invokeMethod('stop');
  }
}

class UIActivityIndicator extends StatefulWidget{

  const UIActivityIndicator({
    Key key,
    this.onActivityIndicatorWidgetCreated,
    this.hexColor,

  }):super(key:key);

  final UIActivityIndicatorWidgetCreatedCallback onActivityIndicatorWidgetCreated;
  final String hexColor;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _UIActivityIndicatorState();
  }

}

class _UIActivityIndicatorState extends State<UIActivityIndicator>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if(defaultTargetPlatform == TargetPlatform.iOS){
      return UiKitView(
        viewType: "plugins/activity_indicator",
        onPlatformViewCreated:_onPlatformViewCreated,
        creationParams: <String,dynamic>{
          "hexColor":widget.hexColor,
          "hidesWhenStopped":true,

        },
        creationParamsCodec: new StandardMessageCodec(),

      );

    }
    return Text('activity_indicator插件尚不支持$defaultTargetPlatform ');
  }

  void _onPlatformViewCreated(int id){
    if(widget.onActivityIndicatorWidgetCreated == null){
      return;
    }
    widget.onActivityIndicatorWidgetCreated(new ActivityIndicatorController._(id));
  }

}
