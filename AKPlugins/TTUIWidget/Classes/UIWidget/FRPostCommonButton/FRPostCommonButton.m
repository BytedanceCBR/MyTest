//
//  FRPostCommonButton.m
//  Article
//
//  Created by zhaopengwei on 15/7/23.
//
//

#import "FRPostCommonButton.h"
#import "UIButton+TTAdditions.h"
#import "TTIndicatorView.h"

#import "TTIndicatorView.h"
#import "TTDeviceHelper.h"
#import <Masonry/Masonry.h>
#import "UIViewAdditions.h"
CGFloat fr_postCommentButtonHeight(void) {
    return 44;
}

@interface FRPostCommonButton ()

@property (strong, nonatomic) TTAlphaThemedButton *shareButton;

@end

@implementation FRPostCommonButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self _commonInit];
    }
    
    return self;
}

- (void)dealloc {
}

- (void)_commonInit
{
    self.backgroundColorThemeKey = kColorBackground4;
    
    [self addSubview:self.topLine];
    [self addSubview:self.button];
    [self addSubview:self.emojiButton];
    [self addSubview:self.diggButton];
    [self addSubview:self.shareButton];
    
    [self.topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.height.equalTo(@1);
        make.left.equalTo(@0);
        make.right.equalTo(@0);
    }];
    
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-15);
        make.centerY.equalTo(@0);
    }];
    
    [self.diggButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_right).with.offset(-85);
        make.centerY.equalTo(self.shareButton);
    }];
    
    [self.button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.right.equalTo(@(-133));
        make.centerY.equalTo(self.shareButton);
        make.height.equalTo(@32);
    }];

    [self.emojiButton addTarget:self action:@selector(emojiAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.emojiButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.button).offset(-6);
        make.centerY.equalTo(self.shareButton);
        make.width.and.height.equalTo(@22);
    }];
}

- (SSThemedButton *)button {
    if (!_button) {
        _button = [[SSThemedButton alloc] initWithFrame:CGRectZero];
        
        _button.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        
        _button.borderColorThemeKey = kColorLine1;
        _button.highlightedBorderColorThemeKey = kColorLine1Highlighted;
        _button.backgroundColorThemeKey = kColorBackground3;
        _button.highlightedBackgroundColorThemeKey = kColorBackground3Highlighted;
        _button.titleColorThemeKey = kColorText1;
        _button.highlightedTitleColorThemeKey = kColorText1Highlighted;
        [_button setTitle:NSLocalizedString(@"回复...", nil) forState:UIControlStateNormal];
//        [_button setImageName:@"write_new"];
        _button.tintColor = [UIColor tt_themedColorForKey:kColorText1];
        
        _button.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _button.layer.cornerRadius = 16.0f;
        _button.layer.masksToBounds = YES;
        
        _button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _button.imageEdgeInsets = UIEdgeInsetsMake(0, 8.f, 0, 0);
        BOOL _isIPad = [TTDeviceHelper isPadDevice];
        _button.titleEdgeInsets = UIEdgeInsetsMake(0, _isIPad ? 25 : 8.f, 0, 0);
    }
    
    return _button;
}

- (SSThemedButton *)shareButton {
    if (!_shareButton) {
        _shareButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _shareButton.frame = CGRectMake(0, 0, 22, 22);
        [_shareButton setHitTestEdgeInsets:UIEdgeInsetsMake(-11, -11, -11, -11)];
        [_shareButton setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [_shareButton setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        _shareButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        _shareButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        _shareButton.imageName = @"tab_share";
        _shareButton.tintColor = [UIColor tt_themedColorForKey:kColorText1];
        
        [_shareButton addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shareButton;
}

- (TTAlphaThemedButton *)emojiButton {
    if (!_emojiButton) {
        _emojiButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _emojiButton.hitTestEdgeInsets = UIEdgeInsetsMake(-8.f, -10.f, -8.f, -10.f);
        _emojiButton.imageName = @"input_emoji";
    }

    return _emojiButton;
}

- (TTDiggButton *)diggButton
{
    if (!_diggButton) {
        _diggButton = [TTDiggButton diggButtonWithStyleType:TTDiggButtonStyleTypeImageOnly];
        [_diggButton setHitTestEdgeInsets:UIEdgeInsetsMake(-12, -12, -12, -12)];
        [_diggButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 3, 0, -3)];
        [_diggButton setImageEdgeInsets:UIEdgeInsetsMake(0, -3, 0, 3)];
        [_diggButton setContentEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 3)];
        [_diggButton setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [_diggButton setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        
        __weak typeof(self) weakSelf = self;
        [_diggButton setClickedBlock:^(TTDiggButtonClickType type) {
//            if (type == TTDiggButtonClickTypeAlreadyDigg) {
//                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"您已经赞过" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
//            }
//            else if (type == TTDiggButtonClickTypeDigg) {
                [weakSelf diggAction];
//            }
        }];
    }
    return _diggButton;
}

- (FRLineView *)topLine
{
    if (!_topLine) {
        _topLine = [[FRLineView alloc] initWithFrame:CGRectZero];
        _topLine.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
        _topLine.borderType = FRBorderTypeTop;
        _topLine.borderColor = [UIColor tt_themedColorForKey:kColorLine7];
    }
    
    return _topLine;
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    _topLine.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
    _topLine.borderColor = [UIColor tt_themedColorForKey:kColorLine7];
}

- (void)setPlaceholderContent:(NSString *)placeholderContent {
    if (isEmptyString(placeholderContent)) {
        [self.button setTitle:NSLocalizedString(@"回帖...", nil) forState:UIControlStateNormal];
    }else {
        [self.button setTitle:placeholderContent forState:UIControlStateNormal];
    }
}

- (void)buttonAction:(UIButton *)sender {
    if (_postCommentButtonClick) {
        _postCommentButtonClick();
    }
}

- (void)emojiAction:(UIButton *)sender {
    if (_emojiButtonClick) {
        _emojiButtonClick();
    }
}

- (void)diggAction {
    if(_diggButtonClick){
        _diggButtonClick();
    }
}

- (void)shareAction {
    if (_shareButtonClick) {
        _shareButtonClick();
    }
}

#pragma mark - safe Area

- (void)safeAreaInsetsDidChange
{
    [super safeAreaInsetsDidChange];
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeInset = self.safeAreaInsets;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        CGRect frameInWindow = [self convertRect:self.bounds toView:nil];
        if (ceil(self.height) - ceil(fr_postCommentButtonHeight()) == 0 &&
            screenHeight == ceil(CGRectGetMaxY(frameInWindow))){
            CGFloat toolBarHeight = (fr_postCommentButtonHeight() + safeInset.bottom);
            frameInWindow = CGRectMake(frameInWindow.origin.x, screenHeight - toolBarHeight, self.width,toolBarHeight);
            self.frame = [self.superview convertRect:frameInWindow fromView:nil];
            CGFloat deltaHeight = ceil(self.height) - ceil(fr_postCommentButtonHeight());
            [self.shareButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(@(-deltaHeight / 2));
            }];
        }
    }
}

@end
