//
//  FHMapSearchSelectModel.h
//  DemoFunTwo
//
//  Created by 春晖 on 2019/7/10.
//  Copyright © 2019 chunhui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FHSearchConfigModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger , FHMapSearchTabIdType) {
    FHMapSearchTabIdTypeRegion = 1, // 区域
    FHMapSearchTabIdTypePrice = 2,
    FHMapSearchTabIdTypeRoom  = 3,
    FHMapSearchTabIdTypeDirection = 6,
    FHMapSearchTabIdTypeAge = 5,
    FHMapSearchTabIdTypePayType = 12,
    FHMapSearchTabIdTypeRentType = 13,
    FHMapSearchTabIdTypeRentTime = 14,
};


@interface FHMapSearchSelectItemModel : NSObject

@property(nonatomic , assign) NSInteger tabId;
@property(nonatomic , assign) NSInteger section;
@property(nonatomic , strong) NSMutableSet *selectIndexes;
@property(nonatomic , copy , nullable)   NSString *lowerPrice; //输入要允许输入 0000000
@property(nonatomic , copy , nullable)   NSString *higherPrice;
@property(nonatomic , copy)   NSNumber *rate;
@property(nonatomic , strong) FHSearchFilterConfigOption *configOption;

-(NSString *)selectQuery;

@end

@interface FHMapSearchSelectModel : NSObject

@property(nonatomic , strong) NSMutableArray<FHMapSearchSelectItemModel *> *items;

-(FHMapSearchSelectItemModel *)selectItemWithTabId:(NSInteger)tabId section:(NSInteger)section;

-(FHMapSearchSelectItemModel *)makeItemWithTabId:(NSInteger)tabId section:(NSInteger)section;

//多选 添加选择
-(void)addSelecteItem:(FHMapSearchSelectItemModel *)item withIndex:(NSInteger)index;
//单选
-(void)clearAddSelecteItem:(FHMapSearchSelectItemModel *)item withIndex:(NSInteger)index;

-(void)delSelecteItem:(FHMapSearchSelectItemModel *)item withIndex:(NSInteger)index;

-(BOOL)selecteItem:(FHMapSearchSelectItemModel *)item containIndex:(NSInteger)index;

-(void)clearAllSection;

-(NSString *)selectedQuery;

@end

NS_ASSUME_NONNULL_END
