//
//  TTVCommodityEntity.h
//  Article
//
//  Created by panxiang on 2017/8/8.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TTVCommoditySourceType) {
    TTVCommoditySourceTypeUnknown,
    TTVCommoditySourceTypeTmall = 1,
    TTVCommoditySourceTypeTaobao = 2,
    TTVCommoditySourceTypeJingdong = 3,
    TTVCommoditySourceTypeJuhuasuan = 6
};

@interface TTVCommodityEntity : NSObject
@property (nonatomic ,copy)NSString *image_url;
@property (nonatomic ,copy)NSString *source;
@property (nonatomic ,assign)TTVCommoditySourceType source_type;//1 天猫  2 淘宝  6 聚划算   3 京东
@property (nonatomic ,copy)NSString *charge_url;
@property (nonatomic ,copy)NSString *commodity_id;
@property (nonatomic ,copy)NSString *title;
@property (nonatomic ,assign)NSInteger insert_time;
@property (nonatomic ,assign)float price;
@property (nonatomic ,assign)NSInteger display_duration;
@property (nonatomic ,assign)BOOL isShowed;
@property (nonatomic ,assign)BOOL isDismissed;
@property (nonatomic ,assign)NSInteger coupon_type; //1.直减  2.折扣
@property (nonatomic ,assign)float coupon_num;  // 直减：单位是元  折扣：单位是折


+ (TTVCommodityEntity *)entityWithDictionary:(NSDictionary *)dic;
@end
