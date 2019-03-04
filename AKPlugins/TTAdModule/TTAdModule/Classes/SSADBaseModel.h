//
//  SSADBaseModel.h
//  Article
//
//  Created by Zhang Leonardo on 14-2-20.
//
//

#import <Foundation/Foundation.h>
#import "TTAdConstant.h"

typedef NS_ENUM(NSInteger, SSADModelActionType) {
    SSADModelActionTypeApp,
    SSADModelActionTypeWeb,
    SSADModelActionTypeSdk,
    SSADModelActionTypeAppoint,
    SSADModelActionTypeCounsel
};

@interface SSADBaseModel : NSObject <TTAd, TTAdAppAction>

- (instancetype)initWithDictionary:(NSDictionary *)data;

@property (nonatomic, copy) NSString *ad_id;       // 广告ID，用于统计
@property (nonatomic, copy) NSString *log_extra;

@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *type;                     //inner action type = {app, web}
@property (nonatomic, assign) SSADModelActionType actionType; //内嵌广告类型

@property (nonatomic, copy) NSArray<NSString *> *track_urls;
@property (nonatomic, copy) NSArray<NSString *> *click_track_urls;
@property (nonatomic, strong) NSArray *adPlayTrackUrls;
@property (nonatomic, strong) NSArray *adPlayActiveTrackUrls;
@property (nonatomic, strong) NSArray *adPlayEffectiveTrackUrls;
@property (nonatomic, strong) NSArray *adPlayOverTrackUrls;
@property (nonatomic, assign) CGFloat effectivePlayTime;

@property (nonatomic, assign) BOOL dislike;             //不感兴趣
//web type
@property (nonatomic, copy) NSString *webURL;
@property (nonatomic, copy) NSString *webTitle;

//app type
@property (nonatomic, copy) NSString *appName;
@property (nonatomic, copy) NSString *download_url;
@property (nonatomic, copy) NSString *apple_id;
@property (nonatomic, copy) NSString *open_url;
@property (nonatomic, copy) NSString *ipa_url;
@property (nonatomic, copy) NSString *appUrl; // preffix of 'open_url'
@property (nonatomic, copy) NSString *tabUrl; // suffix  of 'open_url'
@property (nonatomic, copy) NSString *alertText;     //确认弹窗的文案

@end

@interface SSADBaseModel (TTAdMonitor)
- (NSDictionary *)monitorInfo;
@end

@interface SSADBaseModel (TTAdNatantTracker)
// 根据不同的label发送广告相关的统计事件
- (void)sendTrackEventWithLabel:(NSString *)label eventName:(NSString *)eventName;
- (void)sendTrackEventWithLabel:(NSString *)label eventName:(NSString *)eventName extra:(NSDictionary *)extra;
@end
