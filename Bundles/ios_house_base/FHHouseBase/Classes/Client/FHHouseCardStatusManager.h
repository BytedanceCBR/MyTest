//
//  FHHouseCardManager.h
//  FHHouseBase
//
//  Created by xubinbin on 2020/12/21.
//

#import <Foundation/Foundation.h>
#import "FHHouseType.h"

const float FHHouseCardReadOpacity = 0.5;  //已读卡片透明度
const float FHHouseCardTouchAnimateTime = 0.2;  //触摸动效动画时长
const float FHHouseCardShrinkRate = 0.9;  //触摸动效卡片缩小率

NS_ASSUME_NONNULL_BEGIN

//已读未读功能协议
@protocol FHHouseCardReadStateProtocol <NSObject>

@required

//渲染已读房源卡片UI
- (void)refreshOpacityWithData:(id)data;

@end

//触摸动效协议
@protocol FHHouseCardTouchAnimationProtocol <NSObject>

@required

//触摸动效，卡片缩小
- (void)shrinkWithAnimation;

//触摸动效，卡片还原
- (void)restoreWithAnimation;

@end

@interface FHHouseCardStatusManager : NSObject

+ (instancetype)sharedInstance;

//把阅读的房源卡片记录到内存
- (void)readHouseId:(NSString *)houseId withHouseType:(NSInteger)houseType;

//判断是否阅读过该房源卡片
- (BOOL)isReadHouseId:(NSString *)houseId withHouseType:(NSInteger)houseType;

@end

NS_ASSUME_NONNULL_END
