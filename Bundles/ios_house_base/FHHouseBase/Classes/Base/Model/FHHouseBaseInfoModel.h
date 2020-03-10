//
//  FHHouseBaseInfoModel.h
//  FHHouseBase
//
//  Created by 春晖 on 2019/6/17.
//

#import "JSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHHouseBaseInfoModel <NSObject>


@end

@interface FHHouseBaseInfoModel : JSONModel

@property (nonatomic, assign) BOOL isSingle;
@property (nonatomic, copy , nullable) NSString *attr;
@property (nonatomic, copy , nullable) NSString *value;
@property (nonatomic, copy , nullable) NSString *color;

@end

NS_ASSUME_NONNULL_END
