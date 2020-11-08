//
//  FHReportActivity.h
//  FHHouseUGC
//
//  Created by bytedance on 2020/11/8.
//

#import <Foundation/Foundation.h>
#import <BDUGActivityProtocol.h>
#import "FHReportContentItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHReportActivity : NSObject <BDUGActivityProtocol>

@property(nonatomic,strong) FHReportContentItem *contentItem;

@end

NS_ASSUME_NONNULL_END
