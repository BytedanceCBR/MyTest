//
//  ExploreDetailToolbarView.m
//  Article
//
//  Created by SunJiangting on 15/7/27.
//
//

#import "FHExploreDetailToolbarView.h"
#import "UIButton+TTAdditions.h"
#import "TTAlphaThemedButton.h"
#import "ExploreVideoDetailHelper.h"
#import "TTDeviceHelper.h"
#import "TTBusinessManager+StringUtils.h"
#import "TTUGCEmojiTextAttachment.h"
#import "TTArticleDetailDefine.h"
#import "SSCommonLogic.h"
#import <TTBaseLib/UIViewAdditions.h>
#import <TTBaseLib/TTDeviceUIUtils.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTPlatformBaseLib/TTTrackerWrapper.h>
#import <Masonry.h>
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import <UIImage+FIconFont.h>

@interface FHExploreDetailToolbarView ()

@property (nonatomic, assign) BOOL toolbarLabelEnabled;

@end

@implementation FHExploreDetailToolbarView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        BOOL _isIPad = [TTDeviceHelper isPadDevice];
        TTAlphaThemedButton *writeButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        [writeButton setTitle:@"说点什么..." forState:UIControlStateNormal];
        writeButton.height = [TTDeviceHelper isPadDevice] ? 36 : [TTDeviceUIUtils tt_newPadding:32];
        writeButton.titleLabel.font = [UIFont systemFontOfSize:(_isIPad ? 18 : 14)];
        writeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        writeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
        writeButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:writeButton];
        _writeButton = writeButton;
        
        [_writeButton setTitleColor:[UIColor themeGray3] forState:UIControlStateNormal];
        [_writeButton setTitleColor:[UIColor themeGray3] forState:UIControlStateHighlighted];
        _writeButton.layer.cornerRadius = 4;
        _writeButton.backgroundColor = [UIColor themeGray7];
        _writeButton.layer.masksToBounds = YES;

        UIEdgeInsets toolBarButtonHitTestInsets = UIEdgeInsetsMake(-8.f, -12.f, -15.f, -12.f);

        self.digCountLabel = [[SSThemedLabel alloc] init];
        self.digCountLabel.textColor = [UIColor themeGray1];
        self.digCountLabel.font = [UIFont systemFontOfSize:12];
        self.digCountLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.digCountLabel];
        
        TTAlphaThemedButton *digButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _digButton = digButton;
        _digButton.hitTestEdgeInsets = toolBarButtonHitTestInsets;
        [_digButton setImage:ICON_FONT_IMG(24, @"\U0000e69c", [UIColor themeGray1]) forState:UIControlStateNormal];
        [_digButton setImage:ICON_FONT_IMG(24, @"\U0000e6b1", [UIColor themeOrange4]) forState:UIControlStateSelected];
        [self addSubview:digButton];
        
        _separatorView = [[SSThemedView alloc] init];
        _separatorView.backgroundColorThemeKey = kColorLine7;
        _separatorView.frame = CGRectMake(0, 0, self.width, [TTDeviceHelper ssOnePixel]);
        _separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_separatorView];

        self.viewStyle = TTDetailViewStyleArticleComment;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWriteTitle:) name:@"TTCOMMENT_UPDATE_WRITETITLE" object:nil];
        self.banEmojiInput = NO;
        [self setupConstraints];
    }
    return self;
}

- (void)setupConstraints {
    [_writeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(20);
        make.height.mas_equalTo(32);
        make.top.mas_equalTo(8);
        make.right.mas_equalTo(self.digButton.mas_left).offset(-15);
    }];
    [self.digButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.writeButton);
        make.width.height.mas_equalTo(24);
    }];
    [_digCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(13);
        make.left.mas_equalTo(self.digButton.mas_right).offset(3);
    }];
}

- (void)updateWriteTitle:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    if (![userInfo tt_boolValueForKey:@"hasComments"]) {
        [self.writeButton setTitle:@"抢沙发..." forState:UIControlStateNormal];
    }
    else {
        [self.writeButton setTitle:@"说点什么..." forState:UIControlStateNormal];
    }
}

- (void)setToolbarType:(FHExploreDetailToolbarType)toolbarType {
    _toolbarType = toolbarType;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)safeAreaInsetsDidChange
{
    [super safeAreaInsetsDidChange];
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeInset = self.superview.safeAreaInsets;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        CGRect frameInWindow = [self convertRect:self.bounds toView:nil];
        if (ceil(self.height) - ceil(FHExploreDetailGetToolbarHeight()) == 0 &&
            screenHeight == ceil(CGRectGetMaxY(frameInWindow))){
            CGFloat toolBarHeight = (FHExploreDetailGetToolbarHeight() + safeInset.bottom);
            frameInWindow = CGRectMake(frameInWindow.origin.x, screenHeight - toolBarHeight, self.width,toolBarHeight);
            self.frame = [self.superview convertRect:frameInWindow fromView:nil];
        }
    }
}

- (void)setFrame:(CGRect)frame {
    if (CGRectGetHeight(frame) == 0){
        frame.size.height = FHExploreDetailGetToolbarHeight();
    }
    [super setFrame:frame];
    
    self.separatorView.top = 0;
}


- (void)setViewStyle:(TTDetailViewStyle)viewStyle {
    _viewStyle = viewStyle;
    
    self.backgroundColorThemeKey = kColorBackground4;
}

- (void)setDigCountValue:(NSString *)commentBadgeValue {
    int64_t value = [commentBadgeValue longLongValue];
    commentBadgeValue = [TTBusinessManager formatCommentCount:value];
    if ([commentBadgeValue integerValue] == 0) {
        commentBadgeValue = @"赞";
    }
    _digCountValue = commentBadgeValue;
    self.digCountLabel.text = commentBadgeValue;
    [self.digCountLabel sizeToFit];
    [self layoutIfNeeded];
}

- (void)setBanEmojiInput:(BOOL)banEmojiInput {
    if ([TTDeviceHelper isPadDevice]) { // iPad 暂时不支持
        banEmojiInput = YES;
    }

    _banEmojiInput = banEmojiInput;
}

#pragma mark - target-action

- (void)shareButtonOnClicked:(id)sender {
    
}

- (void)themeChanged:(NSNotification *)notification {
 
}

- (void)setToolbarLabelEnabled:(BOOL)toolbarLabelEnabled {
    _toolbarLabelEnabled = toolbarLabelEnabled;
}

- (NSString *)_shareIconName {
    return @"tab_share";
}

- (NSString *)_photoShareIconName {
    return @"icon_details_share";
}

@end

CGFloat FHExploreDetailGetToolbarHeight(void) {
    return ([TTDeviceHelper isPadDevice] ? 50 : 48) + [TTDeviceHelper ssOnePixel];
}

