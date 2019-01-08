//
//  FlutterActivityIndicator.m
//  activity_indicator
//
//  Created by admin_test on 2019/1/8.
//

#import "FlutterActivityIndicator.h"
#import "UIColor+RGB.h"

@implementation FlutterActivityIndicatorFactory{
    NSObject<FlutterBinaryMessenger>*_messenger;
}

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messager{
    self = [super init];
    if (self) {
        _messenger = messager;
    }
    return self;
}

-(NSObject<FlutterMessageCodec> *)createArgsCodec{
    return [FlutterStandardMessageCodec sharedInstance];
}

-(NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args{
    
   FlutterActivityIndicatorController*activity = [[FlutterActivityIndicatorController alloc] initWithWithFrame:frame viewIdentifier:viewId arguments:args binaryMessenger:_messenger];
    
    return activity;
    
}

@end

@implementation FlutterActivityIndicatorController{
    int64_t _viewId;
    FlutterMethodChannel* _channel;
    UIActivityIndicatorView * _indicator;
}

- (instancetype)initWithWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger{
    if ([super init]) {
        
        NSDictionary *dic = args;
        NSString *hexColor = dic[@"hexColor"];
        bool hidesWhenStopped = [dic[@"hidesWhenStopped"] boolValue];
        
        _indicator = [[UIActivityIndicatorView alloc]init];
        _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        _indicator.color = [UIColor colorWithHexString:hexColor];
        _indicator.hidesWhenStopped = hidesWhenStopped;
        
        _viewId = viewId;
        NSString* channelName = [NSString stringWithFormat:@"plugins/activity_indicator_%lld", viewId];
        _channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
        __weak __typeof__(self) weakSelf = self;
        [_channel setMethodCallHandler:^(FlutterMethodCall *  call, FlutterResult  result) {
            [weakSelf onMethodCall:call result:result];
        }];
        
    }
    
    return self;
}

-(UIView *)view{
    return _indicator;
}

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


@end


