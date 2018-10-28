//
//  ExploreDetailToolbarView.m
//  Article
//
//  Created by SunJiangting on 15/7/27.
//
//

#import "ExploreDetailToolbarView.h"
#import "UIButton+TTAdditions.h"
#import "TTAlphaThemedButton.h"
#import "ExploreVideoDetailHelper.h"
#import "TTDeviceHelper.h"
#import "TTBusinessManager+StringUtils.h"
#import "TTUGCEmojiTextAttachment.h"
#import "TTArticleDetailDefine.h"
#import "SSCommonLogic.h"

@interface ExploreDetailToolbarView ()

@property (nonatomic, strong) SSThemedLabel *commentLabel;
@property (nonatomic, strong) SSThemedLabel *collectLabel;
@property (nonatomic, strong) SSThemedLabel *shareLabel;
@property (nonatomic, assign) BOOL toolbarLabelEnabled;

@end

@implementation ExploreDetailToolbarView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        BOOL _isIPad = [TTDeviceHelper isPadDevice];
        TTAlphaThemedButton *writeButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        [writeButton setTitle:[SSCommonLogic exploreDetailToolBarWriteCommentPlaceholderText] forState:UIControlStateNormal];
        writeButton.height = [TTDeviceHelper isPadDevice] ? 36 : [TTDeviceUIUtils tt_newPadding:32];
        writeButton.titleLabel.font = [UIFont systemFontOfSize:(_isIPad ? 18 : 14)];
        writeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//        writeButton.imageEdgeInsets = UIEdgeInsetsMake(0, 8.f, 0, 0);
        writeButton.titleEdgeInsets = UIEdgeInsetsMake(0, _isIPad ? 25 : 16, 0, 0);
        writeButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:writeButton];
        _writeButton = writeButton;

        UIEdgeInsets toolBarButtonHitTestInsets = UIEdgeInsetsMake(-8.f, -12.f, -15.f, -12.f);

        TTAlphaThemedButton *emojiButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
//        [self addSubview:emojiButton];
        _emojiButton = emojiButton;
        _emojiButton.hitTestEdgeInsets = toolBarButtonHitTestInsets;

        TTAlphaThemedButton *commentButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:commentButton];
        _commentButton = commentButton;
        _commentButton.hitTestEdgeInsets = toolBarButtonHitTestInsets;

        TTAlphaThemedButton *topButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:topButton];
        _topButton = topButton;
        _topButton.hitTestEdgeInsets = toolBarButtonHitTestInsets;
        _topButton.hidden = YES;

        self.badgeLabel = [[SSThemedLabel alloc] init];
        self.badgeLabel.backgroundColorThemeKey = kColorBackground7;
        self.badgeLabel.textColorThemeKey = kColorText8;
        self.badgeLabel.font = [UIFont systemFontOfSize:8];
        self.badgeLabel.layer.cornerRadius = 5;
        self.badgeLabel.layer.masksToBounds = YES;
        self.badgeLabel.textAlignment = NSTextAlignmentCenter;
        [_commentButton addSubview:self.badgeLabel];
        
        TTAlphaThemedButton *collectButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:collectButton];
        _collectButton = collectButton;
        _collectButton.hitTestEdgeInsets = toolBarButtonHitTestInsets;
        
        TTAlphaThemedButton *shareButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:shareButton];
        _shareButton = shareButton;
        _shareButton.hitTestEdgeInsets = toolBarButtonHitTestInsets;
        [_shareButton addTarget:self action:@selector(shareButtonOnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        TTAlphaThemedButton *digButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _digButton = digButton;
        _digButton.hitTestEdgeInsets = toolBarButtonHitTestInsets;
        [self addSubview:digButton];
        
        _separatorView = [[SSThemedView alloc] init];
        _separatorView.backgroundColorThemeKey = kColorLine7;
        _separatorView.frame = CGRectMake(0, 0, self.width, [TTDeviceHelper ssOnePixel]);
        _separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_separatorView];

        self.viewStyle = TTDetailViewStyleDarkContent;
        
        _collectLabel = [[SSThemedLabel alloc] init];
        _collectLabel.textColorThemeKey = kColorText2;
        _collectLabel.font = [UIFont systemFontOfSize:9.f];
        _collectLabel.text = @"收藏";
        [_collectLabel sizeToFit];
        _collectLabel.hidden = YES;
        [self addSubview:_collectLabel];
        
        _commentLabel = [[SSThemedLabel alloc] init];
        _commentLabel.textColorThemeKey = kColorText2;
        _commentLabel.font = [UIFont systemFontOfSize:9.f];
        _commentLabel.text = @"评论";
        [_commentLabel sizeToFit];
        _commentLabel.hidden = YES;
        [self addSubview:_commentLabel];
        
        _shareLabel = [[SSThemedLabel alloc] init];
        _shareLabel.textColorThemeKey = kColorText2;
        _shareLabel.font = [UIFont systemFontOfSize:9.f];
        _shareLabel.text = @"分享";
        [_shareLabel sizeToFit];
        _shareLabel.hidden = YES;
        [self addSubview:_shareLabel];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWriteTitle:) name:@"TTCOMMENT_UPDATE_WRITETITLE" object:nil];
        self.banEmojiInput = YES;
    }
    return self;
}

