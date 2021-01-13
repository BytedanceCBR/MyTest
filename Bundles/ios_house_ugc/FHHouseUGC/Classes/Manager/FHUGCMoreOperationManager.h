//
//  FHUGCMoreOperationManager.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/12/23.
//

#import <Foundation/Foundation.h>
#import "FHFeedUGCCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCMoreOperationManager : NSObject

- (void)showOperationAtView:(UIView *)view withCellModel:(FHFeedUGCCellModel *)cellModel;

@end

NS_ASSUME_NONNULL_END
