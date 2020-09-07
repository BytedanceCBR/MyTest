//
//  FHHouseSaleInputModel.h
//  FHHouseTrend
//
//  Created by 谢思铭 on 2020/9/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseSaleInputModel : NSObject

//小区信息
@property(nonatomic ,copy ,nullable) NSString *neighbourhoodId;
@property(nonatomic ,copy ,nullable) NSString *neighbourhoodName;
//户型
@property(nonatomic ,copy ,nullable) NSString *floor;
//面积
@property(nonatomic ,copy ,nullable) NSString *area;
//称呼
@property(nonatomic ,copy ,nullable) NSString *name;
//手机号
@property(nonatomic ,copy ,nullable) NSString *phoneNumber;

@end

NS_ASSUME_NONNULL_END
