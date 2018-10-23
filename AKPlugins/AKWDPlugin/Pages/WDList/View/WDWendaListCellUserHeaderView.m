//
//  WDWendaListCellUserHeaderView.m
//  TTWenda
//
//  Created by wangqi.kaisa on 2017/12/27.
//

#import "WDWendaListCellUserHeaderView.h"
#import <TTAvatar/ExploreAvatarView+VerifyIcon.h>
#import <TTFriendRelation/TTFollowThemeButton.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <TTBaseLib/UIViewAdditions.h>
#import "WDCommonLogic.h"
#import "WDPersonModel.h"
#import "WDUIHelper.h"

#define kUserNameLabelFontSize 14
#define kUserDescLabelFontSize 12

@interface WDWendaListCellUserHeaderView ()

@property (nonatomic, strong) ExploreAvatarView *cellAvatarView;
@property (nonatomic, strong) SSThemedButton *userNameButton;
@property (nonatomic, strong) SSThemedLabel *userDescLabel;
@property (nonatomic, strong) TTFollowThemeButton *followButton;

@property (nonatomic, strong) NSMutableArray <SSThemedImageView*> *medalImageViews;

@end

@implementation WDWendaListCellUserHeaderView

+ (CGFloat)userHeaderHeight {
    return [WDWendaListCellUserHeaderView userAvatarTopPadding] + 36 + [WDWendaListCellUserHeaderView userAvatarBottomPadding];
}

+ (CGFloat)userAvatarTopPadding {
    return ([TTDeviceHelper isScreenWidthLarge320]) ? 15 : 14;
}

+ (CGFloat)userAvatarBottomPadding {
    return ([TTDeviceHelper isScreenWidthLarge320]) ? 6 : 5;
}

- (instancetype)initWithFrame:(CGRect)frame {
    CGRect newFrame = frame;
    newFrame.size.height = [WDWendaListCellUserHeaderView userHeaderHeight];
    self = [super initWithFrame:newFrame];
    if (self) {
        [self addSubview:self.cellAvatarView];
        [self addSubview:self.userNameButton];
        [self addSubview:self.userDescLabel];
        [self addSubview:self.followButton];
    }
    return self;
}

- (void)refreshUserInfoContent:(WDPersonModel *)user descInfo:(NSString *)descInfo followButtonHidden:(BOOL)hidden {
    [self.cellAvatarView setImageWithURLString:user.avatarURLString];
//    [self.cellAvatarView showOrHideVerifyViewWithVerifyInfo:user.userAuthInfo decoratorInfo:user.userDecoration];
    [self.userNameButton setTitle:user.name forState:UIControlStateNormal];
    [self.userDescLabel setText:descInfo];
    
    // add by zjing 去掉问答折叠cell的关注
    [self.followButton setHidden:YES];

//    [self.followButton setHidden:hidden];
    
    CGFloat availabelNameAndDescWidth = 0;
    if (hidden) {
        availabelNameAndDescWidth = self.width - kWDCellRightPadding - self.cellAvatarView.right - 10;
    } else {
        availabelNameAndDescWidth = self.width - kWDCellRightPadding - 43 - 20 - self.cellAvatarView.right - 10;
    }
    
    [self.userNameButton sizeToFit];
    CGFloat userNameLabelWidth = MIN(availabelNameAndDescWidth, ceilf(self.userNameButton.width));
    self.userNameButton.width = userNameLabelWidth;
    self.userNameButton.height = 20;
    if (isEmptyString(descInfo)) {
        self.userDescLabel.hidden = YES;
        CGFloat buttonOffset = ceilf(((self.cellAvatarView.height) - (self.userNameButton.height)) / 2.0f) + (self.cellAvatarView.top);
        self.userNameButton.origin = CGPointMake((self.cellAvatarView.right) + 10, buttonOffset);
    } else {
        self.userDescLabel.hidden = NO;
        self.userNameButton.origin = CGPointMake((self.cellAvatarView.right) + 10, (self.cellAvatarView.top));
        [self.userDescLabel sizeToFit];
        self.userDescLabel.height = 16;
        CGFloat userDescLabelWidth = MIN(availabelNameAndDescWidth, ceilf(self.userDescLabel.width));
        self.userDescLabel.width = userDescLabelWidth;
        self.userDescLabel.origin = CGPointMake((self.userNameButton.left), (self.userNameButton.bottom));
        if ([self.userDescLabel.text hasPrefix:@"「"]) {
            self.userDescLabel.left = (self.userNameButton.left) - 6.0f;
        }
    }
    
    self.followButton.right = self.width - kWDCellRightPadding;
    self.followButton.centerY = self.userNameButton.centerY;
    
    for (SSThemedImageView *imageView in self.medalImageViews) {
        [imageView removeFromSuperview];
    }
    [self.medalImageViews removeAllObjects];
    NSArray *medals = [self userMedals:user.medals];
    for (TTImageInfosModel *model in medals) {
        CGFloat x = self.userNameButton.right + 4;
        CGFloat height = 15;
        if (model.width > 0 && model.height > 0) {
            CGFloat width = (CGFloat) height * model.width / model.height;
            if (x + width > self.followButton.left) {
                continue;
            }
            
            SSThemedImageView *imageView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(x, 0, width, height)];
            imageView.centerY = self.userNameButton.centerY;
            imageView.enableNightCover = YES;
            NSURL *url = [NSURL URLWithString:[model urlStringAtIndex:0]];
            [imageView sd_setImageWithURL:url];
            x = imageView.right + 4;
            [self addSubview:imageView];
            [self.medalImageViews addObject:imageView];
        }
    }
}