- (void)updateWriteTitle:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    if (![userInfo tt_boolValueForKey:@"hasComments"]) {
        [self.writeButton setTitle:@"抢沙发..." forState:UIControlStateNormal];
    }
    else {
        [self.writeButton setTitle:[SSCommonLogic exploreDetailToolBarWriteCommentPlaceholderText] forState:UIControlStateNormal];
    }
}

- (void)setToolbarType:(ExploreDetailToolbarType)toolbarType {
    _toolbarType = toolbarType;
    
    switch (toolbarType) {
        case ExploreDetailToolbarTypeNormal:
            _writeButton.hidden = NO;
            _emojiButton.hidden = NO;
            _commentButton.hidden = NO;
            _collectButton.hidden = NO;
            _shareButton.hidden = NO;
            _digButton.hidden = YES;
            self.toolbarLabelEnabled = [SSCommonLogic toolbarLabelEnabled];
            break;
        case ExploreDetailToolbarTypeOnlyWriteButton:
            _writeButton.hidden = NO;
            _emojiButton.hidden = NO;
            _commentButton.hidden = YES;
            _collectButton.hidden = YES;
            _shareButton.hidden = YES;
            _digButton.hidden = YES;
            break;
        case ExploreDetailToolbarTypeExcludeCommentButtons:
            _writeButton.hidden = YES;
            _emojiButton.hidden = YES;
            _commentButton.hidden = YES;
            _collectButton.hidden = NO;
            _shareButton.hidden = NO;
            _digButton.hidden = YES;
            break;
        case  ExploreDetailToolbarTypeExcludeCollectButton:
            _writeButton.hidden = NO;
            _emojiButton.hidden = NO;
            _commentButton.hidden = NO;
            _collectButton.hidden = YES;
            _shareButton.hidden = NO;
            _digButton.hidden = YES;
            break;
        case ExploreDetailToolbarTypeArticleComment: {
            _writeButton.hidden = NO;
            _emojiButton.hidden = NO;
            _commentButton.hidden = NO;
            _collectButton.hidden = NO;
            _shareButton.hidden = NO;
            _digButton.hidden = YES;
            self.toolbarLabelEnabled = [SSCommonLogic toolbarLabelEnabled];
            self.backgroundColorThemeKey = kColorBackground4;
        }
            break;
        case ExploreDetailToolbarTypePhotoComment: {
            _writeButton.hidden = NO;
            _emojiButton.hidden = NO;
            _commentButton.hidden = NO;
            _collectButton.hidden = NO;
            _shareButton.hidden = NO;
            _digButton.hidden = YES;
            self.toolbarLabelEnabled = [SSCommonLogic toolbarLabelEnabled];
        }
            break;
        case ExploreDetailToolbarTypePhotoOnlyWriteButton: {
            _writeButton.hidden = NO;
            _emojiButton.hidden = NO;
            _commentButton.hidden = YES;
            _collectButton.hidden = YES;
            _shareButton.hidden = YES;
            _digButton.hidden = YES;
            self.backgroundColorThemeKey = kColorBackground4;
        }
        case ExploreDetailToolbarTypeCommentDetail: {
            _writeButton.hidden = NO;
            _emojiButton.hidden = NO;
            _commentButton.hidden = YES;
            _collectButton.hidden = YES;
            _shareButton.hidden = YES;
            _digButton.hidden = NO;
            self.backgroundColorThemeKey = kColorBackground4;
            [_writeButton setTitle:@"回复" forState:UIControlStateNormal];
        }
            
        default:
            break;
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
    CGRect writeFrame = CGRectZero, emojiFrame = CGRectZero, commentFrame = CGRectZero, shareFrame = CGRectZero, collectFrame = CGRectZero, digFrame = CGRectZero;
    CGFloat width = self.width;
    CGFloat margin = [TTDeviceHelper is736Screen] ? 10 : ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]?5:0);
    if (self.toolbarType == ExploreDetailToolbarTypeNormal) {
        writeFrame = CGRectMake(15 + leftInset, writeTopMargin, width - (169 + margin * 3) - hInset, writeButtonHeight);
        emojiFrame = CGRectMake(CGRectGetMaxX(writeFrame) - 22 - 6, CGRectGetMinY(writeFrame) + (writeButtonHeight - 22) / 2, 22, 22);
        commentFrame = CGRectMake(CGRectGetMaxX(writeFrame) + 22 + margin, iconTopMargin, 24, 24);
        shareFrame = CGRectMake(width - 38 - rightInset, iconTopMargin, 24, 24);
        collectFrame = CGRectMake(CGRectGetMinX(shareFrame) - 46 - margin, iconTopMargin, 24, 24);
    } else if (self.toolbarType == ExploreDetailToolbarTypeOnlyWriteButton) {
        CGFloat sidePadding = [TTDeviceHelper isPadDevice] ? [TTUIResponderHelper paddingForViewWidth:width] : 15.0f;
        writeFrame = CGRectMake(sidePadding + leftInset, writeTopMargin, width - sidePadding * 2 - hInset, writeButtonHeight);
        emojiFrame = CGRectMake(CGRectGetMaxX(writeFrame) - 22 - 6, CGRectGetMinY(writeFrame) + (writeButtonHeight - 22) / 2, 22, 22);
    } else if (self.toolbarType == ExploreDetailToolbarTypeExcludeCommentButtons) {
        collectFrame = CGRectMake(0, iconTopMargin, width / 2, 24);
        shareFrame = CGRectMake(width / 2, iconTopMargin, width / 2, 24);
    } else if (self.toolbarType == ExploreDetailToolbarTypeArticleComment) {
        //169是什么...❓
        writeFrame = CGRectMake(15 + leftInset, writeTopMargin, width - (169 + margin * 3) - hInset, writeButtonHeight);
        emojiFrame = CGRectMake(CGRectGetMaxX(writeFrame) - 22 - 6, CGRectGetMinY(writeFrame) + (writeButtonHeight - 22) / 2, 22, 22);
        commentFrame = CGRectMake(CGRectGetMaxX(writeFrame) + 22 + margin, iconTopMargin, 24, 24);
        shareFrame = CGRectMake(width - 38 - rightInset, iconTopMargin, 24, 24);
        collectFrame = CGRectMake(CGRectGetMinX(shareFrame) - 46 - margin, iconTopMargin, 24, 24);
    } else if (self.toolbarType == ExploreDetailToolbarTypePhotoComment) {
        writeFrame = CGRectMake(15 + leftInset, writeTopMargin, width - (169 + margin * 3) - hInset, writeButtonHeight);
        emojiFrame = CGRectMake(CGRectGetMaxX(writeFrame) - 22 - 6, CGRectGetMinY(writeFrame) + (writeButtonHeight - 22) / 2, 22, 22);
        commentFrame = CGRectMake(CGRectGetMaxX(writeFrame) + 22 + margin, iconTopMargin, 24, 24);
        shareFrame = CGRectMake(width - 38 - rightInset, iconTopMargin, 24, 24);
        collectFrame = CGRectMake(CGRectGetMinX(shareFrame) - 46 - margin, iconTopMargin, 24, 24);
    } else if (self.toolbarType == ExploreDetailToolbarTypePhotoOnlyWriteButton) {
        CGFloat sidePadding = [TTDeviceHelper isPadDevice] ? [TTUIResponderHelper paddingForViewWidth:width] : 15.0f;
        writeFrame = CGRectMake(sidePadding + leftInset, writeTopMargin, width - sidePadding * 2 - hInset, writeButtonHeight);
        emojiFrame = CGRectMake(CGRectGetMaxX(writeFrame) - 22 - 6, CGRectGetMinY(writeFrame) + (writeButtonHeight - 22) / 2, 22, 22);
    } else if (self.toolbarType == ExploreDetailToolbarTypeCommentDetail) {
//        shareFrame = CGRectMake(width - 43 - rightInset, iconTopMargin, 24, 24);
        digFrame = CGRectMake(width - 46 - margin, iconTopMargin, 24, 24);
        writeFrame = CGRectMake(15 + leftInset, writeTopMargin, CGRectGetMinX(digFrame) - 30 - hInset, writeButtonHeight);
        emojiFrame = CGRectMake(CGRectGetMaxX(writeFrame) - 22 - 6 , CGRectGetMinY(writeFrame) + (writeButtonHeight - 22) / 2, 22, 22);
    } else {
        shareFrame = CGRectMake(width - 38 - rightInset, iconTopMargin, 24, 24);
        commentFrame = CGRectMake(CGRectGetMinX(shareFrame) - 46 - margin, iconTopMargin, 24, 24);
        writeFrame = CGRectMake(15 + leftInset, writeTopMargin, CGRectGetMinX(commentFrame) - margin - 39 - hInset, writeButtonHeight);
        emojiFrame = CGRectMake(CGRectGetMaxX(writeFrame) - 22 - 6, CGRectGetMinY(writeFrame) + (writeButtonHeight - 22) / 2, 22, 22);
    }
    
    _writeButton.frame = writeFrame;
    _emojiButton.frame = emojiFrame;
    _commentButton.frame = commentFrame;
    _topButton.frame = commentFrame;
    _shareButton.frame = shareFrame;
    _collectButton.frame = collectFrame;
    _digButton.frame = digFrame;
    
    BOOL _isIPad = [TTDeviceHelper isPadDevice];
    _writeButton.titleEdgeInsets = UIEdgeInsetsMake(0, _isIPad ? 25 : 16, 0, _emojiButton.width + 4);
    
    
    
