//
//  ExploreOrderedADModel.h
//  Article
//
//  Created by SunJiangting on 14-11-26.
//
//

#import <Foundation/Foundation.h>
#import "TTImageInfosModel.h"
#import "TTAdFeedDefine.h"
#import "TTAdConstant.h"

/// 存在于内存中的数据结构，主要用于广告
@interface ExploreOrderedADModel : NSObject <TTAdFeedModel>

- (nullable instancetype)initWithDictionary:(nullable NSDictionary *)dictionary;

@property (nonatomic, copy, nullable)   NSString *ad_id;
@property (nonatomic, copy, nullable)   NSString *log_extra;

@property (nonatomic, copy, nullable)   NSString *open_url;

// 创意大图
@property (nonatomic, strong, nullable) NSDictionary *imageInfo;
@property (nonatomic, strong, nullable) TTImageInfosModel *imageModel;

@property (nonatomic, copy, nullable)   NSString *type;   // 创意类型

@property (nonatomic, copy, nullable)   NSString *title;
@property (nonatomic, copy, nullable) NSString *sub_title;
@property (nonatomic, copy, nullable)   NSString *descInfo;
@property (nonatomic, assign) NSInteger displayType;
@property (nonatomic, copy, nullable)   NSString *source;
@property (nonatomic, copy, nullable)   NSString *button_text;
@property (nonatomic, strong, nullable) NSNumber *hideIfExists;

@property (nonatomic, copy, nullable)   NSString *webURL;
@property (nonatomic, copy, nullable)   NSString *webTitle;
@property (nonatomic, copy, nullable)   NSString *displayInfo;

@property (nonatomic, copy, nullable)   NSString *appName;
@property (nonatomic, copy, nullable)   NSString *apple_id;
@property (nonatomic, copy, nullable)   NSString *download_url;
@property (nonatomic, copy, nullable)   NSString *ipa_url;
//衍生字段
@property (nonatomic, copy, nullable)   NSString *appUrl; //open_url's scheme
@property (nonatomic, copy, nullable)   NSString *tabUrl; //open_url's path and query

@property (nonatomic, copy, nullable)   NSString *phoneNumber;
@property (nonatomic, strong, nullable) NSNumber *dialActionType;


@property (nonatomic, copy, nullable)   NSString *form_url;
@property (nonatomic, strong, nullable) NSNumber *form_width;
@property (nonatomic, strong, nullable) NSNumber *form_height;
@property (nonatomic, strong, nullable) NSNumber *use_size_validation;

//商圈广告地理位置相关信息
@property (nonatomic, copy, readonly, nullable) NSString *locationDistrict;
@property (nonatomic, copy, readonly, nullable) NSString *locationStreet;
@property (nonatomic, copy, readonly, nullable) NSString *locationDisdance;
//商圈广告点击位置落地页url
@property (nonatomic, copy, nullable) NSString *location_url;
@property (nonatomic, copy, nullable) NSDictionary *location_data;

/**
 广告创意类型
 string -> enum
 @return 创意类型的 枚举类型
 */
- (ExploreActionType)adType;
- (nullable NSString *)actionButtonTitle;

/// 2017/04/26 @刘文宇 下 icon AB测
- (BOOL)showActionButtonIcon;

@property (nonatomic, copy, nullable) NSArray<NSString *> *track_url_list;
@property (nonatomic, copy, nullable) NSArray<NSString *> *click_track_url_list;
@property (nonatomic, assign)            CGFloat  effectivePlayTime;
@property (nonatomic, copy, nullable ) NSArray <NSString *> *playTrackUrls;
@property (nonatomic, copy, nullable ) NSArray <NSString *> *activePlayTrackUrls;
@property (nonatomic, copy, nullable ) NSArray <NSString *> *effectivePlayTrackUrls;
@property (nonatomic, copy, nullable ) NSArray <NSString *> *playOverTrackUrls;

@property (nonatomic, strong, nullable) NSNumber *ui_type;

@end

@interface ExploreOrderedADModel (TTAdMointer)

/*
 * 端监控带上的基本广告数据 -> 定位广告
 */
- (nonnull NSDictionary *)mointerInfo;
@end

