//
//  TTPersonalHomeHeaderView.m
//  Article
//
//  Created by 王迪 on 2017/3/13.
//
//

#import "TTPersonalHomeHeaderView.h"
#import "UIImageView+WebCache.h"
#import <BDWebImage/SDWebImageAdapter.h>
@interface TTPersonalHomeHeaderView ()

@property (nonatomic, assign) CGFloat introduceRealHeight;
@property (nonatomic, assign) CGFloat interduceHeight;
@property (nonatomic, weak) SSThemedImageView *starNextView;
@property (nonatomic, weak) SSThemedLabel *starLabel;
@property (nonatomic, assign) CGFloat starNextViewX;
@property (nonatomic, strong) UIVisualEffectView    *zoomVisualEffectView;
@end

@implementation TTPersonalHomeHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        self.backgroundColorThemeKey = kColorBackground4;
        [self setupSubview];
    }
    return self;
}

- (void)setupSubview
{
    SSThemedImageView *zoomView = [[SSThemedImageView alloc] init];
    zoomView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    zoomView.frame = CGRectMake(0, 0, self.width, TTHeaderViewZoomViewHeight());
    zoomView.contentMode = UIViewContentModeScaleAspectFill;
    zoomView.enableNightCover = YES;
    zoomView.userInteractionEnabled = YES;
    zoomView.clipsToBounds = YES;
    [self addSubview:zoomView];
    self.zoomView = zoomView;
    
    _zoomVisualEffectView = ({
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        effectView.frame = zoomView.bounds;
        effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        effectView.alpha = 0.5;
        [zoomView addSubview:effectView];
        effectView;
    });
    
    SSThemedImageView *starNextView = [[SSThemedImageView alloc] init];
    starNextView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    starNextView.imageName = @"star_next";
    starNextView.hidden = YES;
    [zoomView addSubview:starNextView];
    self.starNextView = starNextView;
    starNextView.userInteractionEnabled = YES;
    UITapGestureRecognizer *nextViewClick = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(starClick)];
    [starNextView addGestureRecognizer:nextViewClick];
    
    SSThemedLabel *starNextLabel = [[SSThemedLabel alloc] init];
    starNextView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    starNextLabel.textColorThemeKey = kColorText8;
    starNextLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:13]];
    starNextLabel.hidden = YES;
    starNextLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *nextLabelClick = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(starClick)];
    [starNextLabel addGestureRecognizer:nextLabelClick];
    [zoomView addSubview:starNextLabel];
    self.starLabel = starNextLabel;
    
    TTPersonalHomeHeaderOperationView *operationView = [[TTPersonalHomeHeaderOperationView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0)];
    operationView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [operationView.followButton addTarget:self action:@selector(didSelectedFollowButton:) forControlEvents:UIControlEventTouchUpInside];
    [operationView.unBlockView addTarget:self action:@selector(unBlockClick) forControlEvents:UIControlEventTouchUpInside];
    [operationView.profileView addTarget:self action:@selector(profileBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [operationView.recommendViewOperationBtn addTarget:self action:@selector(didSelectRecommendUserOperationBtn:) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconViewClick)];
    [operationView.iconView addGestureRecognizer:tap];
    [self addSubview:operationView];
//    [operationView.privateMessageBtn addTarget:self action:@selector(privateMessageClick) forControlEvents:UIControlEventTouchUpInside];
//    [operationView.certificationBtn addTarget:self action:@selector(certificationClick) forControlEvents:UIControlEventTouchUpInside];

    self.operationView = operationView;
    
//    TTPersonalHomeRecommendFollowView *recommendFollowView = [[TTPersonalHomeRecommendFollowView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0)];
//    recommendFollowView.hidden = YES;
//    recommendFollowView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    [self addSubview:recommendFollowView];
//    self.recommendFollowView = recommendFollowView;
    
    TTPersonalHomeHeaderInfoView *infoView = [[TTPersonalHomeHeaderInfoView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0)];
    infoView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [infoView.spreadOutBtn addTarget:self action:@selector(introduceBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:infoView];
    self.infoView = infoView;
    WeakSelf;
    infoView.multiplePlatformFollowersInfoViewSpreadOutBlock = ^(BOOL spreadOut) {
        StrongSelf;
        if ([self.delegate respondsToSelector:@selector(headerView:didSelectedMultiplePlatformFollowersInfoViewSpreadOut:)]) {
            [self.delegate headerView:self didSelectedMultiplePlatformFollowersInfoViewSpreadOut:spreadOut];
        }
    };
    
    self.operationView.frame = CGRectMake(0, self.zoomView.bottom, self.width, self.operationView.height);
    self.infoView.frame = CGRectMake(0, self.operationView.bottom, self.width, self.infoView.height);
    self.height = self.infoView.bottom;
}

- (void)setInfoModel:(TTPersonalHomeUserInfoDataResponseModel *)infoModel
{
    _infoModel = infoModel;
    [self.zoomView sda_setImageWithURL:[NSURL URLWithString:infoModel.avatar_url] placeholderImage:[UIImage imageNamed:@"default_avatar"] options:SDWebImageRetryFailed];
    
    if(infoModel.star_chart && infoModel.star_chart.Rate.integerValue <= 100 && infoModel.star_chart.Rate.integerValue > 0) {
        self.starLabel.hidden = NO;
        self.starNextView.hidden = NO;
        self.starNextView.width = 8;
        self.starNextView.height = 10;
        self.starNextView.right = self.zoomView.width - [TTDeviceUIUtils tt_newPadding:15];
        self.starNextViewX = self.starNextView.left;
        self.starLabel.text = [NSString stringWithFormat:@"明星排行榜第%@名", infoModel.star_chart.Rate];
        CGSize starLabelSize = [self.starLabel.text sizeWithAttributes:@{NSFontAttributeName : self.starLabel.font}];
        self.starLabel.width = starLabelSize.width;
        self.starLabel.height = [TTDeviceUIUtils tt_newPadding:17];
        self.starLabel.right = self.starNextView.left - [TTDeviceUIUtils tt_newPadding:2];
        self.starLabel.bottom = self.zoomView.height - [TTDeviceUIUtils tt_newPadding:10];
        self.starNextView.centerY = self.starLabel.centerY;

    }else {
        self.starLabel.hidden = YES;
        self.starNextView.hidden = YES;
    }
    
    self.operationView.infoModel = infoModel;
    self.infoView.infoModel = infoModel;
    self.operationView.frame = CGRectMake(0, self.zoomView.bottom, self.width, self.operationView.height);
//    CGFloat infoViewHeight = self.recommendFollowView.isSpread && self.recommendFollowView.height > 0 ?self.operationView.bottom - self.operationView.sanjiaoIcon.height + self.recommendFollowView.height : self.operationView.bottom - self.operationView.sanjiaoIcon.height;
    CGFloat infoViewHeight = self.operationView.bottom - self.operationView.sanjiaoIcon.height;
    self.infoView.frame = CGRectMake(0, infoViewHeight, self.width, self.infoView.height);
//    self.recommendFollowView.userID = self.infoModel.user_id;
//    self.recommendFollowView.left = 0;
//    self.recommendFollowView.top = self.operationView.bottom;
//    self.recommendFollowView.width = self.width;
    self.height = self.infoView.bottom;
    if ([TTDeviceHelper isPadDevice]) {
        return;
    }
//    if (infoModel.live_data)
//    {
//        if (!_xiguaLiveView) {
//            TTXiguaLiveProfileView *xiguaLiveView = [[TTXiguaLiveProfileView alloc] initWithFrame:CGRectMake(0, self.infoView.bottom, self.width, ceil(self.width/2.09))];
//            xiguaLiveView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//            [self addSubview:xiguaLiveView];
//            self.xiguaLiveView = xiguaLiveView;
//        }
//        self.xiguaLiveView.frame = CGRectMake(0, self.infoView.bottom, self.width, ceil(self.width/2.09));
//        self.height = self.xiguaLiveView.bottom;
//        TTXiguaLiveProfileModel *livemodel = [[TTXiguaLiveProfileModel alloc] init];
//        livemodel.title = infoModel.live_data.title;
//        livemodel.watchCount = @(infoModel.live_data.live_info.watching_count);
//        livemodel.avatarUrl = self.infoModel.big_avatar_url;
//        livemodel.userID = self.infoModel.user_id;
//        livemodel.roomID = infoModel.live_data.live_info.room_id;
//        livemodel.groupID = infoModel.live_data.group_id;
//        livemodel.groupSource = infoModel.live_data.group_source;
//        livemodel.largeImage = infoModel.live_data.large_image;
//        livemodel.categoryName = @"pgc";
//        self.xiguaLiveView.liveModel = livemodel;
//    }else{
//        if (self.xiguaLiveView.superview) {
//            self.height = self.xiguaLiveView.bottom;
//        }
//    }
}

- (void)updateStarLocationWithOffset:(CGFloat)offset
{
    if(!self.starNextView.hidden && !self.starLabel.hidden) {
        if(offset == 0 && [TTDeviceHelper OSVersionNumber] < 8.0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.starLabel.bottom = self.zoomView.height - [TTDeviceUIUtils tt_newPadding:10];
                self.starNextView.centerY = self.starLabel.centerY;
            });
        } else {
            self.starLabel.bottom = self.zoomView.height - [TTDeviceUIUtils tt_newPadding:10];
            self.starNextView.centerY = self.starLabel.centerY;
        }
        if(offset >= 0) offset = 0;
        self.starNextView.right = self.zoomView.width - [TTDeviceUIUtils tt_newPadding:15] + offset;
        self.starLabel.right = self.starNextView.left - [TTDeviceUIUtils tt_newPadding:2];
    }
}

