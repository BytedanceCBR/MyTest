//
//  FHIMActivity.h
//  FHHouseShare
//
//  Created by bytedance on 2020/11/9.
//

#import <Foundation/Foundation.h>
#import <BDUGActivityProtocol.h>
#import "FHIMContentItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHIMActivity : NSObject <BDUGActivityProtocol>

@property(nonatomic,strong) FHIMContentItem *contentItem;

@end

NS_ASSUME_NONNULL_END
