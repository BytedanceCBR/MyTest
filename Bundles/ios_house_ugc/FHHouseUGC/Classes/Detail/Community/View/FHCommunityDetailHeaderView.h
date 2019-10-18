//
// Created by zhulijun on 2019-06-12.
//

#import <Foundation/Foundation.h>

#define PublicationsContentLabel_numberOfLines 2
#define PublicationsContentLabel_lineHeight 20

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
@property(nonatomic, strong) UIView  *userCountBgView;// 控制userCountLabel显示和隐藏
@property(nonatomic, strong) UILabel *userCountLabel;
@property(nonatomic, strong) UIImageView *userCountRightArrow;
@property(nonatomic, strong) FHUGCFollowButton *followButton;
@property(nonatomic, strong) UIView *publicationsContainer;
@property(nonatomic, strong) UILabel *publicationsContentLabel;
@property(nonatomic, strong) UILabel *publicationsDetailViewTitleLabel;
@property(nonatomic, copy) GotoPublicationsDetailBlock gotoPublicationsDetailBlock;               // 公告区显示详情按钮block
@property (nonatomic, copy)     dispatch_block_t       gotoSocialFollowUserListBlk;
@property(nonatomic) CGFloat headerBackHeight;
// 运营位部分
@property(nonatomic, copy) GotoOperationDetailBlock gotoOperationBlock;
@property(nonatomic, strong) UIImageView *operationBannerImageView;

- (void)startRefresh;

- (void)stopRefresh;

- (void)updateWhenScrolledWithContentOffset:(CGPoint)contentOffset isScrollTop:(BOOL)isScrollTop;

- (void)updateOperationInfo:(BOOL)isShow whRatio:(CGFloat)whRatio;

- (void)updatePublicationsInfo:(BOOL)isShow hasDetailBtn:(BOOL)hasDetailBtn;

// 非管理员状态，判断如果没有查看详情按钮时公告内容标签的布局是否超过两行
-(BOOL)isPublicationsContentLabelLargerThanTwoLineWithoutDetailButtonShow;
@end