-(void)adjustInfoViewTopMargin:(CGFloat)topMargin
{
    [self.infoView setupSubviewFrameWithTopMargin:topMargin];
    self.height = self.infoView.bottom;
//    [self adjustXiguaLiveViewFrame];
}

- (void)refreshUIWithMultiplePlatformFollowersInfoViewSpreadOut:(BOOL)spreadOut
{
    [self.infoView refreshUIWithMultiplePlatformFollowersInfoViewSpreadOut:spreadOut];
    self.height = self.infoView.bottom;
//    [self adjustXiguaLiveViewFrame];
}

//- (void)adjustXiguaLiveViewFrame
//{
//    if (self.xiguaLiveView) {
//        self.xiguaLiveView.top = self.infoView.bottom;
//        self.height = self.xiguaLiveView.bottom;
//    }
//}

//- (void)showRecommendViewIsSpread:(BOOL)isSpread {
//    self.clipsToBounds = YES;
//    self.recommendFollowView.isSpread = isSpread;
//    if(isSpread) {
//        [self.recommendFollowView prepare];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kHeaderAnimationTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            self.clipsToBounds = NO;
//
////            [self.recommendFollowView.collectionView willDisplay];
//        });
//    } else {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kHeaderAnimationTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            self.clipsToBounds = NO;
//            self.recommendFollowView.height = 0;
//
//            [self.recommendFollowView.collectionView didEndDisplaying];
//        });
//    }
//}

