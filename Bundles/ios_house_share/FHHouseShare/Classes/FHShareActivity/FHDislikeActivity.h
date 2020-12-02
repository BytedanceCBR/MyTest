//
//  FHDislikeActivity.h
//  FHHouseShare
//
//  Created by bytedance on 2020/11/8.
//

#import <Foundation/Foundation.h>
#import <BDUGActivityProtocol.h>
#import "FHDislikeContentItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDislikeActivity : NSObject <BDUGActivityProtocol>

@property(nonatomic,strong) FHDislikeContentItem *contentItem;

@end

NS_ASSUME_NONNULL_END
