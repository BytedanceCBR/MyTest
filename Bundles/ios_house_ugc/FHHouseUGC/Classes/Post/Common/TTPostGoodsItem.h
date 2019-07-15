//
//  TTPostGoodsItem.h
//  TTPostThread
//
//  Created by 李沛伦 on 2019/1/28.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTPostGoodsItem : JSONModel
@property (nonatomic, copy) NSString *product_id;
@property (nonatomic, copy) NSString *promotion_id;
@property (nonatomic, copy) NSString<Optional> *title;
@property (nonatomic, copy) NSString<Optional> *cover;
@property (nonatomic, copy) NSNumber<Optional> *price;
@property (nonatomic, copy) NSNumber<Optional> *market_price;
@property (nonatomic, copy) NSNumber<Optional> *cos_fee;
@property (nonatomic, copy) NSString<Optional> *detail_url;
@property (nonatomic, copy) NSNumber<Optional> *sales;
@property (nonatomic, copy) NSNumber<Optional> *item_type;
@property (nonatomic, copy) NSNumber<Optional> *cos_ratio;
@property (nonatomic, copy) NSNumber<Optional> *favor;
@end

NS_ASSUME_NONNULL_END
