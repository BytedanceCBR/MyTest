//
//  TSVRecUserSinglePersonCollectionViewCell.m
//  Article
//
//  Created by 王双华 on 2017/9/27.
//

#import "TSVRecUserSinglePersonCollectionViewCell.h"
#import <TTUIWidget/TTAlphaThemedButton.h>
#import "TTAsyncCornerImageView.h"
#import "TTAsyncCornerImageView+VerifyIcon.h"
#import "SSThemed.h"
#import "TTFollowThemeButton.h"
#import <TTBaseLib/UIViewAdditions.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <TTVerifyKit/TTVerifyIconHelper.h>

@interface TSVRecUserSinglePersonCollectionViewCell()

@property (nonatomic, strong) TTAsyncCornerImageView *avatarView;
@property (nonatomic, strong) SSThemedLabel *nameLabel;
@property (nonatomic, strong) SSThemedLabel *descLabel;
@property (nonatomic, strong) TTFollowThemeButton *followButton;

@end

@implementation TSVRecUserSinglePersonCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.avatarView = ({
            TTAsyncCornerImageView *avatarView = [[TTAsyncCornerImageView alloc] initWithFrame:CGRectMake(0, 0 , 66, 66) allowCorner:YES];
            avatarView.cornerRadius = avatarView.width / 2;
            [avatarView setupVerifyViewForLength:66 adaptationSizeBlock:nil];
            avatarView.userInteractionEnabled = NO;
            avatarView.coverColor = [[UIColor blackColor] colorWithAlphaComponent:0.05];
            avatarView.placeholderName = @"default_sdk_login";
            avatarView.borderWidth = 0;
            avatarView;
        });
        [self.contentView addSubview:self.avatarView];
        
        self.nameLabel = ({
            SSThemedLabel *label = [[SSThemedLabel alloc] init];
            label.font = [UIFont boldSystemFontOfSize:14.f];
            label.textColorThemeKey = kColorText15;
            label.textAlignment = NSTextAlignmentCenter;
            label;
        });
        [self.contentView addSubview:self.nameLabel];
        
        self.descLabel = ({
            SSThemedLabel *label = [[SSThemedLabel alloc] init];
            label.font = [UIFont systemFontOfSize:12.f];
            label.textColorThemeKey = kColorText15;
            label.textAlignment = NSTextAlignmentCenter;
            label;
        });
        [self.contentView addSubview:self.descLabel];
        
        self.followButton = ({
            TTFollowThemeButton *button = [[TTFollowThemeButton alloc] initWithUnfollowedType:TTUnfollowedType101
                                                                                 followedType:TTFollowedType101
                                                                           followedMutualType:TTFollowedMutualType101];
            @weakify(self);
            [[[button rac_signalForControlEvents:UIControlEventTouchUpInside]
              takeUntil:self.rac_willDeallocSignal]
             subscribeNext:^(id x) {
                 @strongify(self);
                 if (self.handleFollowBtnTapBlock) {
                     self.handleFollowBtnTapBlock();
                 }
             }];
            button;
        });
        [self.contentView addSubview:self.followButton];
        
        self.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        self.layer.cornerRadius = 4.f;
        self.layer.borderColor = [UIColor tt_themedColorForKey:kColorLine1].CGColor;
        self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        
        @weakify(self);
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:TTThemeManagerThemeModeChangedNotification object:nil]
          takeUntil:self.rac_willDeallocSignal]
         subscribeNext:^(id x) {
             @strongify(self);
             self.layer.borderColor = [UIColor tt_themedColorForKey:kColorLine1].CGColor;
             self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
         }];
        
        [CATransaction commit];
        
        [self bindViewModel];
    }
    
    return self;
}

- (void)layoutSubviews {
    [UIView performWithoutAnimation:^{
        [super layoutSubviews];
        CGFloat centerX = self.contentView.width / 2;
        self.avatarView.centerX = centerX;
        self.avatarView.top = 12;
        
        CGFloat width = self.contentView.width - 15 * 2;
        self.nameLabel.width = width;
        self.nameLabel.height = 20;
        self.nameLabel.top = self.avatarView.bottom + 10;
        self.nameLabel.centerX = centerX;
        
        self.descLabel.width = width;
        self.descLabel.height = 17;
        self.descLabel.top = self.nameLabel.bottom + 1;
        self.descLabel.centerX = centerX;
        
        self.followButton.constWidth = width;
        self.followButton.centerX = centerX;
        self.followButton.bottom = self.contentView.height - 12;
    }];
}

- (void)bindViewModel
{
    @weakify(self);
    [RACObserve(self, viewModel.avatarURL) subscribeNext:^(NSString *url) {
        @strongify(self);
        [self.avatarView tt_setImageWithURLString:url];
    }];
    [RACObserve(self, viewModel.userAuthInfo) subscribeNext:^(NSString *userAuthInfo) {
        @strongify(self);
        [self.avatarView showOrHideVerifyViewWithVerifyInfo:userAuthInfo decoratorInfo:nil sureQueryWithID:YES userID:nil];
    }];
    RAC(self, nameLabel.text) = RACObserve(self, viewModel.userName);
    RAC(self, descLabel.text) = RACObserve(self, viewModel.recommendReason);
    RACChannelTo(self, followButton.followed, @NO) = RACChannelTo(self, viewModel.isFollowing);
}

@end