//    //显示按钮热区
//    UIView *backView0 = [[UIView alloc] initWithFrame:CGRectOffset(self.writeButton.frame, 0, 0)];
//    backView0.width = self.writeButton.width;
//    backView0.height = self.writeButton.height;
//    backView0.backgroundColor = [UIColor cyanColor];
//    [self addSubview:backView0];
//    [self bringSubviewToFront:self.writeButton];
//
//    
//    UIView *backView = [[UIView alloc] initWithFrame:CGRectOffset(self.commentButton.frame, -10, -8)];
//    backView.width = self.commentButton.width + 20;
//    backView.height = self.commentButton.height + 16;
//    backView.backgroundColor = [UIColor cyanColor];
//    [self addSubview:backView];
//    [self bringSubviewToFront:self.commentButton];
//    
//    UIView *backView2 = [[UIView alloc] initWithFrame:CGRectOffset(self.collectButton.frame, -10, -8)];
//    backView2.width = self.collectButton.width + 20;
//    backView2.height = self.collectButton.height + 16;
//    backView2.backgroundColor = [UIColor cyanColor];
//    [self addSubview:backView2];
//    [self bringSubviewToFront:self.collectButton];
//
//    
//    UIView *backView3 = [[UIView alloc] initWithFrame:CGRectOffset(self.shareButton.frame, -10, -8)];
//    backView3.width = self.shareButton.width + 20;
//    backView3.height = self.shareButton.height + 16;
//    backView3.backgroundColor = [UIColor cyanColor];
//    [self addSubview:backView3];
//    [self bringSubviewToFront:self.shareButton];
//
//    //end test
    
    [self relayoutItems];
    
    if (self.toolbarLabelEnabled) {
        _commentButton.top -= 5.f;
        _commentLabel.centerX = _commentButton.centerX;
        _commentLabel.top = _commentButton.bottom;
        _commentLabel.left = nearbyintf(_commentLabel.left);
        
        _collectButton.top -= 5.f;
        _collectLabel.centerX = _collectButton.centerX;
        _collectLabel.top = _collectButton.bottom;
        _collectLabel.left = nearbyintf(_collectLabel.left);
        
        _shareButton.top -= 5.f;
        _shareLabel.centerX = _shareButton.centerX;
        _shareLabel.top = _shareButton.bottom;
        _shareLabel.left = nearbyintf(_shareLabel.left);
    }
}

