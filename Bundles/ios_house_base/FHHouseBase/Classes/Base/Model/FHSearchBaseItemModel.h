//
//  FHSearchBaseItemModel.h
//  FHHouseBase
//
//  Created by 张静 on 2019/11/8.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


//1. card_type=1 新房卡片
//2. card_type=2 二手房卡片
//3. card_type=3 租房卡片
//4. card_type=4小区卡片
//5. card_type=5 订阅卡片
//6. card_type=6 小区专家卡片
//7. card_type=7 全真房源文本卡片（eg：以为您找到全网xxx家经纪公司的xxx套房源）
//8. card_type=8 过滤文本卡片 （已为您过滤xxx套可疑房源）
//9. card_type=9 猜你想找tip（没有找到相关房源，猜你想找下面这些？）
//10. card_type=10猜你想找文本 （猜你想找）
//11. card_type=11切换城市卡片 （你是不是想找“xxx”的房源？）
//13. card_type=13 预约顾问
//17. card_type=17 浏览历史文本

typedef NS_ENUM(NSUInteger, FHSearchCardType) {
    FHSearchCardTypeNewHouse = 1, //1. card_type=1 新房卡片
    FHSearchCardTypeSecondHouse = 2,
    FHSearchCardTypeRentHouse = 3,
    FHSearchCardTypeNeighborhood = 4,
    FHSearchCardTypeSubscribe = 5,
    FHSearchCardTypeNeighborExpert = 6,
    FHSearchCardTypeAgencyInfo = 7,
    FHSearchCardTypeFilterHouseTip = 8,
    FHSearchCardTypeGuessYouWantTip = 9,
    FHSearchCardTypeGuessYouWantContent = 10,
    FHSearchCardTypeRedirectTip = 11,
    FHSearchCardTypeReserveAdviser = 13,
    FHSearchCardTypeAgentCard = 14,
    FHSearchCardTypeFindHouseHelper = 15,   //帮我找房卡片
    FHSearchCardTypeBrowseHistoryTip = 17,
};

@interface FHSearchBaseItemModel : JSONModel

@property (nonatomic, assign) NSInteger cardType;
@property (nonatomic, assign) NSInteger cellStyle;
@property (nonatomic, assign) CGFloat topMargin;


@end

NS_ASSUME_NONNULL_END
