//
//  TTNotePermissonGuideView.m
//  Article
//
//  Created by liuzuopeng on 02/07/2017.
//
//

#import "TTNotePermissonGuideView.h"
#import <TTUIResponderHelper.h>
#import <BDWebImage/SDWebImageAdapter.h>


@implementation TTNotePermissonGuideView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self setupCustomViews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self setupCustomViews];
    }
    return self;
}

- (void)setupCustomViews
{
    [self setupDismissButtons];
    [self setupTitles];
    [self setupImages];
    [self setupTappedTextButtons];
    
    self.size = CGSizeMake([self.class viewWidth], [self.class viewHeight]);
}

- (void)setupDismissButtons
{
    
}

- (void)setupTitles
{
    [self addSubview:self.titleLabel];
    [self addSubview:self.subTitleLabel];
}

- (void)setupImages
{
    [self addSubview:self.permissionGuideImageView];
}

- (void)setupTappedTextButtons
{
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = [self.class viewWidth];
    CGFloat insetTop = [TTDeviceUIUtils tt_newPadding:106.f];
    CGFloat titleToSubTitle = [TTDeviceUIUtils tt_newPadding:22.f];
    CGFloat imageToTitle = [TTDeviceUIUtils tt_newPadding:52.f];
    
    CGFloat offsetY = insetTop;
    
    self.titleLabel.top = offsetY;
    self.titleLabel.centerX = width / 2;
    
    offsetY = self.subTitleLabel.bottom;
    
    if ([self.subTitleLabel.text length] > 0) {
        offsetY += titleToSubTitle;
        
        self.subTitleLabel.top = offsetY;
        self.subTitleLabel.centerX = width / 2;
        
        offsetY = self.subTitleLabel.bottom;
    }
    
    offsetY += imageToTitle;
    
    CGFloat imageWidth = [TTDeviceUIUtils tt_newPadding:422.f];
    CGFloat imageHeight = [TTDeviceUIUtils tt_newPadding:394.f];
    self.permissionGuideImageView.frame = CGRectMake((width - imageWidth) / 2, offsetY, imageWidth, imageHeight);
}

#pragma mark - public methods

- (void)showWithCompletion:(void (^)())completedHandler
{
    [self showWithAnimated:YES completion:completedHandler];
}

- (void)showWithAnimated:(BOOL)animated completion:(void (^)())completedHandler
{
    if (self.superview) [self removeFromSuperview];
    
    UIView *superView = [TTUIResponderHelper mainWindow];
    
    if ([superView isKindOfClass:[UIWindow class]]) {
        UIViewController *vc = ((UIWindow *)superView).rootViewController;
        while (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController *)vc).topViewController;
        }
        superView = vc.view;
    }
    [superView addSubview:self];
    [superView bringSubviewToFront:self];
    
    if (animated) {
        self.alpha = 0.3;
        self.hidden = NO;
        __weak typeof(self) wself = self;
        [UIView animateWithDuration:0.13 animations:^{
            wself.alpha = 1.0f;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.07 animations:^{
                
            } completion:^(BOOL finished) {
                if (completedHandler) completedHandler();
            }];
        }];
    } else {
        if (completedHandler) completedHandler();
    }
}

- (void)hideWithCompletion:(void (^)())completedHandler
{
    [self hideWithAnimated:YES completion:completedHandler];
}

- (void)hideWithAnimated:(BOOL)animated completion:(void (^)())completedHandler
{
    if (animated) {
        __weak typeof(self) wself = self;
        [UIView animateWithDuration:0.1 animations:^{
            __strong typeof(wself) sself = wself;
            sself.alpha = 0.f;
        } completion:^(BOOL finished) {
            __strong typeof(wself) sself = wself;
            [sself removeFromSuperview];
            if (completedHandler) completedHandler();
        }];
    } else {
        if (completedHandler) completedHandler();
    }
}

+ (void)openAppSystemSettings
{
    if ((&UIApplicationOpenSettingsURLString) != NULL) {
        NSURL *appSettingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([TTDeviceHelper OSVersionNumber] >= 10.0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
            [[UIApplication sharedApplication] openURL:appSettingsURL
#pragma clang diagnostic pop
                                               options:@{}
                                     completionHandler:nil];
        } else if ([TTDeviceHelper OSVersionNumber] >= 8.0) {
            [[UIApplication sharedApplication] openURL:appSettingsURL];
        }
    } else {
        NSLog(@"%@, not supported", NSStringFromSelector(_cmd));
    }
}

+ (CGFloat)viewWidth
{
    return [TTDeviceUIUtils tt_newPadding:560.f];
}

+ (CGFloat)viewHeight
{
    return [TTDeviceUIUtils tt_newPadding:784.f];
}

#pragma mark - setter/getter

- (void)setPermissionGuideImageWithURL:(NSURL *)urlString
{
    if (!urlString) return;
    
    WeakSelf;
    [self.permissionGuideImageView sda_setImageWithURL:urlString completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        wself.permissionGuideImageView.image = image;
    }];
}

- (SSThemedLabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [SSThemedLabel new];
        _titleLabel.numberOfLines = 1;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:36.f]];
        _titleLabel.textColorThemeKey = kColorText1;
        _titleLabel.text = @"开启推送通知";
    }
    return _titleLabel;
}

- (SSThemedLabel *)subTitleLabel
{
    if (!_subTitleLabel) {
        _subTitleLabel = [SSThemedLabel new];
        _subTitleLabel.numberOfLines = 1;
        _subTitleLabel.textAlignment = NSTextAlignmentCenter;
        _subTitleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:30.f]];
        _subTitleLabel.textColorThemeKey = kColorText3;
        _subTitleLabel.text = @"开启推送通知";
    }
    return _titleLabel;
}

- (SSThemedImageView *)permissionGuideImageView
{
    if (!_permissionGuideImageView) {
        _permissionGuideImageView = [[SSThemedImageView alloc] init];
    }
    return _permissionGuideImageView;
}

@end