- (void)safeAreaInsetsDidChange
{
    [super safeAreaInsetsDidChange];
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeInset = self.superview.safeAreaInsets;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        CGRect frameInWindow = [self convertRect:self.bounds toView:nil];
        if (ceil(self.height) - ceil(ExploreDetailGetToolbarHeight()) == 0 &&
            screenHeight == ceil(CGRectGetMaxY(frameInWindow))){
            CGFloat toolBarHeight = (ExploreDetailGetToolbarHeight() + safeInset.bottom);
            frameInWindow = CGRectMake(frameInWindow.origin.x, screenHeight - toolBarHeight, self.width,toolBarHeight);
            self.frame = [self.superview convertRect:frameInWindow fromView:nil];
        }
    }
}

- (void)setFrame:(CGRect)frame {
    if (CGRectGetHeight(frame) == 0){
        frame.size.height = ExploreDetailGetToolbarHeight();
    }
    [super setFrame:frame];
    
    self.separatorView.top = 0;

}

/*
 *  ipad上根据屏幕宽度重刷item位置
 */
- (void)relayoutItems
{
    if (![TTDeviceHelper isPadDevice] || _toolbarType == ExploreDetailToolbarTypeOnlyWriteButton) {
        return;
    }
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
     */
    
    
    static CGFloat writeMinLen = 120.f;
    static CGFloat writeMaxLen = 465.f;
    static CGFloat firstMarginAspect = 1.1f;
    
    CGFloat mSumMinLen = 44.f + 44.f + 40.f;
    CGFloat mSumMaxLen = 110.f + 110.f + 106.f;
    CGFloat marginAspects = 1.1f + 1.1f + 1.0f;
    
    CGFloat baseItemMargin;
    CGFloat edgeMargin = [TTUIResponderHelper paddingForViewWidth:self.width];
    
    //视频详情页横屏分屏模式下特殊适配
    if (self.fromView == ExploreDetailToolbarFromViewVideoDetail &&
        [ExploreVideoDetailHelper currentVideoDetailRelatedStyle] == VideoDetailRelatedStyleDistinct &&
        [TTDeviceHelper isPadDevice]) {
        if ([TTDeviceHelper isIpadProDevice]) {
            edgeMargin = 100;
        } else {
            edgeMargin = 75;
        }
    }
    
    CGFloat fixWidthOfRightItems = _commentButton.width + _shareButton.width + _collectButton.width;
    CGFloat checkWidth = self.width - edgeMargin * 2 - fixWidthOfRightItems;
    _writeButton.left = edgeMargin;
    if (checkWidth < writeMinLen + mSumMinLen) {
        //case(1)
        _writeButton.width = writeMinLen;
        baseItemMargin = (checkWidth - _writeButton.width)/marginAspects;
        _commentButton.left = _writeButton.right + baseItemMargin * firstMarginAspect;
        _emojiButton.right = _commentButton.right - 22 - 6;
        _topButton.left = _commentButton.left;
        _collectButton.left = _commentButton.right + baseItemMargin * firstMarginAspect;
        _shareButton.left = _collectButton.right + baseItemMargin;
    }
    else if (checkWidth < writeMaxLen + mSumMinLen) {
        //case(2)
        _writeButton.width = checkWidth - mSumMinLen;
        _emojiButton.right = _commentButton.right - 22 - 6;
        _commentButton.left = _writeButton.right + 44.f;
        _topButton.left = _commentButton.left;
        _collectButton.left = _commentButton.right + 44.f;
        _shareButton.left = _collectButton.right + 40.f;
    }
    else if (checkWidth < writeMaxLen + mSumMaxLen) {
        //case(3)
        _writeButton.width = writeMaxLen;
        _emojiButton.right = _commentButton.right - 22 - 6;
        baseItemMargin = (checkWidth - _writeButton.width)/marginAspects;
        _commentButton.left = _writeButton.right + baseItemMargin * firstMarginAspect;
        _topButton.left = _commentButton.left;
        _collectButton.left = _commentButton.right + baseItemMargin * firstMarginAspect;
        _shareButton.left = _collectButton.right + baseItemMargin;
    }
    else {
        //case(4)
        _writeButton.width = checkWidth - mSumMaxLen;
        _emojiButton.right = _commentButton.right - 22 - 6;
        _commentButton.left = _writeButton.right + 110.f;
        _topButton.left = _commentButton.left;
        _collectButton.left = _commentButton.right + 110.f;
        _shareButton.left = _collectButton.right + 106.f;
    }
}

