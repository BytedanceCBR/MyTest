//
//  TTCommentDetailToolbarView.m
//  Article
//
//  Created by Jiyee Sheng on 21/01/2018.
//
//

#import "TTCommentDetailToolbarView.h"
#import <TTUIWidget/TTAlphaThemedButton.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTBaseLib/TTDeviceUIUtils.h>
#import <TTBaseLib/UIViewAdditions.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTPlatformBaseLib/TTTrackerWrapper.h>


@interface TTCommentDetailToolbarView ()

@property (nonatomic, strong) SSThemedView *separatorView;

@end

@implementation TTCommentDetailToolbarView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        BOOL _isIPad = [TTDeviceHelper isPadDevice];
        TTAlphaThemedButton *writeButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _writeButton = writeButton;
        [writeButton setTitle:@"写评论..." forState:UIControlStateNormal];
        writeButton.height = [TTDeviceHelper isPadDevice] ? 36 : [TTDeviceUIUtils tt_newPadding:32];
        writeButton.titleLabel.font = [UIFont systemFontOfSize:(_isIPad ? 18 : 13)];
        writeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        writeButton.imageEdgeInsets = UIEdgeInsetsMake(0, 8.f, 0, 0);
        writeButton.titleEdgeInsets = UIEdgeInsetsMake(0, _isIPad ? 25 : 8, 0, 0);
        writeButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        writeButton.borderColorThemeKey = kColorLine1;
        writeButton.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        writeButton.borderColors = nil;
        writeButton.titleColorThemeKey = kColorText1;
        writeButton.layer.cornerRadius = writeButton.height / 2.f;
        writeButton.layer.masksToBounds = YES;
        writeButton.backgroundColorThemeKey = kColorBackground3;
        writeButton.tintColor = [UIColor tt_themedColorForKey:kColorText1];
        [writeButton setImageName:@"write_new"];
        [writeButton setTitle:@"回复" forState:UIControlStateNormal];
        [self addSubview:writeButton];

        UIEdgeInsets toolBarButtonHitTestInsets = UIEdgeInsetsMake(-8.f, -12.f, -15.f, -12.f);

        TTAlphaThemedButton *emojiButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:emojiButton];
        _emojiButton = emojiButton;
        _emojiButton.imageName = @"input_emoji";
        _emojiButton.hitTestEdgeInsets = toolBarButtonHitTestInsets;

        TTAlphaThemedButton *shareButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:shareButton];
        _shareButton = shareButton;
        _shareButton.imageName = @"tab_share";
        _shareButton.hitTestEdgeInsets = toolBarButtonHitTestInsets;
        _shareButton.hidden = YES;
        [_shareButton addTarget:self action:@selector(shareButtonOnClicked:) forControlEvents:UIControlEventTouchUpInside];

        TTAlphaThemedButton *digButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _diggButton = digButton;
        _diggButton.imageName = @"digup_tabbar";
        _diggButton.selectedImageName = @"digup_tabbar_press";
        _diggButton.tintColor = [UIColor tt_themedColorForKey:kColorText1];
        _diggButton.hitTestEdgeInsets = toolBarButtonHitTestInsets;
        _diggButton.selectedTintColorThemeKey = @"ff0031";
        [self addSubview:digButton];

        _separatorView = [[SSThemedView alloc] init];
        _separatorView.backgroundColorThemeKey = kColorLine7;
        _separatorView.frame = CGRectMake(0, 0, self.width, [TTDeviceHelper ssOnePixel]);
        _separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_separatorView];

        self.backgroundColorThemeKey = kColorBackground4;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWriteTitle:) name:@"TTCOMMENT_UPDATE_WRITETITLE" object:nil];
    }

    return self;
}

- (void)updateWriteTitle:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    if (![userInfo tt_boolValueForKey:@"hasComments"]) {
        [self.writeButton setTitle:@"抢沙发..." forState:UIControlStateNormal];
    } else {
        [self.writeButton setTitle:@"写评论..." forState:UIControlStateNormal];
    }
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
    CGRect writeFrame = CGRectZero, emojiFrame = CGRectZero, shareFrame = CGRectZero, digFrame = CGRectZero;
    CGFloat width = self.width;
    CGFloat margin = [TTDeviceHelper is736Screen] ? 10 : ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]?5:0);
    shareFrame = CGRectMake(width - 43 - rightInset, iconTopMargin, 24, 24);
    digFrame = CGRectMake(width - 46 - margin, iconTopMargin, 24, 24);
    writeFrame = CGRectMake(15 + leftInset, writeTopMargin, CGRectGetMinX(digFrame) - 30 - hInset, writeButtonHeight);
    emojiFrame = CGRectMake(CGRectGetMaxX(writeFrame) - 22 - 6 , CGRectGetMinY(writeFrame) + (writeButtonHeight - 22) / 2, 22, 22);

    _writeButton.frame = writeFrame;
    _emojiButton.frame = emojiFrame;
    _diggButton.frame = digFrame;

    BOOL _isIPad = [TTDeviceHelper isPadDevice];
    _writeButton.titleEdgeInsets = UIEdgeInsetsMake(0, _isIPad ? 25 : 8, 0, _emojiButton.width + 4);

}

- (void)safeAreaInsetsDidChange {
    [super safeAreaInsetsDidChange];
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeInset = self.superview.safeAreaInsets;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        CGRect frameInWindow = [self convertRect:self.bounds toView:nil];
        if (ceil(self.height) - ceil(TTCommentDetailToolbarViewHeight()) == 0 &&
            screenHeight == ceil(CGRectGetMaxY(frameInWindow))){
            CGFloat toolBarHeight = (TTCommentDetailToolbarViewHeight() + safeInset.bottom);
            frameInWindow = CGRectMake(frameInWindow.origin.x, screenHeight - toolBarHeight, self.width,toolBarHeight);
            self.frame = [self.superview convertRect:frameInWindow fromView:nil];
        }
    }
}

- (void)setFrame:(CGRect)frame {
    if (CGRectGetHeight(frame) == 0){
        frame.size.height = TTCommentDetailToolbarViewHeight();
    }
    [super setFrame:frame];
}

- (void)setBanEmojiInput:(BOOL)banEmojiInput {
    if ([TTDeviceHelper isPadDevice]) { // iPad 暂时不支持
        banEmojiInput = YES;
    }

    _banEmojiInput = banEmojiInput;

    self.emojiButton.hidden = banEmojiInput;
    self.emojiButton.enabled = !banEmojiInput;
}

- (void)shareButtonOnClicked:(id)sender {
    [TTTrackerWrapper eventV3:@"share_icon_click" params:@{@"icon_type": @"1"}]; // 评论详情不支持 settings 控制
}

CGFloat TTCommentDetailToolbarViewHeight(void) {
    return ([TTDeviceHelper isPadDevice] ? 50 : 44) + [TTDeviceHelper ssOnePixel];
}

@end
