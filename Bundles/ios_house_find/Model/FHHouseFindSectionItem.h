//
//  FHHouseFindSectionItem.h
//  FHHouseFind
//
//  Created by 张静 on 2019/1/4.
//

#import <Foundation/Foundation.h>
#import "FHHouseType.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseFindSectionItem : NSObject

@property (nonatomic , assign) FHHouseType houseType;
@property (nonatomic , assign) NSString *title;

@end

NS_ASSUME_NONNULL_END
