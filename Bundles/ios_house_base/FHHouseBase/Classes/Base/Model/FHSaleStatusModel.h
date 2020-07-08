//
//  FHSaleStatusModel.h
//  FHHouseBase
//
//  Created by bytedance on 2020/7/2.
//

#import "JSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHSaleStatusModel : JSONModel

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *textColor;

@end

NS_ASSUME_NONNULL_END
