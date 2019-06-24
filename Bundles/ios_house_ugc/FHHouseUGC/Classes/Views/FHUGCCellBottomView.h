//
//  FHUGCCellBottomView.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/4.
//

#import <UIKit/UIKit.h>
#import "FHFeedUGCCellModel.h"
#import "FHUGCFeedGuideView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCCellBottomView : UIView

@property(nonatomic ,strong) UILabel *position;
@property(nonatomic ,strong) UIButton *commentBtn;
@property(nonatomic ,strong) UIView *positionView;
@property(nonatomic ,strong) FHUGCFeedGuideView *guideView;
@property(nonatomic ,strong) FHFeedUGCCellModel *cellModel;

- (void)updateLikeState:(NSString *)diggCount userDigg:(NSString *)userDigg;
- (void)showPositionView:(BOOL)isShow;

@end

NS_ASSUME_NONNULL_END
