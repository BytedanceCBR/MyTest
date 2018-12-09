//
//  FHHomeConfigManager.h
//  Article
//
//  Created by 谢飞 on 2018/11/21.
//

#import <Foundation/Foundation.h>
#import <FHHouseBase/FHMainApi.h>
#import <ReactiveObjC/ReactiveObjC.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHomeConfigManager : NSObject

@property(nonatomic , strong) RACReplaySubject *configDataReplay;
@property(nonatomic , strong) FHConfigDataModel *currentDataModel;
@property(nonatomic , strong) NSDictionary *currentDictionary;
@property (nonatomic,assign)BOOL isNeedTriggerPullDownUpdate;
@property (nonatomic,assign)BOOL isTraceClickIcon;

+(instancetype)sharedInstance;
//从原有数据源接收数据
- (void)acceptConfigDictionary:(NSDictionary *)configDict;

- (void)currentNeedRequestConfig:(NSString *)cityId cityGeoCode:(NSString *)cityCode lat:(double)latValue lon:(double)lonValue cityName:(NSString *)cityName;

- (void)updateConfigDataFromCache;

- (void)openCategoryFeedStart;

- (void)startUpdateAllConfig;

@end

NS_ASSUME_NONNULL_END
