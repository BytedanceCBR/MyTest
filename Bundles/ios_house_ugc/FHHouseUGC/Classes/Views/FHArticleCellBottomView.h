//
//  FHArticleCellBottomView.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/5.
//

#import <UIKit/UIKit.h>
#import "FHFeedUGCCellModel.h"
#import "FHUGCFeedGuideView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHArticleCellBottomView : UIView

@property(nonatomic ,strong) UILabel *position;
@property(nonatomic ,strong) UILabel *descLabel;
@property(nonatomic ,strong) UIButton *moreBtn;
@property(nonatomic ,strong) UIView *positionView;
@property(nonatomic ,strong) FHUGCFeedGuideView *guideView;

@property(nonatomic ,strong) FHFeedUGCCellModel *cellModel;
@property(nonatomic, copy) void(^deleteCellBlock)(void);

- (void)showPositionView:(BOOL)isShow;

@end

NS_ASSUME_NONNULL_END
