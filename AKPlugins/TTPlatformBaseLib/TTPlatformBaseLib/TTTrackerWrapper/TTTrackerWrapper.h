//
//  TTTrackerWrapper.h
//  Article
//
//  Created by fengyadong on 2017/5/11.
//
//

#import <Foundation/Foundation.h>
#import <BDTrackerProtocol/BDTrackerProtocol.h>
#import <ByteDanceKit/BTDMacros.h>
#import <TTInstallService/TTInstallSandBoxHelper.h>
#import <TTInstallService/TTInstallIDManager.h>
#import <TTTracker/TTTracker.h>

@interface TTTrackerWrapper : NSObject

/**
 设置是否只发v3事件
 
 @param enable 是否只发v3事件
 */
+ (void)setOnlyV3SendingEnable:(BOOL)enable;

/**
 是否只发v3事件

 @return 是否只发v3事件
 */
+ (BOOL)isOnlyV3SendingEnable;

/**
 v3事件是否双发

 @param enable 是否双发
 */
+ (void)setV3DoubleSendingEnable:(BOOL)enable;

+ (void)startupTrackerFromAPNS:(BOOL)fromAPNS;

+ (void)event:(nonnull NSString*)event label:(nonnull NSString*)label;
/*
 *  use dictionary as track data
 *  如果data中category是umeng，则发送到umeng一份
 */
+ (void)eventData:(nonnull NSDictionary*)event;

/**
 *  category 为umeng的事件
 *  id类型的参数只能是string或者number
 */
+ (void)event:(nonnull NSString*)event
        label:(nonnull NSString*)label
        value:(nullable id)value
     extValue:(nullable id)extValue
    extValue2:(nullable id)extValue2;

+ (void)event:(nonnull NSString*)event
        label:(nonnull NSString*)label
        value:(nullable id)value
     extValue:(nullable id)extValue
    extValue2:(nullable id)extValue2
         dict:(nullable NSDictionary *)aDict;

+ (void)event:(nonnull NSString *)event label:(nonnull NSString *)label json:(nullable NSString *)json;
+ (void)category:(nonnull NSString *)category event:(nonnull NSString *)event label:(nonnull NSString *)label json:(nullable NSString *)json;
+ (void)category:(nonnull NSString *)category event:(nonnull NSString *)event label:(nonnull NSString *)label dict:(nullable NSDictionary *)aDict;
+ (void)category:(nonnull NSString *)category event:(nonnull NSString *)event label:(nonnull NSString *)label dict:(nullable NSDictionary *)aDict json:(nullable NSString *)json;

+ (void)ttTrackEventWithCustomKeys:(nonnull NSString *)event label:(nonnull NSString *)label value:(nullable NSString *)value source:(nullable NSString *)source extraDic:(nullable NSDictionary *)extraDic;

/**
 v3格式日志打点
 @param event 时间名称
 @param params 额外参数
 */
+ (void)eventV3:(nonnull NSString *)event params:(nullable NSDictionary *)params;

/**
 v3格式日志打点
 @param event 事件名称
 @param params 额外参数
 @param isDoubleSending 是否为双发的v3事件，默认不是
 */
+ (void)eventV3:(NSString *_Nonnull)event params:(NSDictionary *_Nullable)params isDoubleSending:(BOOL)isDoubleSending;

@end

// sendTrackerLog: true to send own log()
static inline void wrapperTrackEventWithOption(NSString * _Nonnull appName, NSString * _Nonnull event, NSString * _Nonnull label, BOOL sendTrackerLog) {
    if(event == nil) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if(!BTD_isEmptyString(label)) {
            if(sendTrackerLog) {
                [BDTrackerProtocol event:event label:label];
            }
        }
    });
}

static inline void wrapperTrackerEvent (NSString * _Nonnull appName, NSString * _Nonnull event, NSString * _Nonnull label) {
    wrapperTrackEventWithOption(appName, event, label, true);
}

static inline void wrapperTrackEvent (NSString * _Nonnull event, NSString * _Nonnull label) {
    if (BTD_isEmptyString(event)) {
        return;
    }
    
    wrapperTrackEventWithOption([TTInstallSandBoxHelper appName], event, label, true);
}

static inline void wrapperTrackEventWithCustomKeys (NSString * _Nonnull event, NSString * _Nonnull label, NSString * _Nullable value, NSString * _Nullable source, NSDictionary * _Nullable extraDic) {
    [BDTrackerProtocol trackEventWithCustomKeys:event label:label value:value source:source extraDic:extraDic];
}
