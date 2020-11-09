//
//  FHReportContentItem.h
//  FHHouseUGC
//
//  Created by bytedance on 2020/11/8.
//

#import "BDUGShareBaseContentItem.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * const FHActivityContentItemTypeReport = @"com.f100.ActivityContentItem.Report";

@interface FHReportContentItem : BDUGShareBaseContentItem

@property(nonatomic,copy) void (^reportBlcok)(void);

@end

@interface FHShareReportDataModel : NSObject

@property(nonatomic,copy) void (^reportBlcok)(void);

@end

NS_ASSUME_NONNULL_END