- (void)setViewStyle:(TTDetailViewStyle)viewStyle {
    _viewStyle = viewStyle;
    if (viewStyle == TTDetailViewStyleLightContent) {
        self.backgroundColorThemeKey = nil;
        self.backgroundColor = [UIColor clearColor];

        _emojiButton.imageName = @"input_emoji";
        _commentButton.imageName = @"icon_details_comment";
        [_commentButton setTintColor:[UIColor whiteColor]];
        _collectButton.imageName = @"icon_details_collect";
        [_collectButton setTintColor:[UIColor whiteColor]];
        _shareButton.imageName = @"icon_details_share";
        [_shareButton setTintColor:[UIColor whiteColor]];
        
        _writeButton.titleColors = nil;
        _writeButton.borderColors = nil;
        _writeButton.borderColorThemeKey = nil;
        _writeButton.backgroundColorThemeKey = nil;

        if ([TTDeviceHelper isPadDevice]) {
            
            _writeButton.titleColorThemeKey = kFHColorCoolGrey3;
            _writeButton.backgroundColor = [UIColor clearColor];
            _writeButton.borderColorThemeKey = kColorLine8;
            _writeButton.layer.cornerRadius = _writeButton.height / 2.f;
            _writeButton.layer.borderWidth = [TTDeviceHelper ssOnePixel];
            
        } else {
            
            _writeButton.titleColorThemeKey = kFHColorCoolGrey3;
            _writeButton.backgroundColor = [[UIColor colorWithHexString:@"#FFFFFF"] colorWithAlphaComponent:.1f];
            
            _writeButton.layer.cornerRadius = _writeButton.height / 2.f;
            _writeButton.layer.borderWidth = 0;
        }
        
        _writeButton.layer.masksToBounds = YES;
        _separatorView.hidden = YES;
        
    }
    else if (viewStyle == TTDetailViewStyleDarkContent || viewStyle == TTDetailViewStyleArticleComment) {
        self.backgroundColorThemeKey = kColorBackground4;

        _emojiButton.imageName = @"input_emoji";
        _commentButton.imageName = @"tab_comment";
        _collectButton.imageName = @"tab_collect";
        _collectButton.selectedImageName = @"tab_collect_press";
        _shareButton.imageName = [self _shareIconName];
        _writeButton.borderColors = nil;
        _writeButton.borderColorThemeKey = kColorLine1;
        _writeButton.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _writeButton.titleColorThemeKey = kFHColorCoolGrey3;
        _writeButton.layer.cornerRadius = _writeButton.height / 2.f;
        _writeButton.backgroundColorThemeKey = kColorBackground3;
        _writeButton.layer.masksToBounds = YES;
        
//        [_writeButton setImageName:@"write_new"];
        _writeButton.tintColor = [UIColor tt_themedColorForKey:kColorText1];
    }
    else if (viewStyle == TTDetailViewStylePhotoComment) {
        _emojiButton.imageName = @"input_emoji";
        _commentButton.imageName = @"icon_details_comment";
        _collectButton.imageName = @"icon_details_collect";
        _shareButton.imageName = [self _photoShareIconName];
        
        _writeButton.titleColorThemeKey = kFHColorCoolGrey3;
//        [_writeButton setImageName:@"write_new"];
        _writeButton.tintColor = [UIColor tt_themedColorForKey:kColorText12];
        _writeButton.backgroundColorThemeKey = nil;
        _writeButton.backgroundColor = [SSGetThemedColorWithKey(kColorBackground4) colorWithAlphaComponent:0.15];
        _writeButton.layer.cornerRadius = _writeButton.height / 2.f;
        _writeButton.layer.borderWidth = 0;
        _separatorView.hidden = YES;
        _commentLabel.textColors = @[[UIColor colorWithHexString:@"FFFFFFE6"], [UIColor colorWithHexString:@"FFFFFFE6"]];
        _collectLabel.textColors = @[[UIColor colorWithHexString:@"FFFFFFE6"], [UIColor colorWithHexString:@"FFFFFFE6"]];
        _shareLabel.textColors = @[[UIColor colorWithHexString:@"FFFFFFE6"], [UIColor colorWithHexString:@"FFFFFFE6"]];
//        self.backgroundColor = [[UIColor ] colorWithAlphaComponent:.7f];
        self.backgroundColorThemeKey = kColorBackground15;
        
    }
    else if (viewStyle == TTDetailViewStylePhotoOnlyWriteButton) {
        self.backgroundColorThemeKey = kColorBackground4;

        _emojiButton.imageName = @"input_emoji";

        _writeButton.borderColorThemeKey = kColorLine1;
        _writeButton.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _writeButton.borderColors = nil;
        _writeButton.titleColorThemeKey = kFHColorCoolGrey3;
        _writeButton.layer.cornerRadius = _writeButton.height / 2.f;
        _writeButton.layer.masksToBounds = YES;
        _writeButton.backgroundColorThemeKey = kColorBackground3;
//        [_writeButton setImageName:@"write_new"];
        _separatorView.hidden = NO;
    }
    else if (viewStyle == TTDetailViewStyleCommentDetail) {
        self.backgroundColorThemeKey = kColorBackground4;

        _emojiButton.imageName = @"input_emoji";
        _digButton.imageName = @"digup_tabbar";
        _digButton.selectedImageName = @"digup_tabbar_press";
        _digButton.tintColor = [UIColor tt_themedColorForKey:kColorText1];
        _shareButton.imageName = @"tab_share";
        
        _writeButton.borderColorThemeKey = kColorLine1;
        _writeButton.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _writeButton.borderColors = nil;
        _writeButton.titleColorThemeKey = kFHColorCoolGrey3;
        _writeButton.layer.cornerRadius = _writeButton.height / 2.f;
        _writeButton.layer.masksToBounds = YES;
        _writeButton.backgroundColorThemeKey = kColorBackground3;
//        [_writeButton setImageName:@"write_new"];
        
        _writeButton.tintColor = [UIColor tt_themedColorForKey:kColorText1];
    }
}

