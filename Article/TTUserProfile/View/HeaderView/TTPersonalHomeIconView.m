//
//  TTPersonalHomeIconView.m
//  Article
//
//  Created by wangdi on 2017/5/3.
//
//

#import "TTPersonalHomeIconView.h"
#import "UIImageView+WebCache.h"
#import "TTThemeManager.h"
#import <TTAvatarDecoratorView.h>
#import <TTInstallJSONHelper.h>
#import <BDWebImage/SDWebImageAdapter.h>

@interface TTPersonalHomeIconView ()
@property (nonatomic, strong) TTAvatarDecoratorView *decoratorView;
@end

@implementation TTPersonalHomeIconView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themedChange) name:TTThemeManagerThemeModeChangedNotification object:nil];
        [self themedChange];
        [self addSubview:self.avatarImageView];
        [self addSubview:self.coverView];
        [self addSubview:self.avatarVerifyView];
        [self addSubview:self.decoratorView];
    }
    return self;
}

- (TTVerifyIconImageView *)avatarVerifyView
{
    if (!_avatarVerifyView) {
        //新版个人主页，头像
        CGSize verifyIconSize = CGSizeMake(2 * kTTVerifyAvatarVerifyIconBorderWidth + [TTDeviceUIUtils tt_newPadding:18.f], 2 * kTTVerifyAvatarVerifyIconBorderWidth + [TTDeviceUIUtils tt_newPadding:18.f]);
        _avatarVerifyView = [[TTVerifyIconImageView alloc] initWithFrame:CGRectMake(self.width - verifyIconSize.width, self.height - verifyIconSize.height, verifyIconSize.width, verifyIconSize.height)];
        _avatarVerifyView.hidden = YES;
        [self addSubview:self.avatarVerifyView];
    }
    return _avatarVerifyView;
}

- (SSThemedImageView *)avatarImageView
{
    if (!_avatarImageView) {
        _avatarImageView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        _avatarImageView.enableNightCover = YES;
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.layer.cornerRadius = self.frame.size.width/2;
        _avatarImageView.layer.masksToBounds = YES;
        _avatarImageView.layer.borderWidth = 1;
        _avatarImageView.layer.borderColor = [UIColor tt_themedColorForKey:kColorBackground4].CGColor;
    }
    return _avatarImageView;
}

- (TTAvatarDecoratorView *)decoratorView {
    if (!_decoratorView) {
        _decoratorView = [[TTAvatarDecoratorView alloc] init];
        _decoratorView = [[TTAvatarDecoratorView alloc] initWithFrame:CGRectMake(kDecoratorOriginFactor * _avatarImageView.width, kDecoratorOriginFactor * _avatarImageView.height, kDecoratorSizeFactor * _avatarImageView.width, kDecoratorSizeFactor * _avatarImageView.height)];
        _decoratorView.hidden = YES;
    }
    return _decoratorView;
}

- (SSThemedView *)coverView
{
    if(!_coverView) {
        _coverView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        _coverView.layer.cornerRadius = self.frame.size.width/2;
        _coverView.layer.masksToBounds = YES;
        _coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.05];
    }
    return _coverView;
}

- (void)setImageWithURL:(NSString *)url
{
    if(isEmptyString(url)) return;
   [self.avatarImageView sda_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
}

- (void)setDecoratorWithURL:(NSString *)url userID:(NSString *)uid {
    self.decoratorView.decoratorInfoString = url;
    self.decoratorView.userID = uid;
    [self.decoratorView showAvatarDecorator];
}

- (void)setPlaceHolder:(NSString *)placeHolder
{
    _placeHolder = placeHolder;
    self.avatarImageView.image = [UIImage imageNamed:placeHolder];
}

- (void)showPersonalVerifyViewWithVerifyInfo:(NSString *)verifyInfo size:(CGSize)size
{
    self.avatarVerifyView.hidden = NO;
    [self.avatarVerifyView updateWithVerifyInfo:verifyInfo extraConfig:nil];
}

- (void)hideVerifyView
{
    self.avatarVerifyView.hidden = YES;
}

- (void)themedChange
{
    if([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay) {
        self.avatarImageView.layer.borderColor = [UIColor tt_themedColorForKey:kColorBackground4].CGColor;
    } else {
        self.avatarImageView.layer.borderColor = [UIColor colorWithHexString:@"#252525"].CGColor;
    }
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
