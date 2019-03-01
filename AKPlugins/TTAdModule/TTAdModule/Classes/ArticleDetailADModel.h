//
//  ArticleDetailADModel.h
//  Article
//
//  Created by Zhang Leonardo on 14-2-20.
//
//

/*
 *  数据字段说明文档
 *  https://wiki.bytedance.net/pages/viewpage.action?pageId=87671732
 *
 */

#import "SSADBaseModel.h"
#import "ArticleDetailADVideoModel.h"

#define kPlayerOverTrackUrlList @"playover_track_url_list"
#define kPlayerEffectiveTrackUrlList @"effective_play_track_url_list"
#define kPlayerActiveTrackUrlList @"active_play_track_url_list"
#define kPlayerTrackUrlList @"play_track_url_list"
#define kClickTrackUrlList @"click_track_url_list"
#define kShowTrackUrlList @"track_url_list"
#define kEffectivePlayTime @"effective_play_time"


//视图展示样式
typedef NS_ENUM(NSInteger, TTAdViewDisplayStyle) {
    TTAdViewDisplayStyleDefault = 0,
    TTAdViewDisplayStyleLeft    = 1,
    TTAdViewDisplayStyleVideo   = 2,
    TTAdViewDisplayStyleLarge   = 3,
    TTAdViewDisplayStyleGroup   = 4
};

typedef NS_ENUM(NSInteger, ArticleDetailADModelType) {
    ArticleDetailADModelTypeBanner,
    /// v7新增的广告类型，图片
    ArticleDetailADModelTypeImage,
    /// 4.8新增应用下载广告
    ArticleDetailADModelTypeApp,
    ArticleDetailADModelTypeMixed,
    // 5.6新增头条号广告
    ArticleDetailADModelTypeMedia,
    // 5.6新增拨打电话广告
    ArticleDetailADModelTypePhone,
    // 5.8新增预约表单广告
    ArticleDetailADModelTypeAppoint,
    // 6.1 新增在线咨询
    ArticleDetailADModelTypeCounsel
};

@interface ArticleDetailADModel : SSADBaseModel <TTAd, TTAdAppAction>

@property (nonatomic, assign) ArticleDetailADModelType detailADType;
@property (nonatomic, strong) ArticleDetailADVideoModel *videoInfo;
@property (nonatomic, copy)   NSString *labelString;
@property (nonatomic, copy)   NSString *titleString;
@property (nonatomic, copy)   NSString *imageURLString;
@property (nonatomic, copy)   NSString *descString;
@property (nonatomic, assign) CGFloat  imageWidth;
@property (nonatomic, assign) CGFloat  imageHeight;

//视频详情页banner广告修改成新创意通投样式 为了不影响原来投在视频详情页老的大图样式，增加is_tongtou_ad字段区分是否是新样式 YES:新样式  NO:老样式
@property (nonatomic, assign) BOOL  isTongTouAd;

//5.5创意通投广告中加入广告来源名称
@property (nonatomic, copy)   NSString *sourceString;

//5.5创意通投广告展示类型
@property (nonatomic, assign) TTAdViewDisplayStyle displaySubtype;

//5.5创意通投拨打电话广告在mixed中
@property (nonatomic, copy)   NSString *mobile;

//5.6头条号广告，增加一个字段，对应下发数据的id字段，作为统计透传的创意通投id使用，含义非头条号id
@property (nonatomic, copy)   NSString *mediaID;

//added 5.7: 组图广告imageURLList
@property (nonatomic, strong) NSArray<NSDictionary *> *imageList;

//应用下载类型的广告(app_name字段在父类)
@property (nonatomic, copy)   NSString *downloadCount;
@property (nonatomic, copy)   NSString *appSize;
@property (nonatomic, copy)   NSString *buttonText;

//5.8增加预约创意,6.1 counsel 复用url跳转
@property (nonatomic, copy)   NSString *formUrl;
@property (nonatomic, strong) NSNumber *formWidth;
@property (nonatomic, strong) NSNumber *formHeight;
@property (nonatomic, strong) NSNumber *formSizeValid;

//5.9增加电话监听
@property (nonatomic, strong) NSNumber *dailActionType;

//5.9增加dislike
@property (nonatomic, strong) NSArray  *filterWords;
@property (nonatomic, assign) NSInteger showDislike;

@property (nonatomic, copy) NSString *key; //ad view identify

@property (nonatomic, copy)  NSString *groupId;
@property (nonatomic, assign) BOOL  isVideoAutoPlay;
@property (nonatomic, assign) BOOL  isVideoPlayInDetail;

- (instancetype)initWithDictionary:(NSDictionary *)data detailADType:(ArticleDetailADModelType)type;

- (BOOL)isModelAvailable;
@end

@interface ArticleDetailADModel (TTAdTracker)
- (void)trackWithTag:(NSString *)tag label:(NSString *)label extra:(NSDictionary *)extra;
- (void)sendTrackURLs:(NSArray<NSString *> *) urls;
- (void)trackRealTimeDownload;
@end

@interface ArticleDetailADModel (TTDataHelper)
- (NSString *)sourceText;
- (NSString *)actionButtonText;
- (NSString *)actionButtonIcon;
@end

