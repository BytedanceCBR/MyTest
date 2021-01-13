//
//  FHArticleCellBottomView.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/5.
//

#import <UIKit/UIKit.h>
#import "FHFeedUGCCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHArticleCellBottomView : UIView

- (void)refreshWithData:(FHFeedUGCCellModel *)cellModel;

@end

NS_ASSUME_NONNULL_END
