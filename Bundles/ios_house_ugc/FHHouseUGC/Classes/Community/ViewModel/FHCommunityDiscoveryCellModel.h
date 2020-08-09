//
//  FHCommunityDiscoveryCellModel.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/4/21.
//

#import <Foundation/Foundation.h>
#import "FHHouseUGCHeader.h"
#import "FHUGCCategoryModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHCommunityDiscoveryCellModel : NSObject

@property(nonatomic , assign) FHCommunityCollectionCellType type;
@property (nonatomic, copy , nullable) NSString *category;
@property (nonatomic, copy , nullable) NSString *name;
//埋点
@property(nonatomic, strong) NSDictionary *tracerDict;

+ (FHCommunityDiscoveryCellModel *)cellModelForCategory:(FHUGCCategoryDataDataModel *)model;

@end

NS_ASSUME_NONNULL_END
