//
//  FHUGCCellHeaderView.h
//  AKCommentPlugin
//
//  Created by 谢思铭 on 2019/6/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCCellHeaderView : UIView

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIButton *moreBtn;
@property(nonatomic, strong) UIView *bottomLine;
@property(nonatomic, strong) UIButton *refreshBtn;

- (void)setMoreBtnLayout;

@end

NS_ASSUME_NONNULL_END
