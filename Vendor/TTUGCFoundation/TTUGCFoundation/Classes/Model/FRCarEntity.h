//
//  FRCarEntity.h
//  Article
//
//  Created by 王霖 on 16/7/8.
//
//

#import <JSONModel/JSONModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface FRCarEntity : JSONModel

@property (nonatomic, copy) NSString * carSeries; //车系
@property (nonatomic, copy) NSString * carType; //车型
@property (nonatomic, copy) NSString * country; //国家
@property (nonatomic, copy) NSString * oilConsume; //油耗
@property (nonatomic, copy) NSString * price; //价格
@property (nonatomic, copy) NSString * coverUrl; //封面图
@property (nonatomic, assign) NSInteger imageNum; //图片数量
@property (nonatomic, copy) NSString * imageOpenUrl; //图片跳转schema
@property (nonatomic, copy) NSString * openUrl; //更多参数跳转schema
@property (nonatomic, copy) NSString * brand; //汽车品牌名
@property (nonatomic, copy) NSString * priceUrl; //价格详情页url

@end

NS_ASSUME_NONNULL_END
