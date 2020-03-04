//
//  FHSpecialTopicHeaderView.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/2/20.
//

#import <Foundation/Foundation.h>
#import "FHCommunityDetailRefreshHeader.h"
#import "FHSpecialTopicHeaderModel.h"

#define PublicationsContentLabel_numberOfLines 2
#define PublicationsContentLabel_lineHeight 20

@class FHUGCFollowButton;
@class FHCommunityDetailMJRefreshHeader;


typedef void(^GotoOperationDetailBlock)(void);
typedef void(^GotoPublicationsDetailBlock)(void);

@interface FHSpecialTopicHeaderView : UIView
@property(nonatomic, strong) UIImageView *topBack;
@property(nonatomic, strong) UIImageView *topBgView;
//@property(nonatomic, strong) UIImageView *avatar;
//@property(nonatomic, strong) UIView *labelContainer;
@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) UILabel *subtitleLabel;
//@property (nonatomic, assign)   BOOL       userCountShowen;// 控制userCountLabel显示和隐藏
//@property(nonatomic, strong) UIView  *userCountSepLine;
//@property(nonatomic, strong) UILabel *userCountLabel;
//@property(nonatomic, strong) UIImageView *userCountRightArrow;
@property(nonatomic) CGFloat headerBackHeight;
// 运营位部分
//@property(nonatomic, copy) GotoOperationDetailBlock gotoOperationBlock;
//@property(nonatomic, strong) UIImageView *operationBannerImageView;

@property (nonatomic, strong) FHCommunityDetailRefreshHeader *refreshHeader;
@property (nonatomic, assign) BOOL scrollViewDidEndDrag;

- (void)updateWhenScrolledWithContentOffset:(CGFloat)offset isScrollTop:(BOOL)isScrollTop scrollView:(UIScrollView *)scrollView;

@end
