//
//  FHFillFormAgencyListItemModel.h
//  FHHouseBase
//
//  Created by 张静 on 2019/5/5.
//

#import "JSONModel.h"

NS_ASSUME_NONNULL_BEGIN


@protocol FHFillFormAgencyListItemModel<NSObject>
@end

@interface FHFillFormAgencyListItemModel : JSONModel

@property (nonatomic, copy , nullable) NSString *agencyId;
@property (nonatomic, copy , nullable) NSString *agencyName;
@property (nonatomic, assign) BOOL checked;

- (nonnull id)copyWithZone:(nullable NSZone *)zone;

@end

NS_ASSUME_NONNULL_END
