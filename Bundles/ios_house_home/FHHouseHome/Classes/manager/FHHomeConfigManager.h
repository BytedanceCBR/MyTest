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

@property (nonatomic, assign) BOOL isNeedTriggerPullDownUpdate;
@property (nonatomic, assign) BOOL isNeedTriggerPullDownUpdateFowFindHouse;
@property (nonatomic, assign) BOOL isTraceClickIcon;
@property (nonatomic, strong) NSString * enterType;

+(instancetype)sharedInstance;

- (void)openCategoryFeedStart;

- (id<FHHomeBridgeProtocol>)fhHomeBridgeInstance;

@end

NS_ASSUME_NONNULL_END
