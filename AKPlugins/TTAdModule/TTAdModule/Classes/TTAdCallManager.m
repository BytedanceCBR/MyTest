//
//  TTAdCallManager.m
//  Article
//
//  Created by yin on 2016/11/28.
//
//

#import "TTAdCallManager.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <TTTracker/TTTrackerProxy.h>
#import <TTBaseLib/TTBaseMacro.h>
#import <TTBaseLib/TTStringHelper.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import "TTAdTrackManager.h"

NSString *const kTTAdCallActionDailing          = @"call_up";
NSString *const kTTAdCallActionConnected        = @"call_cutin";
NSString *const kTTAdCallActionDisconnected     = @"call_hangup";

@interface TTAdCallManager ()

@property (nonatomic, strong) CTCallCenter* callCenter;

@property (nonatomic, strong) TTAdCallListenModel* model;

@property (nonatomic, copy) TTAdCallListenBlock block;

@end

@implementation TTAdCallManager

+ (instancetype)sharedManager{
    static TTAdCallManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
        [_sharedManager startCallListener];
    });
    return _sharedManager;
}

- (void)callAdModel:(TTAdCallListenModel*)model
{
    if (model&&[model isKindOfClass:[TTAdCallListenModel class]]) {
        self.model = model;
    }
    else{
        self.model = nil;
    }
    self.block = nil;
}

- (void)callAdDict:(NSDictionary *)dict
{
    TTAdCallListenModel* callModel = [[TTAdCallListenModel alloc] init];
    //ad_id、log_extra无用,因为只给web传状态,无需打点
    callModel.ad_id = [dict valueForKey:@"ad_id"];
    callModel.log_extra = [dict valueForKey:@"log_extra"];
    callModel.position = [dict valueForKey:@"position"];
    callModel.dailTime = [dict valueForKey:@"dailTime"];
    callModel.dailActionType = [dict valueForKey:@"dailActionType"];
    callModel.isWebCall = [[dict valueForKey:@"web_call"] boolValue];
    if ([dict valueForKey:@"block"]) {
        self.block = [[dict valueForKey:@"block"] copy];
    }
    else
    {
        self.block = nil;
    }
    if (callModel&&[callModel isKindOfClass:[TTAdCallListenModel class]]) {
        self.model = callModel;
    }
    else{
        self.model = nil;
    }
}

- (void)callAdModel:(TTAdCallListenModel*)model block:(TTAdCallListenBlock)block
{
    if (model&&[model isKindOfClass:[TTAdCallListenModel class]]) {
        self.model = model;
    }
    else{
        self.model = nil;
    }
    if (block) {
        self.block = [block copy];
    }
}

- (void)startCallListener
{
    self.callCenter = [[CTCallCenter alloc] init];
    WeakSelf;
    self.callCenter.callEventHandler = ^(CTCall *call){
        StrongSelf;
        CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
        CTCarrier *carrier = [networkInfo subscriberCellularProvider];
        if (isEmptyString(carrier.isoCountryCode)) {
            return;
        }
        
        if (!self.model||![self.model isKindOfClass:[TTAdCallListenModel class]]) {
            return;
        }
        
        if (self.model.toListen == NO) {
            return;
        }
        
        //监听返回落地页的电话状态(返回后不打点)
        if (self.model.isWebCall==YES && self.block) {
            [self callStatus:call.callState];
            return;
        }
        
        if ([call.callState isEqualToString:CTCallStateDialing]){
           
            [self trackCallAdLabel:kTTAdCallActionDailing];
            NSLog(@"Call dialing");
        }
        else if ([call.callState isEqualToString:CTCallStateConnected]){
            
            [self trackCallAdLabel:kTTAdCallActionConnected];
            NSLog(@"Call connected");
        }
        else if ([call.callState isEqualToString:CTCallStateDisconnected]){
            
            [self trackCallAdLabel:kTTAdCallActionDisconnected];
            self.model = nil;
            self.block = nil;
            NSLog(@"Call disconnected");
        }
    };
}


