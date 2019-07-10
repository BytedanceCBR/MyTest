//
//  FHRentFacilitiesModel.h
//  FHHouseBase
//
//  Created by 春晖 on 2019/7/3.
//

#import "JSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHRentFacilitiesModel <NSObject>

@end

@interface FHRentFacilitiesModel : JSONModel

@property (nonatomic, copy , nullable) NSString *iconUrl;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *name;

@end

NS_ASSUME_NONNULL_END
