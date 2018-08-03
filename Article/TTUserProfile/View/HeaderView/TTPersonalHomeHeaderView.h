//
//  TTPersonalHomeHeaderView.h
//  Article
//
//  Created by 王迪 on 2017/3/13.
//
//

#import "SSThemed.h"
#import "TTPersonalHomeHeaderInfoView.h"
//#import "TTPersonalHomeRecommendFollowView.h"
#import "TTPersonalHomeHeaderOperationView.h"
//#import "TTXiguaLiveProfileView.h"

static CGFloat TTHeaderViewZoomViewHeight() {
    if ([TTDeviceHelper isIPhoneXDevice]) {
        return 146.f;
    } else {
        return 122.f;
    }
}

#define kHeaderAnimationTime 0.3

@class TTPersonalHomeHeaderView;

@protocol TTPersonalHomeHeaderViewDelegate <NSObject>
@optional
- (void)headerViewDidSelectedFollow;
- (void)headerViewDidSelectedCancelFollow;
- (void)headerViewDidSelectedUnBlock;
- (void)headerViewDidSelectedProfile;
- (void)headerViewDidSelectedIconView;
- (void)headerViewDidSelectedPrivateMessage;
- (void)headerViewDidSelectedCertification;
- (void)headerViewDidSelectedStar;
- (void)headerView:(TTPersonalHomeHeaderView *)headerView didSelectedFollowSpreadOut:(BOOL)isSpread;
- (void)headerView:(TTPersonalHomeHeaderView *)headerView didSelectedIntroduceSpreadOut:(BOOL)isSpread;
- (void)headerView:(TTPersonalHomeHeaderView *)headerView didSelectedMultiplePlatformFollowersInfoViewSpreadOut:(BOOL)spreadOut;

@end

@interface TTPersonalHomeHeaderView : SSThemedView

@property (nonatomic, weak) SSThemedImageView *zoomView;
@property (nonatomic, weak) TTPersonalHomeHeaderOperationView *operationView;
@property (nonatomic, weak) TTPersonalHomeHeaderInfoView *infoView;
//@property (nonatomic, weak) TTPersonalHomeRecommendFollowView *recommendFollowView;
//@property (nonatomic, weak) TTXiguaLiveProfileView *xiguaLiveView;
@property (nonatomic, weak) id <TTPersonalHomeHeaderViewDelegate> delegate;
@property (nonatomic, strong) TTPersonalHomeUserInfoDataResponseModel *infoModel;

- (void)showRecommendViewIsSpread:(BOOL)isSpread;
- (void)adjustInfoViewTopMargin:(CGFloat)topMargin;
- (void)refreshUIWithMultiplePlatformFollowersInfoViewSpreadOut:(BOOL)spreadOut;

- (void)updateStarLocationWithOffset:(CGFloat)offset;

@end
