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

@property(nonatomic ,strong) UILabel *position;
@property(nonatomic ,strong) UILabel *descLabel;
@property(nonatomic ,strong) UIButton *moreBtn;
@property(nonatomic ,strong) UIButton *answerBtn;
@property(nonatomic ,strong) UIView *positionView;
 
@property(nonatomic ,strong) FHFeedUGCCellModel *cellModel;

- (void)showPositionView:(BOOL)isShow;

- (void)updateIsQuestion;

- (void)refreshWithData:(FHFeedUGCCellModel *)cellModel;

@end

NS_ASSUME_NONNULL_END
