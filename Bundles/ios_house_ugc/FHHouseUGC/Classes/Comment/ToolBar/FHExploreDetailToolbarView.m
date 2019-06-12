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

@interface FHExploreDetailToolbarView ()

@property (nonatomic, strong) SSThemedLabel *commentLabel;
@property (nonatomic, strong) SSThemedLabel *collectLabel;
@property (nonatomic, strong) SSThemedLabel *shareLabel;
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
        writeButton.titleEdgeInsets = UIEdgeInsetsMake(0, _isIPad ? 25 : 16, 0, 0);
        writeButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:writeButton];
        _writeButton = writeButton;

        UIEdgeInsets toolBarButtonHitTestInsets = UIEdgeInsetsMake(-8.f, -12.f, -15.f, -12.f);

        self.digCountLabel = [[SSThemedLabel alloc] init];
        self.digCountLabel.backgroundColorThemeKey = kFHColorCoral;
        self.digCountLabel.textColorThemeKey = kColorText8;
        self.digCountLabel.font = [UIFont systemFontOfSize:8];
        self.digCountLabel.layer.cornerRadius = 5;
        self.digCountLabel.layer.masksToBounds = YES;
        self.digCountLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.digCountLabel];
        
        TTAlphaThemedButton *digButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _digButton = digButton;
        _digButton.hitTestEdgeInsets = toolBarButtonHitTestInsets;
        [self addSubview:digButton];
        
        _separatorView = [[SSThemedView alloc] init];
        _separatorView.backgroundColorThemeKey = kColorLine7;
        _separatorView.frame = CGRectMake(0, 0, self.width, [TTDeviceHelper ssOnePixel]);
        _separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_separatorView];

        self.viewStyle = TTDetailViewStyleArticleComment;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWriteTitle:) name:@"TTCOMMENT_UPDATE_WRITETITLE" object:nil];
        self.banEmojiInput = NO;
    }
    return self;
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
    CGFloat leftInset = self.tt_safeAreaInsets.left;
    CGFloat rightInset = self.tt_safeAreaInsets.right;
    CGFloat hInset = leftInset + rightInset;//水平缩进
    CGFloat bottomSafeInset = self.tt_safeAreaInsets.bottom;
    CGFloat writeButtonHeight = [TTDeviceHelper isPadDevice] ? 36 : [TTDeviceUIUtils tt_newPadding:32];
    CGFloat writeTopMargin = ((NSInteger)self.height - writeButtonHeight - bottomSafeInset) / 2;
    CGFloat iconTopMargin = ((NSInteger)self.height - 24 - bottomSafeInset) / 2;
    CGRect writeFrame = CGRectZero, emojiFrame = CGRectZero, commentFrame = CGRectZero, shareFrame = CGRectZero, collectFrame = CGRectZero, digFrame = CGRectZero;
    CGFloat width = self.width;

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
    
//    _emojiButton.imageName = @"input_emoji";
//    _commentButton.imageName = @"tab_comment";
//    _collectButton.imageName = @"tab_collect";
//    _collectButton.selectedImageName = @"tab_collect_press";
    _digButton.imageName = @"digup_tabbar";
    _digButton.selectedImageName = @"digup_tabbar_press";
    _digButton.tintColor = [UIColor tt_themedColorForKey:kColorText1];
//    _shareButton.imageName = [self _shareIconName];
    _writeButton.borderColors = nil;
    _writeButton.borderColorThemeKey = kFHColorSilver2;
    _writeButton.layer.borderWidth = 0;
    _writeButton.titleLabel.textColor = [UIColor themeGray3];
    _writeButton.layer.cornerRadius = 4;
    _writeButton.backgroundColor = [UIColor themeGray7];
    _writeButton.layer.masksToBounds = YES;
    
    //        [_writeButton setImageName:@"write_new"];
    //        _writeButton.tintColor = [UIColor themeGray3];//[UIColor tt_themedColorForKey:kColorText1];
}

- (void)setCommentBadgeValue:(NSString *)commentBadgeValue {
    int64_t value = [commentBadgeValue longLongValue];
    commentBadgeValue = [TTBusinessManager formatCommentCount:value];
    if ([commentBadgeValue integerValue] == 0) {
        commentBadgeValue = nil;
    }
    _commentBadgeValue = commentBadgeValue;
    self.digCountLabel.text = commentBadgeValue;
    if (isEmptyString(commentBadgeValue)) {
        self.digCountLabel.hidden = YES;
    } else {
        self.digCountLabel.hidden = NO;
        [self.digCountLabel sizeToFit];
        self.digCountLabel.width += 8;
        self.digCountLabel.width = MAX(self.digCountLabel.width, 15);
        self.digCountLabel.height = 10;
        self.digCountLabel.origin = CGPointMake(11, 0);
    }
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
    _commentLabel.hidden = !toolbarLabelEnabled;
    _collectLabel.hidden = !toolbarLabelEnabled;
    _shareLabel.hidden = !toolbarLabelEnabled;
}

- (NSString *)_shareIconName {
    return @"tab_share";
}

- (NSString *)_photoShareIconName {
    return @"icon_details_share";
}

@end

CGFloat FHExploreDetailGetToolbarHeight(void) {
    return ([TTDeviceHelper isPadDevice] ? 50 : 44) + [TTDeviceHelper ssOnePixel];
}

