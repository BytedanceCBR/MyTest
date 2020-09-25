//
//  FHShortVideoTracerUtil.h
//  FHHouseUGC
//
//  Created by liuyu on 2020/9/25.
//

#import <Foundation/Foundation.h>
#import "FHFeedUGCCellModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHShortVideoTracerUtil : NSObject
+ (void)feedClientShowWithmodel:(FHFeedUGCCellModel *)model eventIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
