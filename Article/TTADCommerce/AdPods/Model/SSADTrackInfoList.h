//
//  SSADTrackInfoList.h
//  Article
//
//  Created by Dai Dongpeng on 5/4/16.
//
//

#import <JSONModel/JSONModel.h>

typedef NS_ENUM(NSInteger, SSSplashADReadyType) {
    SSSplashADReadyTypeUnknow = -1,
    SSSplashADReadyTypeSuccess = 0,
    SSSplashADReadyTypeNonArrival = 1, // 时间未到
    SSSplashADReadyTypeExpired = 2, // 时间过期
    SSSplashADReadyTypeIntervalFromBGNotMach = 3,//从后台切回前台频率过快
    SSSplashADReadyTypeIntervalFromLastNotMatch = 4,//图片展示频率过快
    SSSplashADReadyTypeHide = 5,//wifi only或者 hide_if_exist
    SSSplashADReadyTypeImageEmpty = 6, //广告图片没有加载完成
    SSSplashADReadyTypeSizeNotMatch = 7,
    
    ///...
    SSSplashADReadyTypeFullscreenVideoEmpty = 8,    // 全屏类型的视频 not ready
    SSSplashADReadyTypeVideoReadyWithoutImage = 9,  // 非全屏类型视频，有视频无图
    SSSplashADReadyTypeImageReadyWithoutVideo = 10, // 非全屏类型视频，有图无视频
    SSSplashADReadyTypeVideoImageAllEmpty = 11      // 非全屏类型视频，无图无视频
    
    //    SSSplashADReadyTypeWiFiOnly = 4,
    //    SSSplashADReadyTypeOrderEmpty = 5, //轮空
    //    SSSplashADReadyTypeModelEmpty = 6, //广告计划没有下载完成
};

@class SSADTrackInfoHistory;
@class SSADTrackInfoLog;
@protocol SSADTrackInfoHistory <NSObject>
@end
@protocol  SSADTrackInfoLog <NSObject>
@end

@interface SSADTrackInfoList : JSONModel

@property (nonatomic, strong) NSNumber *fetchTime;

- (void)addInfoLog:(SSADTrackInfoLog *)log;
- (void)setPreloadListArray:(NSArray *)preloadIDs;
- (NSDictionary *)toCustomJSONDictionary;

@end

@interface SSADTrackInfoLog : JSONModel <SSADTrackInfoLog>

@property (nonatomic, copy) NSString *logID;
@property (nonatomic, strong) NSMutableArray <SSADTrackInfoHistory> *historyList;

- (void)addHistory:(SSADTrackInfoHistory *)history;
- (void)addHistoryArray:(NSArray <SSADTrackInfoHistory *> *)hisArray;

- (instancetype)initWithLogID:(NSString *)logID;
@end

@interface SSADTrackInfoHistory : JSONModel <SSADTrackInfoHistory>

@property (nonatomic, copy) NSString <Ignore> *logID;
@property (nonatomic) NSUInteger count;
@property (nonatomic) SSSplashADReadyType statue;

@end
