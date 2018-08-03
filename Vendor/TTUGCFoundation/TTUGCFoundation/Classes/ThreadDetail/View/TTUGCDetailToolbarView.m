//
//  TTUGCDetailToolbarView.m
//  Article
//
//  Created by 王霖 on 16/12/12.
//
//

#import "TTUGCDetailToolbarView.h"
#import "TTUGCEmojiTextAttachment.h"
#import <TTBubbleView.h>
#import <TTMultiDigManager.h>
#import <TTAlphaThemedButton.h>
#import <TTKitchenHeader.h>
#import <TTDiggButton.h>
#import <TTDeviceHelper.h>
#import <UIButton+TTAdditions.h>
#import <UIViewAdditions.h>
#import <TTUIResponderHelper.h>
#import <TTTrackerWrapper.h>
#import <TTUGCPodBridge.h>

CGFloat TTUGCDetailGetToolbarHeight(void) {
    return ([TTDeviceHelper isPadDevice] ? 50 : 44) + [TTDeviceHelper ssOnePixel];
}

@interface TTUGCDetailToolbarView ()

@property(nonatomic, strong) TTAlphaThemedButton * writeCommentButton;
@property(nonatomic, strong) TTDiggButton * diggButton;
@property(nonatomic, strong) TTAlphaThemedButton * shareButton;
@property(nonatomic, strong) SSThemedView * separatorView;

@end

@implementation TTUGCDetailToolbarView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColorThemeKey = kColorBackground4;
        
        _separatorView = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _separatorView.backgroundColorThemeKey = kColorLine7;
        [self addSubview:_separatorView];
        
        BOOL isIPad = [TTDeviceHelper isPadDevice];
        _writeCommentButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        NSString *writeCommentButtonTitle;
        if ([[TTUGCPodBridge sharedInstance] exploreDetailToolBarWriteCommentPlaceholderText]) {
            writeCommentButtonTitle = [[TTUGCPodBridge sharedInstance] exploreDetailToolBarWriteCommentPlaceholderText];
        } else {
            writeCommentButtonTitle = NSLocalizedString(@"写评论...", nil);
        }
        [_writeCommentButton setTitle:writeCommentButtonTitle forState:UIControlStateNormal];
        _writeCommentButton.titleLabel.font = [UIFont systemFontOfSize:(isIPad ? 18 : 13)];
        _writeCommentButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        _writeCommentButton.imageEdgeInsets = UIEdgeInsetsMake(0, 8.f, 0, 0);
        _writeCommentButton.titleEdgeInsets = UIEdgeInsetsMake(0, isIPad ? 25 : 8, 0, 0);
        _writeCommentButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        _writeCommentButton.borderColorThemeKey = kColorLine1;
        _writeCommentButton.titleColorThemeKey = kColorText1;
        _writeCommentButton.titleColorThemeKey = kColorText1;
        _writeCommentButton.highlightedTitleColorThemeKey = kColorText3Highlighted;
        _writeCommentButton.backgroundColorThemeKey = kColorBackground3;
        
        _writeCommentButton.layer.cornerRadius = ([TTDeviceHelper isPadDevice] ? 18 : 16);
        _writeCommentButton.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _writeCommentButton.layer.masksToBounds = YES;
        
        [_writeCommentButton setImageName:@"write_new"];
        
        _writeCommentButton.tintColor = [UIColor tt_themedColorForKey:kColorText1];
        [self addSubview:_writeCommentButton];
        
        UIEdgeInsets toolBarButtonHitTestInsets = UIEdgeInsetsMake(-8.f, -10.f, -8.f, -10.f);
        
        _emojiButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _emojiButton.hitTestEdgeInsets = toolBarButtonHitTestInsets;
        _emojiButton.imageName = @"input_emoji";
        [self addSubview:_emojiButton];
        
        _diggButton = [TTDiggButton diggButtonWithStyleType:TTDiggButtonStyleTypeImageOnly];
        _diggButton.hitTestEdgeInsets = toolBarButtonHitTestInsets;
        _diggButton.imageName = @"tab_like";
        _diggButton.selectedImageName = @"tab_like_press";
        [self addSubview:_diggButton];
        
        _shareButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _shareButton.hitTestEdgeInsets = toolBarButtonHitTestInsets;
        _shareButton.imageName = [self _shareIconName];
        [_shareButton addTarget:self action:@selector(shareButtonOnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_shareButton];
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame {
    frame.size.height = TTUGCDetailGetToolbarHeight();
    [super setFrame:frame];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _separatorView.frame = CGRectMake(0, 0, self.width, [TTDeviceHelper ssOnePixel]);
    
    CGRect writeCommentButtonFrame = CGRectZero;
    CGRect emojiButtonFrame = CGRectZero;
    CGRect diggButtonFrame = CGRectZero;
    CGRect shareButtonFrame = CGRectZero;
    
    CGFloat writeCommentButtonHeight = [TTDeviceHelper isPadDevice] ? 36 : 32;
    CGFloat writeCommentButtonTopMargin = ceil((self.height - writeCommentButtonHeight) / 2);
    CGFloat iconTopMargin = ceil((self.height - 24) / 2);
    
    CGFloat width = self.width;
    CGFloat margin = [TTDeviceHelper is736Screen] ? 10 : ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]?5:0);
    writeCommentButtonFrame = CGRectMake(15, writeCommentButtonTopMargin, width - (15*2 + 24*2 + 22*2 + margin * 2), writeCommentButtonHeight);
    emojiButtonFrame = CGRectMake(CGRectGetMaxX(writeCommentButtonFrame) - 22 - 6, CGRectGetMinY(writeCommentButtonFrame) + 5, 22, 22);
    diggButtonFrame = CGRectMake(CGRectGetMaxX(writeCommentButtonFrame) + 22 + margin, iconTopMargin, 24, 24);
    shareButtonFrame = CGRectMake(width - 15 - 24, iconTopMargin, 24, 24);
    
    _writeCommentButton.frame = writeCommentButtonFrame;
    _writeCommentButton.layer.cornerRadius = _writeCommentButton.height/2.f;
    _emojiButton.frame = emojiButtonFrame;
    _diggButton.frame = diggButtonFrame;
    _shareButton.frame = shareButtonFrame;
    
    BOOL isIPad = [TTDeviceHelper isPadDevice];
    _writeCommentButton.titleEdgeInsets = UIEdgeInsetsMake(0, isIPad ? 25 : 8, 0, _emojiButton.width + 4);
    
    if ([TTDeviceHelper isPadDevice]) {
        [self layoutSubviewsForIPad];
    }
}

