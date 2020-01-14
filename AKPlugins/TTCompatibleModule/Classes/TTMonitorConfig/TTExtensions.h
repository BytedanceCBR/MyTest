//
//  TTExtensions.h
//  TTLive
//
//  Created by Ray on 16/3/4.
//  Copyright © 2016年 Nick Yu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTReachability.h"

#if 0
#define DDLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define DDLog(...)
#endif

//异步执行某个任务
#define ASYNC(...) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ __VA_ARGS__ })
//主线程中执行某个操作
#define ASYNC_MAIN(...) dispatch_async(dispatch_get_main_queue(), ^{ __VA_ARGS__ })
//后台线程执行某个block
#define ASYNC_BACK(...) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{ __VA_ARGS__ })
//执行某个block
#define ExcecuteBlock(_block_, ...)    \
if(_block_) \
_block_(__VA_ARGS__); \


//添加通知
#define TTAddNotification(key,sender,sel) [[NSNotificationCenter defaultCenter] addObserver:sender selector:sel name:key object:nil]
//取消通知
#define TTRemoveNotification(sender,key) [[NSNotificationCenter defaultCenter] removeObserver:sender name:key object:nil]

#define  TTObjectForKeySafe(_dict_, _key_)  ([_dict_ isKindOfClass:NSDictionary.class] ? [_dict_ objectForKey:_key_] : nil)

#define  TTObjectAtIndexSafe(_array_, _idx_)  ([_array_ isKindOfClass:NSArray.class] ? [_array_ objectAtIndex:_idx_] : nil)

#define NumberDouble(x)     [NSNumber numberWithDouble:x]

#define NumberInteger(x)    [NSNumber numberWithInteger:x]

static inline BOOL TTIsNull(id object){
    BOOL isNull = NO;
    if (object == nil
        || object == [NSNull null])
    {
        isNull = YES;
    }
    return isNull;
}

static inline BOOL TTIsEmpty(id object){
    BOOL isEmpty = NO;
    if (TTIsNull(object) == YES
        || ([object respondsToSelector: @selector(length)]
            && [object length] == 0)
        || ([object respondsToSelector: @selector(count)]
            && [(NSDictionary *)object count] == 0))
    {
        isEmpty = YES;
    }
    
    return isEmpty;
}

#define CheckNil(_OBJ_) if(TTIsNull(_OBJ_)){return;};

#define CheckEmpty(_OBJ_) if(TTIsEmpty(_OBJ_)){return;};

#define ReturnNilIfNil(_OBJ_) if(TTIsNull(_OBJ_)){return nil;};

#define ValueOfDictKey(_dict_,_key_) ([_dict_ isKindOfClass:NSDictionary.class] ? [_dict_ objectForKey:_key_] : nil)

#define  ObjectAtIndex(_array_, _idx_) \
(([_array_ isKindOfClass:NSArray.class] && (_idx_<_array_.count)) ? [_array_ objectAtIndex:_idx_] : nil)\

#define SetObjectForKeySafely(_dict_, _object_, _key_) \
if(_object_ != nil && _key_!=nil && [_dict_ isKindOfClass:NSDictionary.class]) \
[_dict_ setObject:_object_ forKey:_key_]; \

#define TTAddObjectIfNotNil(_array_,_OBJ_) if(!TTIsNull(_OBJ_)){[_array_ addObject:_OBJ_];};

#define TTCurrentNow @([[NSDate date] timeIntervalSince1970])

typedef enum : NSInteger {
    MNetworkStatusNone=-1,
    MNNotReachable = 0,
    MNReachableViaWWAN=1,
    MNReachableVia2G = 2,
    MNReachableVia3G = 3,
    MNReachableViaWiFi=4,
    MNReachableVia4G = 5
} MNetworkStatus;


@interface TTExtensions : NSObject

+ (NSString*)bundleIdentifier;

+ (NSString*)versionName;

+ (BOOL)isJailBroken;

+ (NSString*)carrierName;

+ (NSString*)carrierMCC;

+ (NSString*)carrierMNC;

+ (NSString*)connectMethodName;

+ (NSString*)appDisplayName;

+ (NSString*)OSVersion;

+ (NSString*)currentLanguage;

+ (NSString *)MACAddress;

+ (NSString*)openUDID;

+ (NSString*)currentChannel;

+ (NSString*)ssAppID;

+ (NSString*)idfaString;

+ (float)OSVersionNumber;

+ (CGSize)resolution;

+ (NSString *)resolutionString;

+ (NSString *)generateUUID;

+ (NSString *)userAgentString;

+ (NSString*)joinBaseUrlStr:(NSString *)baseUrl
                 withParams:(NSDictionary *)params;

+ (void)applyCookieHeader:(NSMutableURLRequest*)request;

+ (MNetworkStatus)networkStatus;

+ (NSString *)getCurrentChannel;

+ (NSString*)URLString:(NSString *)URLStr appendCommonParams:(NSDictionary *)commonParams;

+ (NSData *)gzipDeflate:(NSData*) src;

+ (NSInteger)connectionType;

+ (NSString*)addressOfHost:(NSString*)host;

+ (NSDateFormatter*)_dateformatter;

+ (NSString*)buildVersion;
@end