- (void)callStatus:(NSString*)status
{
    if ([status isEqualToString:CTCallStateDialing]){
        
        self.block(kTTAdCallActionDailing);
    }
    else if ([status isEqualToString:CTCallStateConnected]){
        
        self.block(kTTAdCallActionConnected);
    }
    else if ([status isEqualToString:CTCallStateDisconnected]){
        
        self.block(kTTAdCallActionDisconnected);
        self.model = nil;
    }
}


-(void)trackCallAdLabel:(NSString*)label
{
    if (self.model&&!isEmptyString(self.model.position)) {
        TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
        NSTimeInterval callDuration = (NSInteger)[[NSDate date] timeIntervalSinceDate:self.model.dailTime]*1000;
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        [dict setValue:self.model.log_extra forKey:@"log_extra"];
        if ([label isEqualToString:kTTAdCallActionDisconnected]&&callDuration>0) {
            [dict setValue:@(callDuration).stringValue forKey:@"duration"];
        }
        [dict setValue:@(connectionType) forKey:@"nt"];
        [dict setValue:@"1" forKey:@"is_ad_event"];
        if (!isEmptyString(self.model.ad_id)) {
            [TTAdTrackManager trackWithTag:self.model.position label:label value:self.model.ad_id extraDic:dict];
        }
    }
}

+ (void)callWithNumber:(NSString*)phoneNumer
{
    if (!isEmptyString(phoneNumer)) {
        
        NSURL *URL = [TTStringHelper URLWithURLString:[NSString stringWithFormat:@"tel://%@", phoneNumer]];
        if ([TTDeviceHelper OSVersionNumber] < 8) {
            UIWebView * callWebview = [[UIWebView alloc] init];
            [callWebview loadRequest:[NSURLRequest requestWithURL:URL]];
            [[UIApplication sharedApplication].keyWindow addSubview:callWebview];
            // 这里delay1s之后把callWebView干掉，不能直接干掉，否则不能打电话。
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [callWebview removeFromSuperview];
            });
            
            return;
        }
        
        if ([[UIApplication sharedApplication] canOpenURL:URL]) {
            [[UIApplication sharedApplication] openURL:URL];
        }
    }
}

+ (BOOL)callWithModel:(id<TTAdPhoneAction>)model {
    if (![model conformsToProtocol:@protocol(TTAdPhoneAction)]) {
        return NO;
    }
    if (isEmptyString(model.phoneNumber)) {
        return NO;
    }
    NSURL *URL = [TTStringHelper URLWithURLString:[NSString stringWithFormat:@"tel://%@", model.phoneNumber]];
    if ([TTDeviceHelper OSVersionNumber] < 8) {
        UIWebView * callWebview = [[UIWebView alloc] init];
        [callWebview loadRequest:[NSURLRequest requestWithURL:URL]];
        [[UIApplication sharedApplication].keyWindow addSubview:callWebview];
        // 这里delay1s之后把callWebView干掉，不能直接干掉，否则不能打电话。
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [callWebview removeFromSuperview];
        });
    } else if ([[UIApplication sharedApplication] canOpenURL:URL]) {
        [[UIApplication sharedApplication] openURL:URL];
    } else {
        return NO;
    }
    return YES;
}

@end



@implementation TTAdCallModel

- (instancetype)initWithPhoneNumber:(NSString *)phoneNumber
{
    self = [super init];
    if (self) {
        self.phoneNumber = phoneNumber;
    }
    return self;
}

@end

@implementation TTAdCallListenModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isWebCall = NO;
    }
    return self;
}

- (BOOL)toListen
{
    if (!_dailActionType) {
        return NO;
    }
    else if(_dailActionType.integerValue == 1)
    {
        return YES;
    }
    else if(_dailActionType.integerValue == 2)
    {
        return NO;
    }
    else
        return NO;
}


@end
