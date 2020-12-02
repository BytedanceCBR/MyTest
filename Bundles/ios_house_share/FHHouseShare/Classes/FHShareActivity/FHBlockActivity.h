//
//  FHBlockActivity.h
//  FHHouseShare
//
//  Created by bytedance on 2020/11/8.
//

#import <Foundation/Foundation.h>
#import <BDUGActivityProtocol.h>
#import "FHBlockContentItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHBlockActivity : NSObject <BDUGActivityProtocol>

@property(nonatomic,strong) FHBlockContentItem *contentItem;

@end

NS_ASSUME_NONNULL_END
