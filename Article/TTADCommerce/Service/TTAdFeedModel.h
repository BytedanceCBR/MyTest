//
//  TTAdModel.h
//  Article
//
//  Created by carl on 2017/7/10.
//
//

#import <Foundation/Foundation.h>
#import "TTAdConstant.h"
#import "TTAdFeedDefine.h"

NS_ASSUME_NONNULL_BEGIN

@class TTAdFeedLbsModel;

/**
  https://wiki.bytedance.net/pages/viewpage.action?pageId=93966626
 */
@interface TTAdFeedModel : JSONModel<TTAdFeedModel>

@property (nonatomic, copy) NSString *ad_id;
@property (nonatomic, copy) NSString *log_extra;

@property (nonatomic, copy, nullable) NSArray<NSString *><Optional> *track_url_list;
@property (nonatomic, copy, nullable) NSArray<NSString *><Optional> *click_track_url_list;
@property (nonatomic, assign)            CGFloat  effectivePlayTime;
@property (nonatomic, copy, nullable ) NSArray <NSString *> *playTrackUrls;
@property (nonatomic, copy, nullable ) NSArray <NSString *> *activePlayTrackUrls;
@property (nonatomic, copy, nullable ) NSArray <NSString *> *effectivePlayTrackUrls;
@property (nonatomic, copy, nullable ) NSArray <NSString *> *playOverTrackUrls;

@property (nonatomic, assign) NSInteger track_sdk;
@property (nonatomic, assign) BOOL system_origin; // 这个表示是否为号外， 0 不是

//表单收集
@property (nonatomic, copy)   NSString *form_url;
@property (nonatomic, strong) NSNumber *form_width;
@property (nonatomic, strong) NSNumber *form_height;
@property (nonatomic, strong) NSNumber *use_size_validation;

//LBS
//@property (nonatomic, strong, nullable) TTAdFeedLbsModel *location_data;
@property (nonatomic, copy) NSDictionary     *location_data;
@property (nonatomic, copy) NSString         *location_url;

@property (nonatomic, copy) NSString *webURL;
@property (nonatomic, copy) NSString *webTitle;


@property (nonatomic, copy) NSString *button_open_url;

@property (nonatomic, assign) NSTimeInterval expire_seconds;

/**
 eg: web app action form
 */
@property (nonatomic, copy) NSString *type; //用creative_type取值

@property (nonatomic, copy) NSDictionary *detail_info;
@property (nonatomic, assign) BOOL inner_open_type;

/**
 落地页
 *   style =
 *   1. "canvas"        沉浸式广告
 *   2. "full_video"    全屏视频广告
 */
@property (nonatomic, copy) NSString *style;
@property (nonatomic, copy) NSString *sub_title;
@property (nonatomic, copy) NSString *open_url;
@property (nonatomic, assign) BOOL has_video;
@property (nonatomic, copy) NSString *share_url;

/**
 广告下架包含在此
 */
@property (nonatomic, copy) NSArray<NSDictionary *> *filter_words;

@property (nonatomic, copy) NSString *button_text;

/**
 是否展示底部按钮
 */
@property (nonatomic, assign) BOOL button_style;

/*
  video_channel_ad_type; 视频频道大图样式，合并到display_type = 8
  ad_display_style;   图片频道大图样式，合并到display_type=7
 */
@property (nonatomic, assign) NSInteger displayType;

// 下载
@property (nonatomic, copy) NSString *appName;
@property (nonatomic, copy) NSString *download_url;
@property (nonatomic, copy) NSString *apple_id;
@property (nonatomic, strong) NSNumber *hideIfExists;
@property (nonatomic, copy) NSString *ipa_url;

// 电话
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *alert_text;
@property (nonatomic, strong) NSNumber *dialActionType;


////地理位置
//@property (nonatomic, copy) NSString *location_url;
//@property (nonatomic, copy) NSDictionary *location_data;

#pragma mark --

- (ExploreActionType)adType;
/*
 *   0:无  1:带地理信息
 */
@property (nonatomic, copy) NSString *sub_style;

/// 是否为全屏视频广告类型
- (BOOL)isFullScreenVideoStyle;
- (BOOL)isCanvasStyle;

@property (nonatomic, copy) NSString *appUrl;
@property (nonatomic, copy) NSString *tabUrl;

//商圈广告地理位置相关信息
@property (nonatomic, copy, nullable) NSString *locationDistrict;
@property (nonatomic, copy, nullable) NSString *locationStreet;
@property (nonatomic, copy, nullable) NSString *locationDisdance;

#pragma  mark -- delete

@property (nonatomic, copy) NSString *descInfo;
@property (nonatomic, strong, nullable) TTImageInfosModel *imageModel;
/**
 source和sub_title可以共存，如没有sub_title,用source展示在sub_title的位置，source位置为空
 */
@property (nonatomic, copy) NSString *source;       //统一采用文章的source
@property (nonatomic, copy) NSString *label;        // 文章的label
@property (nonatomic, copy) NSString *title;        // 文章的title
@property (nonatomic, strong) NSNumber *ui_type;    //标识创意按钮位置, 1 图片下方 0 图片右下角

- (BOOL)hasLocationInfo;

@end

@interface TTAdFeedLbsModel:JSONModel

@property (nonatomic, copy)  NSString<Optional>  *district;
@property (nonatomic, copy)  NSString<Optional>  *street;
@property (nonatomic, copy)  NSString<Optional>  *distance;

@end


NS_ASSUME_NONNULL_END
