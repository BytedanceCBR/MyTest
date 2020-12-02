//
//  FHCollectActivity.h
//  FHHouseShare
//
//  Created by bytedance on 2020/11/9.
//

#import <Foundation/Foundation.h>
#import <BDUGActivityProtocol.h>
#import "FHCollectContentItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHCollectActivity : NSObject <BDUGActivityProtocol>

@property(nonatomic,strong) FHCollectContentItem *contentItem;

@end

NS_ASSUME_NONNULL_END
