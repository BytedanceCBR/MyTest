//
//  TTAdFeedDefine.h
//  Article
//
//  Created by carl on 2017/8/27.
//
//

#import <Foundation/Foundation.h>
#import "TTAdConstant.h"

#define kSeperatorString        @"://"

@class TTImageInfosModel;

typedef NS_ENUM(NSInteger, ExploreActionType) {
    ExploreActionTypeApp,
    ExploreActionTypeWeb,
    ExploreActionTypeAction,
    ExploreActionTypeForm,
    ExploreActionTypeCounsel,
    ExploreActionTypeDiscount, // 优惠券类型
    ExploreActionTypeCoupon,   // 新优惠券(可直接领取)
    
    //商圈广告相关类型
    ExploreActionTypeLocationAction,
    ExploreActionTypeLocationForm,
    ExploreActionTypeLocationcounsel
};

typedef NS_ENUM(NSInteger, TTAdFeedCellDisplayType) {
    TTAdFeedCellDisplayTypeSmall = 1,                // 旧版小图模式
    TTAdFeedCellDisplayTypeLarge = 2,                // 新版大图模式
    TTAdFeedCellDisplayTypeGroup = 3,                // 新版组(三)图模式
    TTAdFeedCellDisplayTypeRight = 4,                // 新版小(右)图模式
    TTAdFeedCellDisplayTypeSlider = 5,               // 轮播
    TTAdFeedCellDisplayTypeFullScreen = 6,           // 2D 全景广告
    TTAdFeedCellDisplayTypeLarge_ImageChannel = 7,   // 图片频道大图广告
    TTAdFeedCellDisplayTypeLarge_VideoChannel = 8,   // 视频频道大图广告
    TTAdFeedCellDisplayType3DPanorama = 9            // 3D全景广告
};


@protocol TTAdFeedModel <TTAd, TTAdAppAction>

@property (nonatomic, copy, nullable)   NSString *type;   // 创意类型
@property (nonatomic, assign) NSInteger displayType;


@property (nonatomic, copy, nullable) NSString *sub_title;


@property (nonatomic, copy, nullable)   NSString *webURL;
@property (nonatomic, copy, nullable)   NSString *webTitle;

@property (nonatomic, copy, nullable)   NSString *appName;
@property (nonatomic, copy, nullable)   NSString *descInfo;

@property (nonatomic, copy, nullable)   NSString *form_url;
@property (nonatomic, strong, nullable) NSNumber *form_width;
@property (nonatomic, strong, nullable) NSNumber *form_height;
@property (nonatomic, strong, nullable) NSNumber *use_size_validation;

@property (nonatomic, copy, nullable)   NSString *phoneNumber;
@property (nonatomic, strong, nullable) NSNumber *dialActionType;

@property (nonatomic, strong, nullable) NSNumber *hideIfExists;

//商圈广告地理位置相关信息
@property (nonatomic, copy, readonly, nullable) NSString *locationDistrict;
@property (nonatomic, copy, readonly, nullable) NSString *locationStreet;
@property (nonatomic, copy, readonly, nullable) NSString *locationDisdance;
//商圈广告点击位置落地页url
@property (nonatomic, copy, nullable) NSString *location_url;
@property (nonatomic, copy, nullable) NSDictionary *location_data;

@property (nonatomic, copy, nullable) NSArray<NSString *> *track_url_list;
@property (nonatomic, copy, nullable) NSArray<NSString *> *click_track_url_list;

@property(nonatomic, assign)          CGFloat  effectivePlayTime;
@property(nonatomic, copy, nullable ) NSArray <NSString *> *playTrackUrls;
@property(nonatomic, copy, nullable ) NSArray <NSString *> *activePlayTrackUrls;
@property(nonatomic, copy, nullable ) NSArray <NSString *> *effectivePlayTrackUrls;
@property(nonatomic, copy, nullable ) NSArray <NSString *> *playOverTrackUrls;

/**
 广告创意类型
 string -> enum
 @return 创意类型的 枚举类型
 */
- (ExploreActionType)adType;
- (nullable NSString *)actionButtonTitle;
- (BOOL)isCreativeAd;
- (BOOL)showActionButton;

/// 2017/04/26 @刘文宇 下 icon AB测
- (BOOL)showActionButtonIcon;

- (NSDictionary *_Nonnull )mointerInfo;

@property (nonatomic, copy, nullable)   NSString *title;
@property (nonatomic, strong, nullable) NSNumber *ui_type; // 控制创意按钮位置 1 下方 0 右下角
@property (nonatomic, strong, nullable) TTImageInfosModel *imageModel;
@property (nonatomic, copy, nullable)   NSString *source;
@end

