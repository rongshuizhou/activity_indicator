## 前言
- 2018年一直在使用 flutter 写项目，从0.2.0开始到现在1.0版本的发布，终于开始慢慢的爬出坑位了，但是因为部分控件感觉还是不如原生控件好用，一直在摸索怎么将原生view 可以放在 flutter 中并且不会遮挡住 flutter 的 widget。终于，看到官网提供了 PlatformView部件，因为我本身是一名 iOS 开发人员，这里只提供 iOS 的教程，[Android 开发教程在这里](https://medium.com/flutter-community/flutter-platformview-how-to-create-flutter-widgets-from-native-views-366e378115b6)。
## 什么是 PlatformView?
- PlatformView是 flutter 官方提供的一个可以嵌入 Android 和 iOS 平台原生 view 的小部件。
- 在我们实际开发中，我们遇到一些 flutter 官方没有提供的插件可以自己创建编写插件来实现部分功能，但是原生View在 flutter 中会遮挡住flutter 中的小部件，比如你想使用高德地图sdk、视频播放器、直播等原生控件，就无法很好的与 flutter 项目结合。
- 之前知道flutter 给 Android(~~***google 的亲儿子***~~)提供了 AndroidView可以实现将 view 存放到部件中，教程也不少，无奈，iOS (~~***毕竟不是亲的***~~)在网上使用 UiKitView的教程太少，目前就只看到日本的一个作者用 swift写的 [教程](https://qiita.com/rykgy/items/24c710e1c83be436ac69)，终于有了可以参考的 Demo，下面我就用 Object-C 来说一下教程：
##制作插件
我们需要创建一个 项目插件，我这里使用 默认的 Object-C和 Java语言。![Plugin](https://upload-images.jianshu.io/upload_images/856856-7c0961f66e232073.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
##### activity_indicator.dart
首先，我将创建一个StatefulWidget类，在class下显示本机视图。
使用文件名activity_indicator.dart编写以下代码。
```import 'dart:async';

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
```
##### 调用 iOS视图
UIKitView用于调用iOS视图，如下所示。
对于指定的参数，viewType用于确定本机端的目标View的返回。
对于Android，我们使用AndroidView但指定viewType不会更改。

此外，onPlatformViewCreated可以将ActivityIndi​​catorController与UIActivityIndi​​cator小部件一起使用。
要将参数传递给本机端，请使用creationParams。
```@override
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
```
#####从 Flutter 运行原生代码

使用MethodChannel从Flutter执行本机代码。
这也会编写接收MethodChannel和invokeMethod参数的代码，并在本机端执行相应的处理。
这次实现它，以便可以通过ActivityIndi​​catorController执行本机代码。
```
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
```
#####main.dart
接下来，编辑example / main.dart并创建一个屏幕。
我将使用我之前创建的UIActivityIndi​​cator小部件。

```
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:activity_indicator/activity_indicator.dart';

void main() => runApp(MaterialApp(
home: ActivityIndicatorExample(),
));

class ActivityIndicatorExample extends StatelessWidget{

ActivityIndicatorController controller;

void _onActivityIndicatorControllerCreated(ActivityIndicatorController _controller){
controller = _controller;
}

@override
Widget build(BuildContext context) {
// TODO: implement build
return Scaffold(
appBar: AppBar(title: const Text("加载测试"),),
body: Stack(
alignment: Alignment.bottomCenter,
children: <Widget>[
new Container(
child: new Stack(
children: <Widget>[
UIActivityIndicator(
hexColor: "FF0000",
onActivityIndicatorWidgetCreated: _onActivityIndicatorControllerCreated,
),
new Container(
alignment: Alignment.center,
child: new Text("我是flutter控件，没有被遮挡~"),
),
],
),
),
Padding(
padding: const EdgeInsets.only(left: 45.0,right: 45.0,top: 0.0,bottom: 50.0),
child: new Row(
mainAxisAlignment: MainAxisAlignment.spaceEvenly,
children: <Widget>[
FloatingActionButton(
onPressed: (){
controller.start();
},
child: new Text("Start"),
),
FloatingActionButton(
onPressed: (){
controller.stop();
},
child: new Text("Stop"),
)
],
),
)
],
),
);
}

}

```

####iOS 端实现
***
#####FlutterActivityIndicator.h
新建类，提供FlutterPlatformView和FlutterPlatformViewFactory协议
```
#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface FlutterActivityIndicatorController : NSObject<FlutterPlatformView>

- (instancetype)initWithWithFrame:(CGRect)frame
viewIdentifier:(int64_t)viewId
arguments:(id _Nullable)args
binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;

@end

@interface FlutterActivityIndicatorFactory : NSObject<FlutterPlatformViewFactory>

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messager;

@end
NS_ASSUME_NONNULL_END
```

#####从 Flutter 运行原生代码
要从Flutter端执行本机代码，可以按如下方式使用MethodChannel。
它产生以前MethodChannel，当您从ActivityIndi​​catorController时，InvokeMethod，onMethodCall被调用，所以你遇到在参数中指定的字符串，以及运行过程中看到它的价值。
```
_viewId = viewId;
NSString* channelName = [NSString stringWithFormat:@"plugins/activity_indicator_%lld", viewId];
_channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
__weak __typeof__(self) weakSelf = self;
[_channel setMethodCallHandler:^(FlutterMethodCall *  call, FlutterResult  result) {
[weakSelf onMethodCall:call result:result];
}];


-(void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result{
if ([[call method] isEqualToString:@"start"]) {
[_indicator startAnimating];
}else
if ([[call method] isEqualToString:@"stop"]){
[_indicator stopAnimating];
}
else {
result(FlutterMethodNotImplemented);
}
}

```
#####将参数从 Flutter 传递到 iOS
由于Flutter端的creationParams指定的值是args，因此将其转换为类型并设置为UIActivityIndi​​catorView的属性。
```
NSDictionary *dic = args;
NSString *hexColor = dic[@"hexColor"];
bool hidesWhenStopped = [dic[@"hidesWhenStopped"] boolValue];

_indicator = [[UIActivityIndicatorView alloc]init];
_indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
_indicator.color = [UIColor colorWithHexString:hexColor];
_indicator.hidesWhenStopped = hidesWhenStopped;
```
#####ActivityIndicatorPlugin.m
自动生成文件中，只需要这样写
```
#import "ActivityIndicatorPlugin.h"
#import "FlutterActivityIndicator.h"

@implementation ActivityIndicatorPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
[registrar registerViewFactory:[[FlutterActivityIndicatorFactory alloc] initWithMessenger:registrar.messenger] withId:@"plugins/activity_indicator"];

}
@end
```
要保证你的viewId指定的字符串与你 flutter 端代码的
ViewType指定的字符串相匹配

#####最重要的一步操作
要在你的 info.plist中添加
```
<key>io.flutter.embedded_views_preview</key>
<true/>
```
要求必须这样设置
[https://github.com/flutter/flutter/issues/19030#issuecomment-437534853](https://github.com/flutter/flutter/issues/19030#issuecomment-437534853)

###演示
***
![演示 Demo.gif](https://upload-images.jianshu.io/upload_images/856856-62d6fbfffdd13105.gif?imageMogr2/auto-orient/strip)
###Demo 地址
