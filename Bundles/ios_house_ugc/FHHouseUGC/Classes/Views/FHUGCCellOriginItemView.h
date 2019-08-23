//
//  FHUGCCellOriginItemView.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/7/19.
//

#import <UIKit/UIKit.h>
#import "FHFeedUGCCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCCellOriginItemView : UIView

@property(nonatomic ,strong) FHFeedUGCCellModel *cellModel;

- (void)refreshWithdata:(id)data;

@end

NS_ASSUME_NONNULL_END