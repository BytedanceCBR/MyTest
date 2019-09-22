//
// Created by zhulijun on 2019-06-12.
//

#import <Foundation/Foundation.h>

@class FHUGCFollowButton;
@class FHCommunityDetailMJRefreshHeader;


typedef void(^GotoOperationDetailBlock)(void);
typedef void(^GotoPublicationsDetailBlock)(void);

@interface FHCommunityDetailHeaderView : UIView
@property(nonatomic, strong) UIImageView *topBack;
@property(nonatomic, strong) UIImageView *avatar;
@property(nonatomic, strong) UIView *labelContainer;
@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) UILabel *subtitleLabel;
@property(nonatomic, strong) FHUGCFollowButton *followButton;
@property(nonatomic, strong) UIView *publicationsContainer;
@property(nonatomic, strong) UILabel *publicationsContentLabel;
@property(nonatomic, strong) UILabel *publicationsDetailViewTitleLabel;
@property(nonatomic, copy) GotoPublicationsDetailBlock gotoPublicationsDetailBlock;
@property(nonatomic) CGFloat headerBackHeight;
// 运营位部分
@property(nonatomic, copy) GotoOperationDetailBlock gotoOperationBlock;
@property(nonatomic, strong) UIImageView *operationBannerImageView;

- (void)startRefresh;

- (void)stopRefresh;

- (void)updateWhenScrolledWithContentOffset:(CGPoint)contentOffset isScrollTop:(BOOL)isScrollTop;

- (void)updateOperationInfo:(BOOL)isShow whRatio:(CGFloat)whRatio;

- (void)updatePublicationsInfo:(BOOL)isShow hasDetailBtn:(BOOL)hasDetailBtn;
@end