- (void)layoutSubviewsForIPad {
    /*
     *  ipad下toolbarItem布局规则: l表示_writeButton宽度，m0_m1_m2表示四个item的三个间距；
     *  整个toolbar两边边距按基本规则算出；
     *  屏幕最窄时，l取最小宽度120, m0_m1_m2压缩；
     *  (1)屏幕逐渐变宽，m0_m1_m2持续拉伸；
     *  (2)m0_m1_m2到达44_44_40后不再拉伸，l开始拉伸；
     *  (3)l拉伸至最大宽度465后不再拉伸，转而拉伸m0_m1_m2；
     *  (4)m0_m1_m2再次拉伸至最大值110_110_106后不再拉伸，转而拉伸l，直至无限大；
     *
     *  特殊情况：图集详情界面会多出个下载按钮，
     *          与上述最后一个 Button 的间距为 44(对应上述情况(2)) 和 110(对应上述情况(4))，
     *          间距变化计算规则同上述。
     *  两个icon的情况：l再加上(m0+24.0)
     */
    static CGFloat writeMinLen = 120.f;
    static CGFloat writeMaxLen = 465.f;
    static CGFloat firstMarginAspect = 1.1f;
    
    CGFloat mSumMinLen = 44.f + 44.f + 40.f;
    CGFloat mSumMaxLen = 110.f + 110.f + 106.f;
    CGFloat marginAspects = 1.1f + 1.1f + 1.0f;
    
    CGFloat baseItemMargin;
    CGFloat edgeMargin = [TTUIResponderHelper paddingForViewWidth:self.width];
    
    CGFloat fixWidthOfRightItems = 24 * 3;
    CGFloat checkWidth = self.width - edgeMargin * 2 - fixWidthOfRightItems;
    _writeCommentButton.left = edgeMargin;
    if (checkWidth < writeMinLen + mSumMinLen) {
        //case(1)
        baseItemMargin = (checkWidth - writeMinLen)/marginAspects;
        _writeCommentButton.width = writeMinLen + baseItemMargin * firstMarginAspect + 24.f;
        _emojiButton.right = _writeCommentButton.right - 22 - 6;
        _diggButton.left = _writeCommentButton.right + baseItemMargin * firstMarginAspect;
        _shareButton.left = _diggButton.right + baseItemMargin;
        
    }else if (checkWidth < writeMaxLen + mSumMinLen) {
        //case(2)
        _writeCommentButton.width = checkWidth - mSumMinLen + 44.f + 24.f;
        _emojiButton.right = _writeCommentButton.right - 22 - 6;
        _diggButton.left = _writeCommentButton.right + 44.f;
        _shareButton.left = _diggButton.right + 40.f;
        
    }else if (checkWidth < writeMaxLen + mSumMaxLen) {
        //case(3)
        baseItemMargin = (checkWidth - writeMaxLen)/marginAspects;
        _writeCommentButton.width = writeMaxLen + baseItemMargin * firstMarginAspect + 24.f;
        _emojiButton.right = _writeCommentButton.right - 22 - 6;
        _diggButton.left = _writeCommentButton.right + baseItemMargin * firstMarginAspect;
        _shareButton.left = _diggButton.right + baseItemMargin;
        
    }
    else {
        //case(4)
        _writeCommentButton.width = checkWidth - mSumMaxLen + 24.f + 110.f;
        _emojiButton.right = _writeCommentButton.right - 22 - 6;
        _diggButton.left = _writeCommentButton.right + 110.f;
        _shareButton.left = _diggButton.right + 106.f;
    }
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
    [TTTrackerWrapper eventV3:@"share_icon_click" params:@{@"icon_type": @([[TTUGCPodBridge sharedInstance] shareIconStye]).stringValue}];
}

- (NSString *)_shareIconName {
//    if ([[TTKitchenMgr sharedInstance] getBOOL:kKCShareBoardDisplayRepost]) {
//        switch ([[TTUGCPodBridge sharedInstance] shareIconStye]) {
//            case 1:
//                return @"tab_share";
//                break;
//            case 2:
//                return @"tab_share1";
//                break;
//            case 3:
//                return @"tab_share4";
//                break;
//            case 4:
//                return @"tab_share3";
//                break;
//            default:
//                return @"tab_share";
//                break;
//        }
//    } else {
        return @"tab_forwarding";
//    }
}

- (void)safeAreaInsetsDidChange {
    self.top -= self.tt_safeAreaInsets.bottom;
}

@end

