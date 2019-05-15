//
//  TTAdRefreshRelateModel1.h
//  Article
//
//  Created by ranny_90 on 2017/3/20.
//
//

#import <JSONModel/JSONModel.h>

//图片预加载网络条件
typedef NS_ENUM(NSUInteger, TTPredownloadType) {
    TTPredownloadType_wifi = 1,     //wifi条件
    TTPredownloadType_4g,           //4g条件
    TTPredownloadType_3g,           //3g条件
    TTPredownloadType_2g,           //2g条件
    TTPredownloadType_mobile,       //mobile条件
    TTPredownloadType_all           //所有条件
};

@class TTAdImageModel;
@protocol TTAdImageModel;

//单个广告model
@interface TTAdRefreshItemModel : JSONModel

//广告id
@property(nonatomic,copy)NSString<Optional> *adID;

//广告对应的频道id
@property(nonatomic,copy)NSString<Optional> *channel_id;

//开始展示时间间隔
@property(nonatomic,strong)NSNumber<Optional> *display_after;

//结束展示时间间隔
@property(nonatomic,strong)NSNumber<Optional> *expire_seconds;

//图片预加载网络条件 1:wifi 2:4g 4:3g 8:2g 16:mobile 31:all
@property(nonatomic,strong)NSNumber<Optional> *predownload;

//图片展示限制频次
@property(nonatomic,strong)NSNumber<Optional> *show_limit;

//是否预览-------bool值怎样optional
@property(nonatomic,assign)BOOL is_preview;

//第三方监控url
@property(nonatomic,strong)NSArray<Optional> *track_url_list;

//广告图片信息
@property(nonatomic,strong)NSArray<Optional, TTAdImageModel>* image_list;

//监控上报信息
@property(nonatomic,strong)NSString<Optional> *log_extra;


//展示开启时间
@property(nonatomic,strong)NSDate<Optional> *displayStartTime;

//展示过期时间
@property(nonatomic,strong)NSDate<Optional> *displayExpiredTime;


//更新展示合适时间
-(void)updateDisplayDate;

-(BOOL)isSuitableTimeToDisplayWithDate:(NSDate *)date;


@end



@class TTAdRefreshItemModel;
@protocol TTAdRefreshItemModel;

//接口广告总数据model
@interface TTAdRefreshRelateModel : JSONModel

//请求网络接口的时间间隔
@property(nonatomic,strong)NSNumber<Optional> *request_after;

//广告数组
@property(nonatomic,strong)NSArray<Optional, TTAdRefreshItemModel> *ad_item;

@property (nonatomic,strong)NSDictionary<Optional> *adItemsDictionary;

-(void)updateAdItemsDictionary;


@end


//单个频道展示的下拉刷新的次数
@interface TTADRefreshChannelShowTimeModel :  NSObject<NSCoding>

@property (nonatomic,copy)NSString *channelId;

@property (nonatomic,strong)NSNumber *showTimes;

@property (nonatomic,copy)NSDate *showDate;

-(id)initWithChannelId:(NSString *)channelId;

@end

@protocol TTADRefreshChannelShowTimeModel;

@protocol NSArray;

//所有频道展示的下拉刷新的次数
@interface TTADRefreshShowTimeModel : NSObject<NSCoding>

@property(nonatomic,strong)NSMutableDictionary <NSString *,TTADRefreshChannelShowTimeModel *>*showLimitDic;

@end