- (void)setCommentBadgeValue:(NSString *)commentBadgeValue {
    int64_t value = [commentBadgeValue longLongValue];
    commentBadgeValue = [TTBusinessManager formatCommentCount:value];
    if ([commentBadgeValue integerValue] == 0) {
        commentBadgeValue = nil;
    }
    _commentBadgeValue = commentBadgeValue;
    self.badgeLabel.text = commentBadgeValue;
    if (isEmptyString(commentBadgeValue)) {
        self.badgeLabel.hidden = YES;
    } else {
        self.badgeLabel.hidden = NO;
        [self.badgeLabel sizeToFit];
        self.badgeLabel.width += 8;
        self.badgeLabel.width = MAX(self.badgeLabel.width, 15);
        self.badgeLabel.height = 10;
        self.badgeLabel.origin = CGPointMake(11, 0);
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

#pragma mark - target-action

- (void)shareButtonOnClicked:(id)sender {
    [TTTrackerWrapper eventV3:@"share_icon_click" params:@{@"icon_type": @([SSCommonLogic shareIconStye]).stringValue}];
}

- (void)themeChanged:(NSNotification *)notification {
    if (self.viewStyle == TTDetailViewStyleDarkContent || self.viewStyle == TTDetailViewStyleArticleComment) {
        _writeButton.tintColor = [UIColor tt_themedColorForKey:kColorText1];
    }
    else if (self.viewStyle == TTDetailViewStylePhotoComment) {
        _writeButton.tintColor = [UIColor tt_defaultColorForKey:kColorText12];
//        self.backgroundColor = [[UIColor colorWithHexString:@"#1B1B1B"] colorWithAlphaComponent:.7f];
        self.backgroundColorThemeKey = kColorBackground15;
        _writeButton.backgroundColor = [[UIColor tt_defaultColorForKey:kColorBackground4] colorWithAlphaComponent:0.15];
    }
    else if (self.viewStyle == TTDetailViewStylePhotoOnlyWriteButton) {
        _writeButton.tintColor = [UIColor tt_themedColorForKey:kColorText1];
//        self.layer.shadowColor = [UIColor tt_themedColorForKey:kColorLine7].CGColor;
    }
}

- (void)setToolbarLabelEnabled:(BOOL)toolbarLabelEnabled {
    _toolbarLabelEnabled = toolbarLabelEnabled;
    _commentLabel.hidden = !toolbarLabelEnabled;
    _collectLabel.hidden = !toolbarLabelEnabled;
    _shareLabel.hidden = !toolbarLabelEnabled;
}

- (NSString *)_shareIconName {
    switch ([SSCommonLogic shareIconStye]) {
        case 1:
            return @"tab_share";
            break;
        case 2:
            return @"tab_share1";
            break;
        case 3:
            return @"tab_share4";
            break;
        case 4:
            return @"tab_share3";
            break;
        default:
            return @"tab_share";
            break;
    }
}

- (NSString *)_photoShareIconName {
    switch ([SSCommonLogic shareIconStye]) {
        case 1:
            return @"icon_details_share";
            break;
        case 2:
            return @"white_share1";
            break;
        case 3:
            return @"white_share4";
            break;
        case 4:
            return @"white_share3";
            break;
        default:
            return @"icon_details_share";
            break;
    }
}

@end

CGFloat ExploreDetailGetToolbarHeight(void) {
    return ([TTDeviceHelper isPadDevice] ? 50 : 44) + [TTDeviceHelper ssOnePixel];
}

