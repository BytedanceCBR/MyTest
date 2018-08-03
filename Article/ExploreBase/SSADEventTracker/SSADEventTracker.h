//
//  SSADEventTracker.h
//  Article
//
//  Created by Zhang Leonardo on 13-11-4.
//
//

#import <Foundation/Foundation.h>
#import "TTGroupModel.h"
#import "TTADEventTrackerEntity.h"
/*
// Feed广告 show与show over打点场景区分
// 需求：https://wiki.bytedance.net/pages/viewpage.action?pageId=70857634
**/
typedef NS_ENUM(NSInteger, TTADShowScene) {
    TTADShowRefreshScene,        //刷新触发的show场景
    TTADShowReturnScene,         //1）从文章详情页退出，再看到广告 2）切到其他APP，再回到列表
    TTADShowChangechannelScene   //切到临近频道，页面不再渲染
};

@class TTADEventTrackerEntity;
@class ExploreOrderedData;
@protocol TTAd;

@interface SSADEventTracker : NSObject

+ (instancetype)sharedManager;

- (void)sendADWithOrderedData:(ExploreOrderedData *)orderedData
                        event:(NSString *)event
                        label:(NSString *)label
                        extra:(NSDictionary *)exitra;

- (void) trackEventWithOrderedData:(ExploreOrderedData *) orderedData
                             label:(NSString *) label
                         eventName:(NSString *) eventName;//默认 show track url
- (void) trackEventWithOrderedData:(ExploreOrderedData *) orderedData
                             label:(NSString *) label
                         eventName:(NSString *) eventName
                      clickTrackUrl:(BOOL)showTrackUrl;

- (void) trackEventWithOrderedData:(ExploreOrderedData *) orderedData
                             label:(NSString *) label
                         eventName:(NSString *) eventName
                             extra:(NSString *) extra
                      clickTrackUrl:(BOOL)showTrackUrl;

- (void) trackEventWithOrderedData:(ExploreOrderedData *) orderedData
                             label:(NSString *) label
                         eventName:(NSString *) eventName
                             extra:(NSDictionary *) extra
                          duration:(NSTimeInterval)duration;
// 针对Feed广告show和show over事件统计的方法
- (void)trackShowWithOrderedData:(ExploreOrderedData *) orderedData
                           extra:(NSDictionary *) extra
                           scene:(TTADShowScene)  scene;

- (void)trackShowOverWithOrderedData:(ExploreOrderedData *) orderedData
                               extra:(NSDictionary *) extra
                               scene:(TTADShowScene)  scene
                            duration:(NSTimeInterval) duration;

- (void)trackShowOverWithOrderedData:(ExploreOrderedData *) orderedData
                               extra:(NSDictionary *) extra;


- (void)willShowAD:(NSString *)adID scene:(TTADShowScene)scene;

- (TTADShowScene)showOverSceneForAd:(NSString *)adID;

- (NSTimeInterval)durationForAdThisTime:(NSString *)adID;

- (void)clearAllAdShow;

/**
 视频重构
 */
- (void)trackEventWithEntity:(TTADEventTrackerEntity *)entity
                       label:(NSString *)label
                   eventName:(NSString *)eventName;

- (void)trackEventWithEntity:(TTADEventTrackerEntity *)entity
                       label:(NSString *)label
                   eventName:(NSString *)eventName
               clickTrackUrl:(BOOL)showTrackUrl;

- (void)trackEventWithEntity:(TTADEventTrackerEntity *)entity
                       label:(NSString *)label
                   eventName:(NSString *)eventName
                       extra:(NSString *)extra
               clickTrackUrl:(BOOL)showTrackUrl;

- (void)trackEventWithEntity:(TTADEventTrackerEntity *)entity
                       label:(NSString *)label
                   eventName:(NSString *)eventName
                       extra:(NSString *)extra;

- (void)trackEventWithEntity:(TTADEventTrackerEntity *)entity
                       label:(NSString *)label
                   eventName:(NSString *)eventName
                       extra:(NSDictionary *)extra
                    duration:(NSTimeInterval)duration;

- (void)trackEventWithOrderedData:(ExploreOrderedData *) orderedData
                            label:(NSString *) label
                        eventName:(NSString *) eventName
                            extra:(NSDictionary *) extra
                         duration:(NSTimeInterval)duration
                            scene:(TTADShowScene) scene;

+ (void)sendTrackURLs:(NSArray<NSString *> *)urls with:(id<TTAd>) model;

+ (void)trackWithModel:(id<TTAd>)model tag:(NSString *)tag label:(NSString *)label extra:(NSDictionary *)extra;

@end
