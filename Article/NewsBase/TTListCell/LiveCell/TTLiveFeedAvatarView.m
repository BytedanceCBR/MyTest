//
//  TTLiveFeedAvatarView.m
//  Article
//
//  Created by 杨心雨 on 16/8/19.
//
//

#import "TTLiveFeedAvatarView.h"
#import <BDWebImage/SDWebImageAdapter.h>
#import "TTArticleCellHelper.h"
#import "UIImage+TTThemeExtension.h"
#import "TTDeviceHelper.h"

@interface TTLiveFeedAvatarView ()

@property (nonatomic, strong) SSThemedImageView * _Nonnull avatar;
@property (nonatomic, strong) SSThemedLabel * _Nonnull name;
@property (nonatomic, strong) NSString * _Nullable url;
@property (nonatomic, strong) UIImageView * _Nullable bgBlueImgView;

@end

@implementation TTLiveFeedAvatarView

- (SSThemedImageView *)avatar {
    if (_avatar == nil) {
        _avatar = [[SSThemedImageView alloc] initWithFrame:CGRectMake(0, 0, ([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]) ? 36 : 40, ([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]) ? 36 : 40)];
        _avatar.enableNightCover = YES;
        [self addSubview:_avatar];
    }
    return _avatar;
}
    
/** 名字 */
- (SSThemedLabel *)name {
    if (_name == nil) {
        _name = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 0, 0, ([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]) ? 14 : 17)];
        _name.numberOfLines = 1;
        [self addSubview:_name];
    }
    return _name;
}

- (UIImageView *)bgBlueImgView {
    if (_bgBlueImgView == nil) {
        _bgBlueImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"teamlight_live"]];
        [self insertSubview:_bgBlueImgView belowSubview:self.avatar];
    }
    return _bgBlueImgView;
}

- (instancetype)init {
    self = [super initWithFrame:CGRectMake(0, 0, (([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]) ? 36 : 40), (([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]) ? 36 : 40))];
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    self.avatar.layer.borderColor = [[UIColor tt_themedColorForKey:kColorLine11] CGColor];
}

- (void)updateAvatarViewWithStar:(LiveStar *)star {
    _bgBlueImgView.hidden = YES;
    NSString *icon = star.icon;
    NSString *name = star.name;
    NSString *url = star.url;
    NSString *title = star.title;
    if (icon && name) {
        [self.avatar sda_setImageWithURL:[NSURL URLWithString:icon] placeholderImage:[UIImage themedImageNamed:@"default_sdk_login"]];
        self.avatar.layer.borderColor = [[UIColor tt_themedColorForKey:kColorLine11] CGColor];
        self.avatar.layer.borderWidth = 1;
        self.avatar.layer.cornerRadius = self.avatar.height / 2;
        self.avatar.layer.masksToBounds = YES;
        self.avatar.layer.shadowColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.65] CGColor];
        self.avatar.layer.shadowOffset = CGSizeMake(0, 0);
        self.avatar.layer.shadowOpacity = 0.65;
        self.avatar.layer.shadowRadius = 1.5;
        self.name.font = [UIFont tt_fontOfSize:([TTDeviceHelper isScreenWidthLarge320] ? 16 : 14)];
        self.name.textColorThemeKey = kColorText10;
        self.name.text = name;
        if (!isEmptyString(title)) {
            [self layoutStarAvatar];
        }
        else{
            [self layoutStarAvatarWithoutTitle];
        }
    }
    if (url) {
        self.url = url;
    }
}

- (void)updateAvatarViewWithTeam:(LiveTeam *)team {
    _bgBlueImgView.hidden = NO;
    NSString *icon = team.icon;
    NSString *name = team.name;
    NSString *url = team.url;
    if (icon && name) {
        [self.avatar sda_setImageWithURL:[NSURL URLWithString:icon] placeholderImage:[UIImage themedImageNamed:@"chatroom_background_image"]];
        if ([name length] > 7) {
            name = [name substringWithRange:NSMakeRange(0, 7)];
        }
        self.name.font = [UIFont tt_fontOfSize:(([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]) ? 14 : 17)];
        self.name.textColorThemeKey = kColorText10;
        self.name.text = name;
        [self layoutTeamAvatar];
    }
    if (url) {
        self.url = url;
    }
}

- (void)layoutStarAvatar {
    [self.name sizeToFit];
    self.name.left = self.avatar.right + 10;
    self.name.top = self.avatar.top + ([TTDeviceHelper isScreenWidthLarge320] ? 0.5 : 2.5);
    self.name.height = ([TTDeviceHelper isScreenWidthLarge320] ? 16 : 14);
    self.width = self.avatar.width + 10 + self.name.width;
    self.height = 36;
}

- (void)layoutStarAvatarWithoutTitle {
    [self.name sizeToFit];
    self.name.left = self.avatar.right + 10;
    self.height = [TTDeviceHelper isScreenWidthLarge320]? 16 : 14;
    self.name.centerY = self.avatar.centerY;
    self.width = self.avatar.width + 10 + self.name.width;
    self.height = 36;
}

- (void)layoutTeamAvatar {
    [self.name sizeToFit];
    self.name.centerX = self.width / 2;
    self.name.height = (([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]) ? 14 : 17);
    self.name.top = self.avatar.bottom + (([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]) ? 20 : 24);
    self.bgBlueImgView.center = self.avatar.center;
    self.height = self.name.bottom;
}

@end
