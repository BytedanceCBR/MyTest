//
//  FHHouseFindSelectModel.h
//  FHHouseFind
//
//  Created by 春晖 on 2019/2/13.
//

#import <Foundation/Foundation.h>
#import <FHHouseBase/FHSearchConfigModel.h>
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger , FHSearchTabIdType) {
    FHSearchTabIdTypeRegion = 1, // 区域
    FHSearchTabIdTypePrice = 2,
    FHSearchTabIdTypeRoom  = 3,
    FHSearchTabIdTypeDirection = 6,
    FHSearchTabIdTypeAge = 5,
    FHSearchTabIdTypeHouse = 7,
    FHSearchTabIdTypePayType = 12,
    FHSearchTabIdTypeRentType = 13,
    FHSearchTabIdTypeRentTime = 14,
};

typedef enum : NSInteger {
    FHHouseFindPriceFromTypeDefault = 0,
    FHHouseFindPriceFromTypeHelp,
} FHHouseFindPriceFromType;

@interface FHHouseFindSelectItemModel : NSObject

@property(nonatomic , assign) NSInteger tabId;
@property(nonatomic , strong) NSMutableArray *selectIndexes;
@property(nonatomic , copy)   NSString *lowerPrice; //输入要允许输入 0000000
@property(nonatomic , copy)   NSString *higherPrice;
@property(nonatomic , copy)   NSNumber *rate;
@property(nonatomic , assign)   FHHouseFindPriceFromType fromType;
@property(nonatomic , strong) FHSearchFilterConfigOption *configOption;

-(NSString *)selectQuery;
-(NSString *)selectQueryForFindingHouse;
- (NSDictionary *)associateInfoForFindingHouse;

@end

@interface FHHouseFindSelectModel : NSObject

@property(nonatomic , strong) NSMutableArray<FHHouseFindSelectItemModel *> *items;

-(FHHouseFindSelectItemModel *)selectItemWithTabId:(NSInteger)tabId;

-(FHHouseFindSelectItemModel *)makeItemWithTabId:(NSInteger)tabId;

//多选 添加选择
-(void)addSelecteItem:(FHHouseFindSelectItemModel *)item withIndex:(NSInteger)index;
//单选
-(void)clearAddSelecteItem:(FHHouseFindSelectItemModel *)item withIndex:(NSInteger)index;

-(void)delSelecteItem:(FHHouseFindSelectItemModel *)item withIndex:(NSInteger)index;

-(BOOL)selecteItem:(FHHouseFindSelectItemModel *)item containIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
