//
// Created by zhulijun on 2019-06-12.
//

#import <Foundation/Foundation.h>

@class FHUGCFollowButton;
@class FHCommunityDetailRefreshView;


@interface FHCommunityDetailHeaderView : UIView
@property(nonatomic, strong) UIImageView *topBack;
@property(nonatomic, strong) UIImageView *avatar;
@property(nonatomic, strong) UIView *labelContainer;
@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) UILabel *subtitleLabel;
@property(nonatomic, strong) FHUGCFollowButton *followButton;
@property(nonatomic, strong) UIView *publicationsContainer;
@property(nonatomic, strong) UILabel *publicationsLabel;
@property(nonatomic, strong) UILabel *publicationsContentLabel;
@property(nonatomic) CGFloat headerBackHeight;
@property(nonatomic, strong) FHCommunityDetailRefreshView *refreshView;

- (void)startRefresh;

- (void)stopRefresh;

- (void)updateWhenScrolledWithContentOffset:(CGPoint)contentOffset isScrollTop:(BOOL)isScrollTop;
@end
