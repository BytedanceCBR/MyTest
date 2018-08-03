//
//  TTAdShortVideoModel.h
//  HTSVideoPlay
//
//  Created by carl on 2017/12/8.
//

#import <Foundation/Foundation.h>
#import "TTAdConstant.h"
#import <JSONModel/JSONModel.h>

typedef NS_ENUM(NSUInteger, TTAdShorVideoShowIn) {
    TTAdShorVideoShowInFeed = 1 << 0,
    TTAdShorVideoShowInDraw = 1 << 1,
};

/**
  https://wiki.bytedance.net/pages/viewpage.action?pageId=145995100
 */
@interface TTAdShortVideoModel : JSONModel <TTAd, TTAdPhoneAction, TTAdAppAction>

@property (nonatomic, copy) NSString *ad_id;
@property (nonatomic, copy) NSString *log_extra;
@property (nonatomic, copy) NSString *log_extra2;
@property (nonatomic, assign) NSInteger expire_seconds;
@property (nonatomic, copy) NSString *button_text;
@property (nonatomic, copy) NSString *type; // web action app form counsel
@property (nonatomic, copy) NSString *web_title;
@property (nonatomic, copy) NSString *web_url;
@property (nonatomic, copy) NSString *open_url;

// track
@property (nonatomic, copy) NSArray<NSString *> *click_track_url_list;
@property (nonatomic, copy) NSArray<NSString *> *track_url_list;
@property (nonatomic, assign) NSTimeInterval effective_play_time;
@property (nonatomic, copy) NSArray<NSString *> *effective_play_track_url_list;
@property (nonatomic, copy) NSArray<NSString *> *play_track_url_list;
@property (nonatomic, copy) NSArray<NSString *> *playover_track_url_list;

// App
@property (nonatomic, copy) NSString *apple_id;
@property (nonatomic, copy) NSString *app_name;
@property (nonatomic, copy) NSString *download_url;
@property (nonatomic, copy) NSString *ipa_url;
@property (nonatomic, assign) BOOL hide_if_exists;

// Phone
@property (nonatomic, copy) NSString *phoneNumber;

// form
@property (nonatomic, copy) NSString *form_url;
@property (nonatomic, copy) NSNumber *form_width;
@property (nonatomic, copy) NSNumber *form_height;
@property (nonatomic, copy) NSNumber *use_size_validation;

// Control
@property (nonatomic, copy) NSString *label_pos;

/**
 1 << 0 feed
 1 << 1 draw
 */
@property (nonatomic, assign) TTAdShorVideoShowIn show_type;
@property (nonatomic, assign) NSInteger button_style; // AB 样式测试 1 样式1 样式 2
@end

@interface TTAdShortVideoModel (TTAdTracker)
- (void)sendTrackURLs:(NSArray<NSString *> *)urls;
- (void)trackDrawWithTag:(NSString *)tag label:(NSString *)label extra:(NSDictionary *)extra;
- (void)trackFeedWithTag:(NSString *)tag label:(NSString *)label extra:(NSDictionary *)extra;
@end

@interface TTAdShortVideoModel (TTAdFactory)
@property (nonatomic, copy, readonly) NSString *appUrl;
@property (nonatomic, copy, readonly) NSString *tabUrl;

- (BOOL)isExpire:(NSTimeInterval)beginTimestamp;
- (BOOL)ignoreApp;
- (NSString *)actionButtonText;
- (NSString *)actionButtonIcon;
@end
