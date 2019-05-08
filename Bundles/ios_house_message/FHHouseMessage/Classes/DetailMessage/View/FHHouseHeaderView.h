//
//  FHHouseHeaderView.h
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/2/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseHeaderView : UIView

@property(nonatomic, strong) UIView *dateView;
@property(nonatomic, strong) UILabel *dateLabel;
@property(nonatomic, strong) UIView *contentView;
@property(nonatomic, strong) UILabel *contentLabel;
@property(nonatomic, strong) UIView *bottomLine;

- (void)setContentViewMargin:(UIEdgeInsets)edgeInsets;

@end

NS_ASSUME_NONNULL_END
