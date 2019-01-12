//
//  FHHomeConfigManager.h
//  Article
//
//  Created by 谢飞 on 2018/11/21.
//

#import <Foundation/Foundation.h>
#import <FHHouseBase/FHMainApi.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "FHHomeBridgeProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, FHHomeHeaderCellPositionType) {
    FHHomeHeaderCellPositionTypeForNews,  //首页推荐频道排序
    FHHomeHeaderCellPositionTypeForFindHouse //找房频道排序
};


@interface FHHomeConfigManager : NSObject

@property(nonatomic , strong) FHConfigDataModel *currentDataModel;
@property(nonatomic , strong) NSDictionary *currentDictionary;
@property (nonatomic, assign) BOOL isNeedTriggerPullDownUpdate;
@property (nonatomic, assign) BOOL isNeedTriggerPullDownUpdateFowFindHouse;
@property (nonatomic, assign) BOOL isTraceClickIcon;
@property (nonatomic, strong) NSString * enterType;

+(instancetype)sharedInstance;
//从原有数据源接收数据
- (void)acceptConfigDictionary:(NSDictionary *)configDict;

- (void)acceptConfigDataModel:(FHConfigDataModel *)configModel;


- (void)currentNeedRequestConfig:(NSString *)cityId cityGeoCode:(NSString *)cityCode lat:(double)latValue lon:(double)lonValue cityName:(NSString *)cityName;

- (void)updateConfigDataFromCache;

- (void)openCategoryFeedStart;

- (id<FHHomeBridgeProtocol>)fhHomeBridgeInstance;

@end

NS_ASSUME_NONNULL_END