- (void)refreshDescInfoContent:(NSString *)descInfo {
    self.userDescLabel.text = descInfo;
    
    // 关注按钮隐藏情况下才会修改
    CGFloat availabelNameAndDescWidth = self.width - kWDCellRightPadding - self.cellAvatarView.right - 10;
    
    if (isEmptyString(descInfo)) {
        self.userDescLabel.hidden = YES;
        CGFloat buttonOffset = ceilf(((self.cellAvatarView.height) - (self.userNameButton.height)) / 2.0f) + (self.cellAvatarView.top);
        self.userNameButton.origin = CGPointMake((self.cellAvatarView.right) + 10, buttonOffset);
    } else {
        self.userDescLabel.hidden = NO;
        self.userNameButton.origin = CGPointMake((self.cellAvatarView.right) + 10, (self.cellAvatarView.top));
        [self.userDescLabel sizeToFit];
        CGFloat userDescLabelWidth = MIN(availabelNameAndDescWidth, ceilf(self.userDescLabel.width));
        self.userDescLabel.width = userDescLabelWidth;
        self.userDescLabel.origin = CGPointMake((self.userNameButton.left), (self.userNameButton.bottom));
        if ([self.userDescLabel.text hasPrefix:@"「"]) {
            self.userDescLabel.left = (self.userNameButton.left) - 6.0f;
        }
    }
    
    for (SSThemedImageView *imageView in self.medalImageViews) {
        imageView.centerY = self.userNameButton.centerY;
    }

}

- (void)refreshFollowButtonState:(BOOL)isFollowing {
    [self.followButton setFollowed:isFollowing];
    self.followButton.hitTestEdgeInsets = UIEdgeInsetsMake(-15, -15, -15, -15);
}

- (void)setHighlighted:(BOOL)highlighted {
    if (highlighted) {
        self.userDescLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
        self.userNameButton.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
    } else {
        self.userDescLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        self.userNameButton.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    }
}

- (NSArray<TTImageInfosModel*>*)userMedals:(NSArray *)medals {
    if ([medals isKindOfClass:[NSArray class]]) {
        NSMutableArray* result = @[].mutableCopy;
        for (NSString* medal in medals) {
            if ([medal isKindOfClass:[NSString class]]) {
                NSDictionary* settingMedals = [WDCommonLogic ugcMedals];
                if ([settingMedals isKindOfClass:[NSDictionary class]]) {
                    NSDictionary* modelDic = [settingMedals tt_dictionaryValueForKey:medal];
                    TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithDictionary:modelDic];
                    if (model) {
                        [result addObject:model];
                    }
                }
            }
        }
        return result;
    }
    return nil;
}

- (void)avatarButtonClick:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(listCellUserHeaderViewAvatarClick)]) {
        [self.delegate listCellUserHeaderViewAvatarClick];
    }
}

- (void)followButtonClick:(TTFollowThemeButton *)followBtn {
    if ([self.delegate respondsToSelector:@selector(listCellUserHeaderViewFollowButtonClick:)]) {
        [self.delegate listCellUserHeaderViewFollowButtonClick:followBtn];
    }
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    
    self.cellAvatarView.layer.borderColor = SSGetThemedColorWithKey(kColorLine1).CGColor;
    self.userNameButton.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    self.userDescLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
}

- (ExploreAvatarView *)cellAvatarView {
    if (!_cellAvatarView) {
        _cellAvatarView = [[ExploreAvatarView alloc] initWithFrame:CGRectMake(kWDCellLeftPadding, [WDWendaListCellUserHeaderView userAvatarTopPadding], 36, 36)];
        _cellAvatarView.enableRoundedCorner = YES;
        _cellAvatarView.userInteractionEnabled = YES;
        _cellAvatarView.placeholder = @"big_defaulthead_head";
        
        // add by zjing 去掉问答折叠里面头像点击
//        [_cellAvatarView addTouchTarget:self action:@selector(avatarButtonClick:)];
        [_cellAvatarView setupVerifyViewForLength:36 adaptationSizeBlock:nil];
        
        UIView *coverView = [[UIView alloc] initWithFrame:_cellAvatarView.bounds];
        coverView.backgroundColor = [UIColor blackColor];
        coverView.layer.opacity = 0.05;
        coverView.layer.cornerRadius = coverView.width / 2.f;
        coverView.layer.masksToBounds = YES;
        [_cellAvatarView insertSubview:coverView belowSubview:self.cellAvatarView.verifyView];
    }
    return _cellAvatarView;
}

- (SSThemedButton *)userNameButton {
    if (!_userNameButton) {
        _userNameButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _userNameButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _userNameButton.titleColorThemeKey = kColorText1;
        _userNameButton.highlightedTitleColorThemeKey = kColorText1Highlighted;
        _userNameButton.titleLabel.font = [UIFont boldSystemFontOfSize:kUserNameLabelFontSize];
        _userNameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _userNameButton.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        // add by zjing 去掉问答折叠里面头像点击
//        [_userNameButton addTarget:self action:@selector(avatarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _userNameButton;
}

- (SSThemedLabel *)userDescLabel {
    if (!_userDescLabel) {
        _userDescLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _userDescLabel.font = [UIFont systemFontOfSize:kUserDescLabelFontSize];
        _userDescLabel.textColorThemeKey = kColorText3;
        _userDescLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    }
    return _userDescLabel;
}

- (TTFollowThemeButton *)followButton {
    if (!_followButton) {
        TTFollowedType followType = TTFollowedType102;
        TTUnfollowedType unFollowType = TTUnfollowedType102;
        TTFollowedMutualType mutualType = TTFollowedMutualType102;
        _followButton = [[TTFollowThemeButton alloc] initWithUnfollowedType:unFollowType followedType:followType followedMutualType:mutualType];
        
        [_followButton addTarget:self action:@selector(followButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _followButton;
}

@end
