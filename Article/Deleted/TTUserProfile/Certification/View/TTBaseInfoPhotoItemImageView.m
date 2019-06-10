//
//  TTBaseInfoPhotoItemImageView.m
//  Article
//
//  Created by wangdi on 2017/5/21.
//
//

#import "TTBaseInfoPhotoItemImageView.h"
#import "TTThemeManager.h"

@interface TTBaseInfoPhotoItemImageView ()

@property (nonatomic, strong) SSThemedButton *closeBtn;
@property (nonatomic, strong) SSThemedView *coverView;
@property (nonatomic, strong) SSThemedImageView *iconView;

@end
@implementation TTBaseInfoPhotoItemImageView
- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self setupSubview];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themedChange) name:TTThemeManagerThemeModeChangedNotification object:nil];
        [self themedChange];
    }
    return self;
}

- (void)setupSubview
{
    SSThemedImageView *imageView = [[SSThemedImageView alloc] init];
    imageView.layer.masksToBounds = YES;
    imageView.layer.cornerRadius = 3;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:imageView];
    self.imageView = imageView;
    
    SSThemedView *coverView = [[SSThemedView alloc] init];
    coverView.layer.masksToBounds = YES;
    coverView.layer.cornerRadius = 3;
    [self addSubview:coverView];
    self.coverView = coverView;
    
    SSThemedImageView *iconView = [[SSThemedImageView alloc] init];
    iconView.imageName = @"certification_authentication_watermark";
    [self addSubview:iconView];
    self.iconView = iconView;
    
    SSThemedButton *closeBtn = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    closeBtn.imageName = @"revoke_icon";
    closeBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-6, -6, -6, -6);
    [closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeBtn];
    self.closeBtn = closeBtn;
}

- (void)closeBtnClick
{
    self.imageView.image = nil;
    self.hidden = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:kDeletePhotoNotification object:nil];
    
}

- (void)setImage:(UIImage *)image
{
    self.hidden = image ? NO : YES;
    self.imageView.image = image;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if(CGRectContainsPoint(self.closeBtn.frame, point)) {
        return self.closeBtn;
    }
    return [super hitTest:point withEvent:event];
}

- (void)themedChange
{
    if([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay) {
        self.coverView.backgroundColor  = [[UIColor blackColor] colorWithAlphaComponent:0.15];
    } else {
        self.coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];

    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
    self.coverView.frame = self.bounds;
    self.iconView.width = [TTDeviceUIUtils tt_newPadding:106];
    self.iconView.height = [TTDeviceUIUtils tt_newPadding:52];
    self.iconView.centerX = self.width * 0.5;
    self.iconView.centerY = self.height * 0.5;
    self.closeBtn.width = [TTDeviceUIUtils tt_newPadding:19];
    self.closeBtn.height = [TTDeviceUIUtils tt_newPadding:19];
    self.closeBtn.centerX = self.width - [TTDeviceUIUtils tt_newPadding:2];
    self.closeBtn.top = -self.closeBtn.height * 0.5;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
