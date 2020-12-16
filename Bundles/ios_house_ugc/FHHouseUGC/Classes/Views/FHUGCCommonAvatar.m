//
//  FHUGCCommonAvatar.m
//  FHHouseUGC
//
//  Created by liuyu on 2020/12/10.
//

#import "FHUGCCommonAvatar.h"
#import <BDWebImage/BDWebImage.h>
#import "UIViewAdditions.h"
#import "FHEnvContext.h"
#import "UIColor+Theme.h"
@interface FHUGCCommonAvatar ()
@property (strong , nonatomic) UIImageView *tagView;
@property (nonatomic, copy) NSString *placeHoldName;
@end
@implementation FHUGCCommonAvatar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
        _placeHoldName = @"detail_default_avatar";
    }
    return self;
}

- (void)layoutSubviews {
    self.avatar.top = 0;
    self.avatar.left = 0;
    self.avatar.width = self.width;
    self.avatar.height = self.height;
    self.avatar.layer.cornerRadius = self.width/2;
    self.avatar.layer.masksToBounds = YES;
    self.tagView.top = self.width*0.6;
    self.tagView.left = self.width*0.6;
    self.tagView.width = self.width*0.4;
    self.tagView.height = self.width*0.4;
}

- (void)initViews {
    _avatar = [[UIImageView alloc]init];
    _avatar.layer.borderWidth = 1;
    _avatar.layer.borderColor = [UIColor themeGray6].CGColor;
    [self addSubview:_avatar];
    _tagView = [[UIImageView alloc]init];
    _tagView.contentMode = UIViewContentModeScaleAspectFill;
    _tagView.image = [UIImage imageNamed:@"ugc_v_tag"];
    _tagView.hidden = YES;
    [self addSubview:_tagView];
}

- (void)setAvatarUrl:(NSString *)avatarStr {
    [self.avatar bd_setImageWithURL:[NSURL URLWithString:avatarStr] placeholder:[UIImage imageNamed:self.placeHoldName]];
}

- (void)setPlaceholderImage:(NSString *)imageName {
    self.avatar.image =  [UIImage imageNamed:imageName];
}

- (void)setShowTag:(BOOL)showTag {
    _showTag = showTag;
    self.tagView.hidden = !_showTag;
}

- (void)setUserId:(NSString *)userId {
    NSArray *vwhiteList =  [FHEnvContext getUGCUserVWhiteList];
    if ([vwhiteList containsObject:userId]) {
        self.tagView.hidden = NO;
    }else {
        self.tagView.hidden = YES;
    }
}
@end