- (void)dealloc {
//    [self.recommendFollowView.collectionView didEndDisplaying];
}

#pragma mark - followView 代理
- (void)didSelectedFollowButton:(TTFollowThemeButton*) button {
    if ([button isKindOfClass:[TTFollowThemeButton class]]) {
        if (button.followed) {
            if([self.delegate respondsToSelector:@selector(headerViewDidSelectedCancelFollow)]) {
                [self.delegate headerViewDidSelectedCancelFollow];
            }
        } else {
            if([self.delegate respondsToSelector:@selector(headerViewDidSelectedFollow)]) {
                [self.delegate headerViewDidSelectedFollow];
            }
        }
    }
}

- (void)didSelectRecommendUserOperationBtn:(UIButton*) btn {
    if([self.delegate respondsToSelector:@selector(headerView:didSelectedFollowSpreadOut:)]) {
        [self.delegate headerView:self didSelectedFollowSpreadOut:btn.selected];
    }
    btn.selected = !btn.selected;
    [UIView animateWithDuration:0.25 animations:^{
        if(btn.selected) {
            btn.imageView.transform =  CGAffineTransformMakeRotation(M_PI);
        } else {
            btn.imageView.transform = CGAffineTransformMakeRotation(0);
        }
    }];
}

- (void)introduceBtnClick:(SSThemedButton *)btn
{
    btn.selected = !btn.selected;
    if([self.delegate respondsToSelector:@selector(headerView:didSelectedIntroduceSpreadOut:)]) {
        [self.delegate headerView:self didSelectedIntroduceSpreadOut:btn.selected];
    }
}

- (void)unBlockClick
{
    if([self.delegate respondsToSelector:@selector(headerViewDidSelectedUnBlock)]) {
        [self.delegate headerViewDidSelectedUnBlock];
    }
}

- (void)profileBtnClick
{
    if([self.delegate respondsToSelector:@selector(headerViewDidSelectedProfile)]) {
        [self.delegate headerViewDidSelectedProfile];
    }
}

- (void)iconViewClick
{
    if([self.delegate respondsToSelector:@selector(headerViewDidSelectedIconView)]) {
        [self.delegate headerViewDidSelectedIconView];
    }
}

- (void)privateMessageClick
{
    if([self.delegate respondsToSelector:@selector(headerViewDidSelectedPrivateMessage)]) {
        [self.delegate headerViewDidSelectedPrivateMessage];
    }
}

//- (void)certificationClick
//{
//    if([self.delegate respondsToSelector:@selector(headerViewDidSelectedCertification)]) {
//        [self.delegate headerViewDidSelectedCertification];
//    }
//}

- (void)starClick
{
    if([self.delegate respondsToSelector:@selector(headerViewDidSelectedStar)]) {
        [self.delegate headerViewDidSelectedStar];
    }
}

@end
