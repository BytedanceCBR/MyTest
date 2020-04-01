//
//  FHUGCCellAttachCardView.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/3/19.
//

#import <UIKit/UIKit.h>
#import "FHFeedUGCCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCCellAttachCardView : UIView

@property(nonatomic ,strong) FHFeedUGCCellModel *cellModel;

- (void)refreshWithdata:(id)data;

@property(nonatomic, copy) void(^goToLinkBlock)(FHFeedUGCCellModel *cellModel, NSURL *url);

@end

NS_ASSUME_NONNULL_END
