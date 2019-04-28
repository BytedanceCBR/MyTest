//
//  TTVideoFloatAvatar.m
//  Article
//
//  Created by panxiang on 16/7/11.
//
//

#import "TTVideoFloatAvatar.h"

@interface TTVideoFloatAvatar()
{
    SSThemedView *_mask;
    UIButton *_button;
}

@property (nonatomic,nullable, strong) ExploreAvatarView *icon;

@end

@implementation TTVideoFloatAvatar

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor tt_defaultColorForKey:kColorLine9];
        
        _icon = [[ExploreAvatarView alloc] init];
        _icon.highlightedMaskView = nil;
        _icon.enableRoundedCorner = YES;

        _icon.userInteractionEnabled = YES;
        [self addSubview:_icon];
        
        _mask = [[SSThemedView alloc] init];
        _mask.backgroundColor = [UIColor tt_defaultColorForKey:kColorBackground16];
        [_icon addSubview:_mask];
        
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.backgroundColor = [UIColor clearColor];
        [self addSubview:_button];
        
    }
    return self;
}

- (void)setImage:(UIImage *)image
{
    _icon.imageView.image = image;
}

- (void)layoutSubviews
{
    _icon.frame = self.bounds;
    [_icon setupVerifyViewForLength:36 adaptationSizeBlock:^CGSize(CGSize standardSize) {
        return [TTVerifyIconHelper tt_newSize:standardSize];
    }];
    _mask.frame = self.bounds;
    _mask.layer.cornerRadius = self.width / 2;
    [_icon insertSubview:_mask belowSubview:_icon.verifyView];
    _button.frame = self.bounds;
    _button.layer.cornerRadius = self.width / 2.f;
    self.layer.cornerRadius = self.width / 2;
    [super layoutSubviews];
}

- (void)addTarget:(nullable id)target action:(_Nonnull SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [_button addTarget:target action:action forControlEvents:controlEvents];
}

@end
