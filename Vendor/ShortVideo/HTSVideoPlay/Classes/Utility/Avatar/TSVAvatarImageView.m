//
//  TSVAvatarImageView.m
//  HTSVideoPlay
//
//  Created by dingjinlu on 2018/1/8.
//

#import "TSVAvatarImageView.h"
#import "NSStringAdditions.h"
#import "NSDictionary+TTAdditions.h"
#import "TTDeviceHelper.h"
#import "TTThemeManager.h"
#import "ReactiveObjC.h"
#import "TTImageView.h"
#import "TSVUserModel.h"

@implementation TSVAvatarImageView

- (instancetype)initWithFrame:(CGRect)frame model:(TSVUserModel *)model disableNightMode:(BOOL)disable
{
    self = [super initWithFrame:frame];
    if (self) {
        self.placeholder = @"hts_vp_head_icon";
        self.userInteractionEnabled = YES;
        self.enableRoundedCorner = YES;
        self.disableNightMode = disable;
        self.verifyView.disableNightMode = disable;
        self.enableBlackMaskView = NO;
        self.imageView.enableNightCover = !disable;
        self.imageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
        [self setImageWithURLString:model.avatarURL?:@""];
        [self showOrHideVerifyViewWithVerifyInfo:model.userAuthInfo decoratorInfo:model.userDecoration sureQueryWithID:YES userID:nil disableNightCover:disable];
        self.disableNightMode = disable;
        self.highlightedMaskView = nil; // 取消点击态
        
        @weakify(self);
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:TTThemeManagerThemeModeChangedNotification object:nil]
          takeUntil:self.rac_willDeallocSignal]
         subscribeNext:^(NSNotification * _Nullable x) {
             @strongify(self);
             if (!self.disableNightMode) {
                 self.borderColor = [UIColor tt_themedColorForKey:kColorBackground4];
             }
         }];
    }
    return self;
}

- (void)refreshWithModel:(TSVUserModel *)model
{
    [self setImageWithURLString:model.avatarURL?:@""];

    [self showOrHideVerifyViewWithVerifyInfo:model.userAuthInfo decoratorInfo:model.userDecoration sureQueryWithID:YES userID:nil disableNightCover:self.disableNightMode];

    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [UIView performWithoutAnimation:^{
        [self setupVerifyViewForLength:self.bounds.size.width adaptationSizeBlock:^CGSize(CGSize standardSize) {
            return [TTVerifyIconHelper tt_newSize:standardSize];
        }];
        [self refreshDecoratorView];
    }];

}

- (void)setBorderColor:(UIColor *)borderColor
{
    if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeNight && !self.disableNightMode) {
        borderColor = [UIColor tt_themedColorForKey:kColorBackground4];
    }
    if (_borderColor == borderColor) {
        return;
    }
    _borderColor = borderColor;
    self.imageView.layer.borderColor = borderColor.CGColor;
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    if (_borderWidth == borderWidth) {
        return;
    }
    _borderWidth = borderWidth;
    self.imageView.layer.borderWidth = borderWidth;
}

@end
