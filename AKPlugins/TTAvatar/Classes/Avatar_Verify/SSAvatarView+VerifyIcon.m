//
//  SSAvatarView+VerifyIcon.m
//  Article
//
//  Created by lizhuoli on 17/1/22.
//
//

#import "SSAvatarView+VerifyIcon.h"
#import <TTVerifyKit/TTVerifyIconMacro.h>

// TTBaseLib
#import "UIViewAdditions.h"

@implementation SSAvatarView (VerifyIcon)

- (TTVerifyIconImageView *)verifyView
{
    TTVerifyIconImageView *verifyView = TT_GET_PROPERTY(verifyView);
    if (!verifyView) {
        verifyView = [[TTVerifyIconImageView alloc] init];
        verifyView.hidden = YES;
        [self setVerifyView:verifyView];
        [self addSubview:verifyView];
    }
    
    return verifyView;
}

- (void)setVerifyView:(TTVerifyIconImageView *)verifyView
{
    TT_SET_STRONG(verifyView);
}

- (TTAvatarDecoratorView *)decoratorView
{
    TTAvatarDecoratorView *decoratorView = TT_GET_PROPERTY(decoratorView);
    if (!decoratorView) {
        decoratorView = [[TTAvatarDecoratorView alloc] init];
        decoratorView.hidden = YES;
        [self setDecoratorView:decoratorView];
        [self addSubview:decoratorView];
    }
    return decoratorView;
}

- (void)setDecoratorView:(TTAvatarDecoratorView *)decoratorView {
    TT_SET_STRONG(decoratorView);
}

- (void)hideVerifyView
{
    self.verifyView.hidden = YES;
}

- (void)hideDecoratorView {
    [self.decoratorView hideAvatarDecorator];
}

- (void)setupVerifyViewForLength:(CGFloat)avatarLength
             adaptationSizeBlock:(CGSize (^)(CGSize standardSize))sizeBlock{
    [self setupVerifyViewForLength:avatarLength adaptationSizeBlock:sizeBlock adaptationOffsetBlock:nil];
}

- (void)setupVerifyViewForLength:(CGFloat)avatarLength
             adaptationSizeBlock:(CGSize (^)(CGSize standardSize))sizeBlock
           adaptationOffsetBlock:(UIOffset (^)(UIOffset standardOffset))offsetBlock{
    CGSize verifyIconSize = CGSizeZero;
    UIOffset verifyIconOffset = UIOffsetZero;
    TTVerifyAvatarIconSize type = [TTVerifyIconHelper ttVerifyAvatarIconSizeForLength:avatarLength];
    switch (type) {
        case TTVerifyAvatarIconSizeSmall:
            verifyIconSize = kTTVerifyAvatarVerifyIconSizeSmall;
            verifyIconOffset = UIOffsetMake(kTTVerifyAvatarVerifyIconBorderWidth, kTTVerifyAvatarVerifyIconBorderWidth);
            break;
        case TTVerifyAvatarIconSizeBig:
            verifyIconSize = kTTVerifyAvatarVerifyIconSizeBig;
            break;
        default:
            break;
    }
    
    if (sizeBlock){
        verifyIconSize = sizeBlock(verifyIconSize);
    }
    // UE说是外描边。。。
    verifyIconSize = CGSizeMake(verifyIconSize.width + 2 * kTTVerifyAvatarVerifyIconBorderWidth, verifyIconSize.height + 2 * kTTVerifyAvatarVerifyIconBorderWidth);
    
    if (offsetBlock){
        verifyIconOffset = offsetBlock(verifyIconOffset);
    }
    
    self.verifyView.frame = CGRectMake(self.width - verifyIconSize.width + verifyIconOffset.horizontal, self.height - verifyIconSize.height + verifyIconOffset.vertical, verifyIconSize.width, verifyIconSize.height);
    self.verifyView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
}

- (void)showVerifyViewWithVerifyInfo:(NSString *)verifyInfo{
    if (isEmptyString(verifyInfo)) {
        self.verifyView.hidden = YES;
        return;
    }
    self.verifyView.hidden = NO;
    [self.verifyView updateWithVerifyInfo:verifyInfo];
}

- (void)showOrHideVerifyViewWithVerifyInfo:(NSString *)verifyInfo decoratorInfo:(NSString *)dInfo {
    [self showOrHideVerifyViewWithVerifyInfo:verifyInfo decoratorInfo:dInfo sureQueryWithID:NO userID:nil];
}

- (void)showOrHideVerifyViewWithVerifyInfo:(NSString *)verifyInfo decoratorInfo:(NSString *)dInfo sureQueryWithID:(BOOL)query userID:(NSString *)userID {
    [self showOrHideVerifyViewWithVerifyInfo:verifyInfo decoratorInfo:dInfo sureQueryWithID:query userID:userID disableNightCover:NO];
}

- (void)showOrHideVerifyViewWithVerifyInfo:(NSString *)verifyInfo decoratorInfo:(NSString *)dInfo sureQueryWithID:(BOOL)query userID:(NSString *)userID disableNightCover:(BOOL)disableNightCover {
    if (![TTVerifyIconHelper isVerifiedOfVerifyInfo:verifyInfo]) {
        [self hideVerifyView];
    } else {
        self.verifyView.hidden = NO;
        [self.verifyView updateWithVerifyInfo:verifyInfo];
    }
    
    self.decoratorView.decoratorInfoString = dInfo;
    self.decoratorView.userID = query ? userID : nil;
    self.decoratorView.disableNightCover = disableNightCover;
    [self.decoratorView refreshDecoratorFrame:self.frame];
}

- (void)refreshDecoratorView {
    [self.decoratorView refreshDecoratorFrame:self.frame];
}

@end
