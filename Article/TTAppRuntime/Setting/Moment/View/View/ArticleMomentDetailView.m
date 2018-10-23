//
//  ArticleMomentDetailView.m
//  Article
//
//  Created by Zhang Leonardo on 14-5-26.
//
//
#import "ArticleMomentDetailView.h"
#import "ArticleTitleImageView.h"
#import "SSUserModel.h"
#import "ArticleAvatarView.h"
#import "ExploreAvatarView+VerifyIcon.h"
#import "TTImageView.h"
#import "ArticleMomentCommentModel.h"
#import "ArticleMomentCommentManager.h"
#import "SSLoadMoreCell.h"
#import "ArticleMomentHelper.h"
#import "ArticleMomentDigUsersViewController.h"
#import "ArticleCommentView.h"
#import "UIImageAdditions.h"
#import "ArticleMomentManager.h"
#import "ArticleMomentGroupModel.h"
#import "NetworkUtilities.h"
#import "SSUserSettingManager.h"
#import "SSAttributeLabel.h"
#import "SSNavigationBar.h"
#import "ExploreLogicSetting.h"
#import <TTAccountBusiness.h>
#import "TTUserInfoView.h"

#import "UIButton+TTAdditions.h"
#import "ExploreMomentListCellHeaderItem.h"
#import "NewsUserSettingManager.h"
#import "SSMotionRender.h"
#import "DetailActionRequestManager.h"
#import "ExploreDeleteManager.h"
#import "SSIndicatorTipsManager.h"
#import "TTActivityShareManager.h"
#import "SSActivityView.h"
#import "ArticleShareManager.h"
#import "SSCommentManager.h"
#import "TTThemedAlertController.h"
#import "TTIndicatorView.h"
#import <FRPostCommonButton.h>
#import "ArticleMomentDiggManager.h"
#import "ArticleForwardViewController.h"

#import "TTReportManager.h"
#import "TTDeviceHelper.h"
#import "UIImage+TTThemeExtension.h"
#import "TTDeviceUIUtils.h"

#import "TTBusinessManager+StringUtils.h"
#import "TTStringHelper.h"
#import "TTLabelTextHelper.h"
#import "TTActionSheetController.h"
#import "TTAsyncLabel.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "ExploreMixListDefine.h"
#import "Comment.h"
#import "TTArticleCategoryManager.h"
//#import "TTRepostViewController.h"
//#import "TTRepostOriginModels.h"
//#import "FRThreadSmartDetailManager.h"

#import "TTUserSettings/TTUserSettingsManager+FontSettings.h"
#import "TTActivityShareSequenceManager.h"

#define kCellElementBgColorKey kColorBackground4
#define kToReplyUserNameIndex 2
#define kCommentIndex 3
#define kReplyText NSLocalizedString(@"回复", nil)
#define kColonText @":"

#define kLikeViewBGTopGap                   [TTDeviceUIUtils tt_paddingForMoment:20]
#define kLikeViewFirstAvatarViewLeftPadding [TTDeviceUIUtils tt_paddingForMoment:15]
#define kLikeViewArrowViewRightPadding      [TTDeviceUIUtils tt_paddingForMoment:15]
#define kLikeViewTopMargin                  [TTDeviceUIUtils tt_paddingForMoment:15]
#define kLikeViewBottomMargin               [TTDeviceUIUtils tt_paddingForMoment:15]
#define kLikeViewAvatarViewNormalWidth      36
#define kLikeViewAvatarViewWidth            [TTDeviceUIUtils tt_paddingForMoment:36]
#define kLikeViewAvatarViewHeight           [TTDeviceUIUtils tt_paddingForMoment:36]
#define kLikeViewArrowViewLeftPadding       [TTDeviceUIUtils tt_paddingForMoment:3]
#define kLikeViewAvatarViewGap              [TTDeviceUIUtils tt_paddingForMoment:6]
#define kLikeViewLastAvatarViewRightPadding [TTDeviceUIUtils tt_paddingForMoment:130]

#define kLikeViewShowArrowMinNumber         1
#define kLikeViewBGHeight                   (kLikeViewTopMargin + kLikeViewAvatarViewHeight + kLikeViewBottomMargin)
#define kLikeViewHeight                     kLikeViewBGTopGap + kLikeViewBGHeight
#define kLoadOnceCount 20
#define kPostCommentViewHeight 40

#define kCellAvatarViewNormalSize           36
#define kCellAvatarViewWidth                [TTDeviceUIUtils tt_paddingForMoment:36]
#define kCellAvatarViewHeight               [TTDeviceUIUtils tt_paddingForMoment:36]
#define kCellAvatarViewLeftPadding          [TTDeviceUIUtils tt_paddingForMoment:15]
#define kCellAvatarViewRightPadding         [TTDeviceUIUtils tt_paddingForMoment:9]
#define kCellAvatarViewTopPadding           [TTDeviceUIUtils tt_paddingForMoment:14]
#define kCellNameLabelTopPadding            [TTDeviceUIUtils tt_paddingForMoment:16]
#define kCellNameLabelFontSize              [TTDeviceUIUtils tt_fontSizeForMoment:16]
#define kCellNameLabelBottomPadding         [TTDeviceUIUtils tt_paddingForMoment:6]
#define kCellDescLabelFontSize              [TTDeviceUIUtils tt_fontSizeForMoment:17]
#define kCellTimeLabelFontSize              [TTDeviceUIUtils tt_fontSizeForMoment:12]
#define kCellDescLabelBottomPadding         [TTDeviceUIUtils tt_paddingForMoment:3]
#define kCellBottomPadding                  [TTDeviceUIUtils tt_paddingForMoment:14]
#define kCellRightPadding                   [TTDeviceUIUtils tt_paddingForMoment:15]
#define kUserInfoViewRightPadding           [TTDeviceUIUtils tt_newPadding:45.f]

#define kDigButtonWidth 60
#define kDigButtonHeight 30
#define kDeleteCommentActionSheetTag 10
#define kSectionHeaderHeight                [TTDeviceUIUtils tt_paddingForMoment:40]
#define kDescLineMultiple 0.1f
////////////////////////////////////////////////////////////
#pragma mark - 发评论按钮
NSString *const ArticleMomentDetailViewAddMomentNoti = @"ArticleMomentDetailViewAddMomentNoti";
static CGFloat globalCustomWidth = 0;
extern BOOL ttvs_isShareIndividuatioEnable(void);

CGRect p_splitViewFrameForView(UIView *view);
CGRect p_splitViewFrameForView(UIView *view)
{
    CGRect frame = [TTUIResponderHelper splitViewFrameForView:view];
    if (globalCustomWidth > 0) {
        frame.origin.x = (view.width - globalCustomWidth) / 2;
        frame.size.width = globalCustomWidth;
    }
    return frame;
}

extern CGFloat fr_postCommentButtonHeight(void);

@interface ArticleMomentDetailViewPostCommentButtonView : SSViewBase
@property(nonatomic, strong)UIImageView *iconView;
@property(nonatomic, strong)UIButton * bgButton;
@property(nonatomic, strong)UILabel * titleLabel;
@property(nonatomic, strong)UIView * separatorView;
@end
@implementation ArticleMomentDetailViewPostCommentButtonView
- (void)dealloc
{
    self.iconView = nil;
    self.separatorView = nil;
    self.bgButton = nil;
    self.titleLabel = nil;
}
- (id)initWithWidth:(CGFloat)width
{
    CGRect frame = CGRectMake(0, 0, width, kPostCommentViewHeight);
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(14+32, 0, width - 28 - 32, kPostCommentViewHeight)];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.backgroundColor = [UIColor clearColor];
        [_titleLabel setText:NSLocalizedString(@"写评论", nil)];
        [self addSubview:_titleLabel];
        
        self.bgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _bgButton.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _bgButton.layer.cornerRadius = 2;
        _bgButton.frame = CGRectMake(14, 4, width - 28, kPostCommentViewHeight - 8);
        [self addSubview:_bgButton];
        
        self.iconView = [[UIImageView alloc] initWithImage:[UIImage themedImageNamed:@"writeicon_details_dynamic.png"]];
        _iconView.left = 9;
        _iconView.centerY = _bgButton.height/2;
        [_bgButton addSubview:_iconView];
        
        [self bringSubviewToFront:_titleLabel];
        
        self.separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, [TTDeviceHelper ssOnePixel])];
        [self addSubview:_separatorView];
        
        [self reloadThemeUI];
    }
    return self;
}
- (void)themeChanged:(NSNotification *)notification
{
    self.backgroundColor = [UIColor tt_themedColorForKey:kCellElementBgColorKey];
    _bgButton.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    _bgButton.layer.borderColor = [UIColor tt_themedColorForKey:kColorLine1].CGColor;
    _titleLabel.textColor = [UIColor tt_themedColorForKey:kColorText3];
    _separatorView.backgroundColor = [UIColor tt_themedColorForKey:kColorLine1];
    _iconView.image = [UIImage themedImageNamed:@"writeicon_details_dynamic.png"];
}
@end
////////////////////////////////////////////////////////////
@interface ArticleMomentDetailViewCommentCell()
@property (nonatomic, strong) TTActionSheetController *actionSheetController;
@end
@implementation ArticleMomentDetailViewCommentCell
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.ssDelegate = nil;
    
    self.commentModel = nil;
    self.replyToMomentModel = nil;
    self.nameView = nil;
    self.descLabel = nil;
    self.avatarView = nil;
    self.timeLabel = nil;
    self.separatorLineView = nil;
    self.replyButton = nil;
    self.diggButton = nil;
    
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.needMargin = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontSizeChanged) name:kSettingFontSizeChangedNotification object:nil];
        
        
        self.avatarView = [[ExploreAvatarView alloc] initWithFrame:CGRectMake(kCellAvatarViewLeftPadding, kCellAvatarViewTopPadding, kCellAvatarViewWidth, kCellAvatarViewHeight)];
        
        [self.avatarView setupVerifyViewForLength:kCellAvatarViewNormalSize adaptationSizeBlock:^CGSize(CGSize standardSize) {
            return [TTVerifyIconHelper tt_sizeForMoment:standardSize];
        }];
        
        _avatarView.enableRoundedCorner = YES;
        _avatarView.placeholder = @"big_defaulthead_head";
        [_avatarView addTouchTarget:self action:@selector(avatarButtonClicked)];
        [self.contentView addSubview:_avatarView];
        
        self.descLabel = [[SSAttributeLabel alloc] initWithFrame:CGRectZero supportCopy:NO];
        _descLabel.backgroundColor = [UIColor tt_themedColorForKey:kCellElementBgColorKey];
        _descLabel.clipsToBounds = YES;
        _descLabel.font = [UIFont systemFontOfSize:[ArticleMomentDetailViewCommentCell settedCommentFontSize]];
        _descLabel.numberOfLines = 0;
        _descLabel.lineSpacingMultiple = kDescLineMultiple;
        _descLabel.delegate = self;
        UIGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
        [_descLabel addGestureRecognizer:longPress];
        //        _descLabel.backgroundHighlightColorName = @"ArticleCommentListCellCommentItemLabelBgHighlightColor";
        //        _descLabel.selectTextForegroundColorName = @"ArticleMomentCellNameLabelPressedColor";
        [self.contentView addSubview:_descLabel];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.backgroundColor = [UIColor tt_themedColorForKey:kCellElementBgColorKey];
        _timeLabel.clipsToBounds = YES;
        _timeLabel.font = [UIFont systemFontOfSize:kCellTimeLabelFontSize];
        _timeLabel.numberOfLines = 1;
        [self.contentView addSubview:_timeLabel];
        
        self.separatorLineView = [[UIView alloc] initWithFrame:CGRectZero];
        //        [self.contentView addSubview:_separatorLineView];
        
        self.replyButton = [[SSThemedButton alloc] initWithFrame:CGRectZero];
        self.replyButton.titleLabel.font = [UIFont systemFontOfSize:kCellTimeLabelFontSize];
        [_replyButton addTarget:self action:@selector(replyButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        _replyButton.backgroundColorThemeKey = kCellElementBgColorKey;
        _replyButton.titleColorThemeKey = kColorText13;
        _replyButton.titleLabel.backgroundColor = [UIColor tt_themedColorForKey:kCellElementBgColorKey];
        _replyButton.titleLabel.clipsToBounds = YES;
        [self.contentView addSubview:_replyButton];
        
        self.diggButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.diggButton setTitleEdgeInsets:UIEdgeInsetsMake(1, 0, 0, 0)];
        [self.diggButton setImageEdgeInsets:UIEdgeInsetsMake(0, -[TTDeviceUIUtils tt_newFontSize:3.f], 0, 0)];
        [self.diggButton setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
        if ([TTDeviceHelper OSVersionNumber] < 8.f) {
            _diggButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:[self digButtonFontSize]];
        }
        else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
            _diggButton.titleLabel.font = [UIFont systemFontOfSize:[self digButtonFontSize] weight:UIFontWeightThin];
#pragma clang diagnostic pop
        }
        [_diggButton addTarget:self action:@selector(diggButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        _diggButton.backgroundColor = [UIColor tt_themedColorForKey:kCellElementBgColorKey];
        _diggButton.titleLabel.backgroundColor = [UIColor tt_themedColorForKey:kCellElementBgColorKey];
        _replyButton.titleLabel.clipsToBounds = YES;
        [self addSubview:_diggButton];
        
        [self bringSubviewToFront:_descLabel];
        
        [self themeChanged:nil];
        
    }
    return self;
}

- (CGFloat)digButtonFontSize {
    if ([TTDeviceHelper isPadDevice]) {
        return 15.f;
    } else {
        if (![TTDeviceHelper isScreenWidthLarge320]) {
            return 12.f;
        } else {
            return 13.f;
        }
    }
}

- (void)themeChanged:(NSNotification *)notification
{
    
    _timeLabel.textColor = [UIColor tt_themedColorForKey:kColorText13];
    _descLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
    
    _nameView.backgroundColorThemeName = kCellElementBgColorKey;
    _nameView.titleLabel.backgroundColor = [UIColor tt_themedColorForKey:kCellElementBgColorKey];
    _descLabel.backgroundColor = [UIColor tt_themedColorForKey:kCellElementBgColorKey];
    _timeLabel.backgroundColor = [UIColor tt_themedColorForKey:kCellElementBgColorKey];
    _replyButton.backgroundColorThemeKey = kCellElementBgColorKey;
    _replyButton.titleLabel.backgroundColor = [UIColor tt_themedColorForKey:kCellElementBgColorKey];
    _diggButton.backgroundColor = [UIColor tt_themedColorForKey:kCellElementBgColorKey];
    _diggButton.titleLabel.backgroundColor = [UIColor tt_themedColorForKey:kCellElementBgColorKey];
    
    self.backgroundColor = [UIColor tt_themedColorForKey:kCellElementBgColorKey];
    
    [self refreshDescLabelColor];
    _descLabel.text = [ArticleMomentDetailViewCommentCell descLabelTextForModel:self.commentModel];
    
    [self refreshDigView];
    
    _replyButton.titleColorThemeKey = kColorText13;
}
- (void)fontSizeChanged
{
    _descLabel.font = [UIFont systemFontOfSize:[ArticleMomentDetailViewCommentCell settedCommentFontSize]];
}
#pragma mark - Longpress gesture
- (BOOL)canBecomeFirstResponder {
    return YES;
}
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (@selector(customCopy:) == action || @selector(report:) == action) {
        return YES;
    }
    return [super canPerformAction:action withSender:sender];
}
- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if ([menu isMenuVisible]) {
        [menu setMenuVisible:NO animated:YES];
        return;
    }
    
    [super touchesBegan:touches withEvent:event];
}
- (void)handleLongPress:(UIGestureRecognizer*)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        wrapperTrackEvent(@"update_detail", @"replier_longpress");
        [self becomeFirstResponder];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"复制", nil) action:@selector(customCopy:)];
        UIMenuItem *reportItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"举报", nil) action:@selector(report:)];
        if (copyItem) {
            self.menuItems = menu.menuItems;
            menu.menuItems = @[copyItem, reportItem];
        }
        [menu setTargetRect:self.descLabel.frame inView:self.descLabel.superview];
        [menu setMenuVisible:YES animated:YES];
        [self changeDescLabelBackgroundColor];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideMenu) name:UIMenuControllerWillHideMenuNotification object:nil];
    }
}
- (void)willHideMenu {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
    [self resetDescLabelBackgroundColor];
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    menu.menuItems = self.menuItems;
}
- (void)changeDescLabelBackgroundColor
{
    self.descLabel.backgroundColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"d4d4d4" nightColorName:@"353535"]];
}
- (void)resetDescLabelBackgroundColor
{
    self.descLabel.backgroundColor = self.backgroundColor;
}
- (void)customCopy:(__unused id)sender {
    wrapperTrackEvent(@"update_detail", @"replier_longpress_copy");
    [[UIPasteboard generalPasteboard] setString:self.descLabel.text];
}
- (void)report:(__unused id)sender {
    wrapperTrackEvent(@"update_detail", @"replier_longpress_report");
    self.actionSheetController = [[TTActionSheetController alloc] init];
    [self.actionSheetController insertReportArray:[TTReportManager fetchReportUserOptions]];
    WeakSelf;
    [self.actionSheetController performWithSource:TTActionSheetSourceTypeUser completion:^(NSDictionary * _Nonnull parameters) {
        StrongSelf;
        if (parameters[@"report"]) {
            TTReportUserModel *model = [[TTReportUserModel alloc] init];
            model.userID = self.commentModel.user.ID;
            model.commentID = self.commentModel.ID;
            model.groupID = self.groupModel.groupID;
            [[TTReportManager shareInstance] startReportUserWithType:parameters[@"report"] inputText:parameters[@"criticism"] message:nil source:@(TTReportSourceMomentReply).stringValue userModel:model animated:YES];
        }
    }];
}
- (void)hideMenu {
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if ([menu isMenuVisible]) {
        [menu setMenuVisible:NO animated:YES];
    }
}
#pragma mark - Action
- (void)replyNameButtonClicked
{
    if (_commentModel.replyUser) {
        [ArticleMomentHelper openMomentProfileView:_commentModel.replyUser navigationController:[TTUIResponderHelper topNavigationControllerFor: self] from:kFromFeedDetailComment];
    }
}
- (void)replyButtonClicked{
    if (_ssDelegate && [_ssDelegate respondsToSelector:@selector(commentCell:openComment:)]) {
        [_ssDelegate commentCell:self openComment:_commentModel];
    }
}
- (void)diggButtonClicked {
    if (!_commentModel.userDigged) {
        if (!TTNetworkConnected()) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"没有网络连接" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        } else {
            [SSMotionRender motionInView:_diggButton byType:SSMotionTypeZoomInAndDisappear image:[UIImage themedImageNamed:@"add_all_dynamic.png"] offsetPoint:CGPointMake(-9.f, -4.f)];
            _commentModel.userDigged = YES;
            _commentModel.diggCount += 1;
            _diggButton.imageView.contentMode = UIViewContentModeCenter;
            _diggButton.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
            _diggButton.imageView.alpha = 1.f;
            [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
                _diggButton.imageView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
                _diggButton.imageView.alpha = 0.f;
            } completion:^(BOOL finished){
                [self refreshDigView];
                _diggButton.imageView.alpha = 0.f;
                [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
                    _diggButton.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
                    _diggButton.imageView.alpha = 1.f;
                } completion:^(BOOL finished){
                    
                }];
            }];
            [ArticleMomentCommentManager startDiggCommentWithCommentID:_commentModel.ID withFinishBlock:^(NSError *error) {
                if (error) {
                }
            }];
            //可能显示appStore评分视图
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TTAppStoreStarManagerShowNotice" object:nil userInfo:@{@"trigger":@"like"}];
            
        }
    }
    else if (_commentModel.userDigged) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"您已经赞过", nil) indicatorImage:nil autoDismiss:YES dismissHandler:nil];
    }
    wrapperTrackEvent(@"update_detail", @"replier_digg_click");
    //    wrapperTrackEvent([self umengEventName], @"digg_comment");
}
- (void)refreshDigView
{
    if (_commentModel.userDigged) {
        [_diggButton setImage:[UIImage themedImageNamed:@"comment_like_icon_press.png"] forState:UIControlStateNormal];
        [_diggButton setImage:[UIImage themedImageNamed:@"comment_like_icon_press.png"] forState:UIControlStateHighlighted];
        [_diggButton setTitleColor:SSGetThemedColorWithKey(kColorText4) forState:UIControlStateNormal];
    }
    else {
        [_diggButton setImage:[UIImage themedImageNamed:@"comment_like_icon.png"] forState:UIControlStateNormal];
        [_diggButton setImage:[UIImage themedImageNamed:@"comment_like_icon_press.png"] forState:UIControlStateHighlighted];
        [_diggButton setTitleColor:SSGetThemedColorWithKey(kColorText13) forState:UIControlStateNormal];
    }
    
    [_diggButton setTitle:[NSString stringWithFormat:@"%@", [TTBusinessManager formatCommentCount:_commentModel.diggCount]] forState:UIControlStateNormal];
    [_diggButton sizeToFit];
}
- (void)_settingTimeLabel
{
    NSString *publishTime =  [NSString stringWithFormat:@"%@",self.midInterval > 0 ? [TTBusinessManager customtimeStringSince1970:self.commentModel.createTime midnightInterval:self.midInterval] : [TTBusinessManager customtimeStringSince1970:self.commentModel.createTime]];
    _timeLabel.text = publishTime;
    [_timeLabel sizeToFit];
    _timeLabel.origin = CGPointMake(CGRectGetMinX(_nameView.frame), CGRectGetMaxY(_descLabel.frame) + kCellDescLabelBottomPadding);
}
- (void)_settingReplyButton{
    if ([TTAccountManager isLogin] &&
        [self.commentModel.user.ID longLongValue] != 0 &&
        [TTAccountManager userIDLongInt] == [self.commentModel.user.ID longLongValue]){
        [_replyButton setTitle:NSLocalizedString(@" · 删除", nil) forState:UIControlStateNormal];
    }
    else{
        [_replyButton setTitle:NSLocalizedString(@" · 回复", nil) forState:UIControlStateNormal];
    }
    [_replyButton sizeToFit];
    CGFloat hitTestHeight = _replyButton.height;
    _replyButton.height = _timeLabel.height;
    _replyButton.centerY = _timeLabel.centerY;
    _replyButton.left = _timeLabel.right;
    CGFloat topHitTestEdgeInset = (hitTestHeight - _replyButton.height)/2;
    _replyButton.hitTestEdgeInsets = UIEdgeInsetsMake(-topHitTestEdgeInset, 0, -topHitTestEdgeInset, 0);
}
- (void)_settingDiggButtonFrame
{
    [_diggButton sizeToFit];
    _diggButton.right = self.viewWidth - kCellRightPadding;
    _diggButton.centerY = _nameView.centerY - 2;
}
- (void)_settingNameLabel
{
    NSString *text = self.commentModel.user.name == nil ? @" " : self.commentModel.user.name;
    if (!_nameView) {
        CGFloat originX = _avatarView.right + kCellAvatarViewRightPadding;
        CGFloat maxWidth = self.viewWidth - kCellRightPadding - originX - _diggButton.width - kUserInfoViewRightPadding;
        _nameView = [[TTUserInfoView alloc] initWithBaselineOrigin:CGPointMake(originX, 0) maxWidth:maxWidth limitHeight:21 title:text fontSize:kCellNameLabelFontSize verifiedInfo:self.commentModel.user.verifiedReason verified:NO owner:NO appendLogoInfoArray:self.commentModel.user.authorBadgeList];
        _nameView.textColorThemedKey = kColorText5;
        _nameView.backgroundColorThemeName = kCellElementBgColorKey;
        _nameView.titleLabel.backgroundColor = [UIColor tt_themedColorForKey:kCellElementBgColorKey];
        _nameView.titleLabel.clipsToBounds = YES;
        [self.contentView addSubview:_nameView];
    }
    [_nameView refreshWithTitle:text relation:nil verifiedInfo:self.commentModel.user.verifiedReason verified:NO owner:NO maxWidth:0 appendLogoInfoArray:self.commentModel.user.authorBadgeList];
    __weak typeof(self) wSelf = self;
    [_nameView clickTitleWithAction:^(NSString *title) {
        [wSelf nameButtonClicked];
    }];
    _nameView.top = kCellNameLabelTopPadding;
}
- (void)_settingDescLabel
{
    [self refreshDescLabelColor];
    _descLabel.text = [ArticleMomentDetailViewCommentCell descLabelTextForModel:self.commentModel];
    CGRect descLabelFrame = _descLabel.frame;
    descLabelFrame.origin.x = CGRectGetMinX(_nameView.frame);
    descLabelFrame.origin.y = CGRectGetMaxY(_nameView.frame) + kCellNameLabelBottomPadding;
    descLabelFrame.size.width = [ArticleMomentDetailViewCommentCell widthForDescLabel:self.viewWidth];
    
    if (self.commentModel.descHeight > 0) {
        descLabelFrame.size.height = self.commentModel.descHeight;
    } else {
        descLabelFrame.size.height = [ArticleMomentDetailViewCommentCell heightForDescLabel:_commentModel width:self.viewWidth];
    }
    _descLabel.frame = descLabelFrame;
}
- (void)_settingAvatarView
{
    [_avatarView setImageWithURLString:self.commentModel.user.avatarURLString];
    [_avatarView showOrHideVerifyViewWithVerifyInfo:self.commentModel.user.userAuthInfo decoratorInfo:nil sureQueryWithID:YES userID:nil];

}
- (void)refreshUserModel:(ArticleMomentCommentModel *)commentModel momentModel:(ArticleMomentModel *)momentModel width:(CGFloat)width midnightInterval:(NSTimeInterval)midInterval index:(NSUInteger)index
{
    if (globalCustomWidth) {
        self.needMargin = NO;
        CGRect frame = p_splitViewFrameForView(self);
        self.frame = frame;
        self.contentView.frame = self.bounds;
    } else {
        self.needMargin = YES;
    }
    self.commentModel = commentModel;
    self.replyToMomentModel = momentModel;
    self.viewWidth = width;
    self.midInterval = midInterval;
    [self setNeedsLayout];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.viewWidth = CGRectGetWidth(self.frame);
    [self _settingAvatarView];
    [self refreshDigView];
    [self _settingNameLabel];
    [self _settingDiggButtonFrame];
    [self _settingDescLabel];
    [self _settingTimeLabel];
    [self _settingReplyButton];
}
- (void)refreshDescLabelColor
{
    [ArticleMomentDetailViewCommentCell descLabelTextForModel:_commentModel];
    NSMutableArray * attributeModels = [NSMutableArray arrayWithCapacity:10];
    if (!isEmptyString(_commentModel.replyUser.name)) {
        SSAttributeLabelModel * model = [[SSAttributeLabelModel alloc] init];
        model.linkURLString = [NSString stringWithFormat:@"ArticleMomentDetailView://profile?index=%i", kToReplyUserNameIndex];
        model.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"3c6598" nightColorName:@"67778b"]];
        model.attributeRange = NSMakeRange([kReplyText length], [_commentModel.replyUser.name length]);
        [attributeModels addObject:model];
        
    }
    [_descLabel refreshAttributeModels:attributeModels];
    
    
}
- (NSString *)umengEventName {
    if (_sourceType == ArticleMomentSourceTypeForum) {
        return @"topic_detail";
    } else {
        return @"update_detail";
    }
}
- (void)avatarButtonClicked
{
    [ArticleMomentHelper openMomentProfileView:_commentModel.user navigationController:[TTUIResponderHelper topNavigationControllerFor: self] from:kFromFeedDetailComment];
    wrapperTrackEvent([self umengEventName], @"click_replier_avatar");
}
- (void)nameButtonClicked
{
    [ArticleMomentHelper openMomentProfileView:_commentModel.user navigationController:[TTUIResponderHelper topNavigationControllerFor: self] from:kFromFeedDetailComment];
    wrapperTrackEvent([self umengEventName], @"click_replier_name");
}
- (void)deleteButtonClicked:(id)sender
{
    wrapperTrackEvent(@"update_detail", @"delete");
    if (_ssDelegate && [_ssDelegate respondsToSelector:@selector(commentCell:deleteComment:)]) {
        [_ssDelegate commentCell:self deleteComment:_commentModel];
    }
}
+ (CGFloat)widthForDescLabel:(CGFloat)cellWidth
{
    return cellWidth - kCellAvatarViewLeftPadding - kCellAvatarViewWidth - kCellAvatarViewRightPadding - kCellRightPadding;
}
+ (NSString *)descLabelTextForModel:(ArticleMomentCommentModel *)model
{
    if (isEmptyString(model.replyUser.name)) {
        return model.content;
    }
    else {
        return [NSString stringWithFormat:@"%@%@%@%@", kReplyText,model.replyUser.name,kColonText, model.content];
    }
}
+ (CGFloat)heightForDescLabel:(ArticleMomentCommentModel *)model width:(CGFloat)cellWidth
{
    if (isEmptyString(model.content)) {
        model.content = @" ";
    }
    return [SSAttributeLabel sizeWithText:[self descLabelTextForModel:model] font:[UIFont systemFontOfSize:[self settedCommentFontSize]] constrainedToSize:CGSizeMake([self widthForDescLabel:cellWidth], CGFLOAT_MAX) lineSpacingMultiple:kDescLineMultiple].height;
}
+ (CGFloat)heightForCommentModel:(ArticleMomentCommentModel *)model cellWidth:(CGFloat)width
{
    CGFloat height = kCellNameLabelTopPadding + kCellNameLabelBottomPadding + kCellDescLabelBottomPadding + kCellBottomPadding;
    height += [TTLabelTextHelper heightOfText:NSLocalizedString(@"名字", nil) fontSize:kCellNameLabelFontSize forWidth:100];
    height += [self heightForDescLabel:model width:width];
    height += [TTLabelTextHelper heightOfText:NSLocalizedString(@"2016-04-19", nil) fontSize:kCellTimeLabelFontSize forWidth:100];
    
    height = MAX(height, kCellAvatarViewTopPadding + kCellAvatarViewHeight + kCellDescLabelBottomPadding);
    return height;
}
+ (float)settedCommentFontSize
{
    CGFloat size = [NewsUserSettingManager fontSizeFromNormalSize:17.f isWidescreen:NO];
    return [TTDeviceUIUtils tt_fontSizeForMoment:size];
}
#pragma mark -- SSAttributeLabelModelDelegate
- (void)attributeLabel:(SSAttributeLabel *)label didClickLink:(NSString *)linkURLString
{
    if (isEmptyString(linkURLString)) {
        return;
    }
    NSURL * url = [TTStringHelper URLWithURLString:linkURLString];
    NSDictionary *parameters = [TTStringHelper parametersOfURLString:url.query];
    if([parameters count] > 0)
    {
        int index = [[parameters objectForKey:@"index"] intValue];
        if (index == kToReplyUserNameIndex) {
            if (_commentModel.replyUser) {
                [ArticleMomentHelper openMomentProfileView:_commentModel.replyUser navigationController:[TTUIResponderHelper topNavigationControllerFor: self] from:kFromFeedDetailComment];
                wrapperTrackEvent([self umengEventName], @"click_replier_name");
            }
        }
    }
}
- (void)attributeLabelClickedUntackArea:(SSAttributeLabel *)label
{
    if (label == _descLabel) {
        if (_ssDelegate && [_ssDelegate respondsToSelector:@selector(commentCell:openComment:)]) {
            [_ssDelegate commentCell:self openComment:_commentModel];
        }
    }
}
- (void)setBgViewBgColor:(BOOL)highlighted
{
}
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    [self setBgViewBgColor:highlighted];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self setBgViewBgColor:selected];
}
@end
#pragma mark --
@interface ArticleMomentDetailViewHeaderLikeView : SSViewBase
{
    CGFloat _viewWidth;
}
@property(nonatomic, strong)NSMutableArray * avatars;//avatar and verify icon
@property(nonatomic, strong)UIButton * arrowButton;
@property(nonatomic, strong)SSThemedImageView *arrowImageView;
@property(nonatomic, strong)SSThemedLabel *diggCountLabel;
@property(nonatomic, strong)ArticleMomentModel * momentModel;
@property(nonatomic, strong)UIView * bgView;
@property(nonatomic, strong)SSThemedView *topSepLineView;
@property(nonatomic, strong)SSThemedView *botSepLineView;
@property(nonatomic, assign)ArticleMomentSourceType sourceType;
@property(nonatomic, copy)NSString *mediaId;
@property(nonatomic, copy)NSString *commentId;
@property(nonatomic, copy)NSString *gid;
@end
@implementation ArticleMomentDetailViewHeaderLikeView
- (void)dealloc
{
    self.bgView = nil;
    self.momentModel = nil;
    self.arrowButton = nil;
    self.avatars = nil;
    self.arrowImageView = nil;
    self.diggCountLabel = nil;
    self.topSepLineView = nil;
    self.botSepLineView = nil;
    
}
- (CGRect)_bgViewFrame
{
    return CGRectMake(0, kLikeViewBGTopGap, CGRectGetWidth(self.frame), kLikeViewBGHeight);
}
- (void)_settingArrowButtonFrame
{
    _diggCountLabel.text = [NSString stringWithFormat:@"%d 个人赞过",self.momentModel.diggsCount];
    [_diggCountLabel sizeToFit];
    _arrowImageView.imageName = @"comment_arrow_icon.png";
    [_arrowImageView sizeToFit];
    float buttonWidth = (_diggCountLabel.width) + (_arrowImageView.width) + kLikeViewArrowViewLeftPadding;
    _arrowButton.frame = CGRectMake(0, 0,buttonWidth, kLikeViewBGHeight);
    
    _arrowButton.left = self.width -  buttonWidth - kLikeViewArrowViewRightPadding;
    
    _diggCountLabel.left = 0;
    _diggCountLabel.centerY = _arrowButton.centerY;
    
    _arrowImageView.left = (_arrowButton.width) - (_arrowImageView.width);
    _arrowImageView.centerY = _arrowButton.centerY;
}
- (void)_settingSepLineViewFrame{
    _topSepLineView.frame = CGRectMake(0, 0, self.width, [TTDeviceHelper ssOnePixel]);
    _botSepLineView.frame = CGRectMake(kLikeViewFirstAvatarViewLeftPadding, kLikeViewBGHeight - [TTDeviceHelper ssOnePixel], self.width - kLikeViewFirstAvatarViewLeftPadding - kCellRightPadding, [TTDeviceHelper ssOnePixel]);
}
- (id)initWithWidth:(CGFloat)width
{
    CGRect frame = CGRectMake(0, 0, width, kLikeViewHeight);
    self = [super initWithFrame:frame];
    if (self) {
        _viewWidth = width;
        _bgView = [[UIView alloc] initWithFrame:CGRectZero];
        _bgView.frame = [self _bgViewFrame];;
        [self addSubview:_bgView];
        
        self.avatars = [NSMutableArray arrayWithCapacity:10];
        
        self.arrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _arrowButton.backgroundColor = [UIColor clearColor];
        [_arrowButton addTarget:self action:@selector(arrowButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        
        [_bgView addSubview:_arrowButton];
        
        self.arrowImageView = [[SSThemedImageView alloc] init];
        self.diggCountLabel = [[SSThemedLabel alloc] init];
        _diggCountLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSizeForMoment:13.f]];
        [_arrowButton addSubview:_arrowImageView];
        [_arrowButton addSubview:_diggCountLabel];
        
        self.topSepLineView = [[SSThemedView alloc] init];
        
        self.botSepLineView = [[SSThemedView alloc] init];
        [self.bgView addSubview:_topSepLineView];
        [self.bgView addSubview:_botSepLineView];
        
        [self reloadThemeUI];
    }
    return self;
}
- (void)relayoutWithWidth:(CGFloat)width
{
    CGRect rect = self.frame;
    rect.size.width = width;
    self.frame = rect;
    _bgView.frame = [self _bgViewFrame];
    [self _settingArrowButtonFrame];
    [self _settingSepLineViewFrame];
}
- (void)arrowButtonClicked
{
    ArticleMomentDigUsersViewController * controller = [[ArticleMomentDigUsersViewController alloc] initWithMomentModel:_momentModel];
    controller.mediaId = self.mediaId;
    controller.commentId = self.commentId;
    controller.gid = self.gid;
    controller.momentId = self.momentModel.ID;
    [[TTUIResponderHelper topNavigationControllerFor: self] pushViewController:controller animated:YES];
    wrapperTrackEvent([self umengEventName], @"enter_diggers");
}
- (void)refreshForModels:(ArticleMomentModel *)momentModel
{
    self.momentModel = momentModel;
    //先刷新model再设置arrowButton,因为要根据model里点赞的人数确认arrowButton的frame
    [self _settingArrowButtonFrame];
    for (UIView * view in _avatars) {
        [view removeFromSuperview];
    }
    [_avatars removeAllObjects];
    
    if ([momentModel.diggUsers count] == 0) {
        self.hidden = YES;
        return;
    }
    else {
        self.hidden = NO;
    }
    
    CGFloat originX = kLikeViewFirstAvatarViewLeftPadding - 2;
    int maxAvatarNumber = (int)((self.width  - kLikeViewFirstAvatarViewLeftPadding - kLikeViewLastAvatarViewRightPadding + kLikeViewAvatarViewGap)/(kLikeViewAvatarViewWidth + kLikeViewAvatarViewGap));
    for (int i = 0; i < MIN(maxAvatarNumber, [momentModel.diggUsers count]); i ++) {
        ArticleAvatarView * avatarView = [[ArticleAvatarView alloc] initWithFrame:CGRectMake(originX, kLikeViewTopMargin, kLikeViewAvatarViewWidth, kLikeViewAvatarViewHeight)];
        
        [avatarView setupVerifyViewForLength:kLikeViewAvatarViewNormalWidth adaptationSizeBlock:^CGSize(CGSize standardSize) {
            return [TTVerifyIconHelper tt_sizeForMoment:standardSize];
        }];
        
        avatarView.tag = i;
        avatarView.avatarStyle = SSAvatarViewStyleRound;
        avatarView.avatarImgPadding = 0.f;
        avatarView.backgroundColor = [UIColor tt_themedColorForKey:kCellElementBgColorKey];
        
        [avatarView.avatarButton addTarget:self action:@selector(avatarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [avatarView showAvatarByURL:((SSUserModel *)[momentModel.diggUsers objectAtIndex:i]).avatarURLString];
        [_bgView addSubview:avatarView];
        [_avatars addObject:avatarView];
        NSString *userAuthInfo = ((SSUserModel *)[momentModel.diggUsers objectAtIndex:i]).userAuthInfo;
        [avatarView showOrHideVerifyViewWithVerifyInfo:userAuthInfo decoratorInfo:nil sureQueryWithID:YES userID:nil];
        
        originX += kLikeViewAvatarViewWidth + kLikeViewAvatarViewGap;
    }
    _arrowButton.hidden = !([momentModel.diggUsers count] >= kLikeViewShowArrowMinNumber);
}
- (void)avatarButtonClicked:(UIButton *)sender
{
    if ([sender.superview isKindOfClass:[ArticleAvatarView class]]) {
        if (sender.superview.tag < [_momentModel.diggUsers count]) {
            SSUserModel * model = [_momentModel.diggUsers objectAtIndex:sender.superview.tag];
            [ArticleMomentHelper openMomentProfileView:model navigationController:[TTUIResponderHelper topNavigationControllerFor: self] from:kFromFeedDetailDig];
            wrapperTrackEvent([self umengEventName], @"click_digger");
        }
    }
}
- (void)themeChanged:(NSNotification *)notification
{
    self.diggCountLabel.textColorThemeKey = kColorText13;
    self.topSepLineView.backgroundColorThemeKey = kColorBackground1;
    self.botSepLineView.backgroundColorThemeKey = kColorBackground1;
    self.bgView.backgroundColor = [UIColor tt_themedColorForKey:kCellElementBgColorKey];
    [_avatars enumerateObjectsUsingBlock:^(ArticleAvatarView * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.backgroundColor = [UIColor tt_themedColorForKey:kCellElementBgColorKey];
    }];
}
+ (CGFloat)heightForModel:(ArticleMomentModel *)model width:(CGFloat)width
{
    if ([model.diggUsers count] == 0) {
        return kLikeViewBGTopGap;
    }
    return kLikeViewHeight;
}
- (NSString *)umengEventName {
    if (_sourceType == ArticleMomentSourceTypeForum) {
        return @"topic_detail";
    } else {
        return @"update_detail";
    }
}
@end
////////////////////////////////////////////////////////////
#pragma mark - comment上面的部分
@interface ArticleMomentDetailViewHeader : SSViewBase
@property(nonatomic, strong)ExploreMomentListCellHeaderItem * header;
@property(nonatomic, strong)ArticleMomentDetailViewHeaderLikeView * likeView;
@property(nonatomic, strong)SSThemedView *placeHolder;
@property(nonatomic, assign)ArticleMomentSourceType sourceType;
@property(nonatomic, strong)ArticleMomentModel *momentModel;
@end
@implementation ArticleMomentDetailViewHeader
- (void)dealloc
{
    self.likeView = nil;
    self.header = nil;
}
- (id)initWithFrame:(CGRect)frame sourceType:(ArticleMomentSourceType)sourceType
{
    self = [super initWithFrame:frame];
    if (self) {
        self.sourceType = sourceType;
        NSDictionary * userInfo = @{kMomentListCellItemBaseUserInfoSourceTypeKey:@(sourceType),
                                    kMomentListCellItemBaseIsDetailViewTypeKey:@(YES)};
        self.header = [[ExploreMomentListCellHeaderItem alloc] initWithWidth:self.width userInfo:userInfo];
        [self addSubview:_header];
        
        self.likeView = [[ArticleMomentDetailViewHeaderLikeView alloc] initWithWidth:self.width];
        [self addSubview:_likeView];
        
        self.placeHolder = [[SSThemedView alloc] initWithFrame:CGRectMake(self.header.left, -[TTUIResponderHelper screenSize].height, self.header.width, [TTUIResponderHelper screenSize].height)];
        self.placeHolder.backgroundColorThemeKey = kColorBackground4;
        [self addSubview:self.placeHolder];
        [self reloadThemeUI];
        
    }
    
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self refreshSplitViewFrame];
}
- (void)refreshSplitViewFrame
{
    self.frame = p_splitViewFrameForView(self);
    self.header.cellWidth = CGRectGetWidth(self.frame);
    [self.likeView relayoutWithWidth:CGRectGetWidth(self.frame)];
    self.placeHolder.width = self.header.width;
}
- (void)_refresh
{
    [self refreshSplitViewFrame];
    
    [_header refreshForMomentModel:_momentModel];
    [_likeView refreshForModels:_momentModel];
    
    NSDictionary * userInfo = @{kMomentListCellItemBaseUserInfoSourceTypeKey:@(_sourceType),
                                kMomentListCellItemBaseIsDetailViewTypeKey:@(YES)};
    CGFloat headerHeight = [ExploreMomentListCellHeaderItem heightForMomentModel:_momentModel cellWidth:CGRectGetWidth(self.frame) userInfo:userInfo];
    _header.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), headerHeight);
    _likeView.origin = CGPointMake(0, headerHeight);
}
- (void)refreshModel:(ArticleMomentModel *)model cellWidth:(CGFloat)width midnightInterval:(NSTimeInterval)interval
{
    CGRect rect = self.frame;
    rect.size.width = width;
    self.frame = rect;
    _momentModel = model;
    [self _refresh];
    [self setNeedsLayout];
}
- (void)themeChanged:(NSNotification *)notification
{
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
}
+ (CGFloat)heightForHeader:(ArticleMomentModel *)model cellWidth:(CGFloat)width sourceType:(ArticleMomentSourceType)sourceType
{
    CGFloat height = 0;
    NSDictionary * userInfo = @{kMomentListCellItemBaseUserInfoSourceTypeKey:@(sourceType),
                                kMomentListCellItemBaseIsDetailViewTypeKey:@(YES)};
    height += [ExploreMomentListCellHeaderItem heightForMomentModel:model cellWidth:width userInfo:userInfo];
    height += [ArticleMomentDetailViewHeaderLikeView heightForModel:model width:width];
    return height;
}
- (NSString *)umengEventName {
    if (_sourceType == ArticleMomentSourceTypeForum) {
        return @"topic_detail";
    } else {
        return @"update_detail";
    }
}
@end
#pragma mark - 详情
@interface ArticleMomentDetailView()<UITableViewDelegate , UITableViewDataSource, ArticleComentViewDelegate, ArticleMomentDetailViewCommentCellDelegate, UIActionSheetDelegate, SSActivityViewDelegate>
{
    NSTimeInterval _midnightInterval;
    BOOL _hasMore;
}
@property(nonatomic, assign, readwrite)ArticleMomentSourceType sourceType;
@property(nonatomic, strong)ArticleMomentDetailViewHeader * headerView;
@property(nonatomic, strong)ArticleMomentCommentManager * manager;
@property(nonatomic, strong)ArticleMomentManager * momentManager;
@property (nonatomic, strong)SSNavigationBar    *navigationBar;
@property (nonatomic, strong)ArticleCommentView *commentView;
@property (nonatomic, strong)ArticleMomentCommentModel *needDeleteCommentModel;
@property (nonatomic, strong)SSLoadMoreCell * loadMoreCell;
@property(nonatomic, strong)TTActivityShareManager *activityActionManager;
@property(nonatomic, strong)SSActivityView *phoneShareView;
@property(nonatomic, strong)ArticleMomentCommentModel *replyMomentCommentModel;
@property(nonatomic, assign)BOOL showWriteComment;
@property(nonatomic, strong)FRPostCommonButton *postCommonButton;
@property(nonatomic, assign) BOOL isSelfDeleted; //自己是否被删除
//发表评论前没有登录，登录后发表了，用这个字段标记
@property(nonatomic, assign) NSInteger publishStatusForTrack; //0为初始值，1表示发送了unlog埋点,2表示发送了unlog_done埋点
// 统计用 作者的mediaId，uid
@property(nonatomic, copy)NSString *mediaId;
@property(nonatomic, copy)NSString *commentId;
@property(nonatomic, copy)NSString *gid;
@property(nonatomic, assign)BOOL isViewAppear;
@property(nonatomic, assign)BOOL fromVideoDetail;
@property (nonatomic, strong) Thread *thread;
@property (nonatomic, strong) Thread *originThread;
@property (nonatomic, strong) Article *originArticle;
//@property (nonatomic, assign) TTThreadRepostType repostType;
//@property (nonatomic, assign) TTThreadRepostOriginType repostOriginType;
@end
@implementation ArticleMomentDetailView
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.commentView) {
        self.commentView.delegate = nil;
    }
    self.commentView = nil;
    self.momentManager = nil;
    [self refreshMomentModel:nil];
    self.manager = nil;
    self.headerView = nil;
    self.commentListView = nil;
    self.navigationBar = nil;
    self.needDeleteCommentModel = nil;
    self.loadMoreCell = nil;
    self.postCommonButton = nil;
    self.delegate = nil;
}
- (id)initWithFrame:(CGRect)frame
        momentModel:(ArticleMomentModel *)model
articleMomentManager:(ArticleMomentManager *)manager
         sourceType:(ArticleMomentSourceType)sourceType
replyMomentCommentModel:(ArticleMomentCommentModel *)replyMomentCommentModel
   showWriteComment:(BOOL)show
{
    self = [super initWithFrame:frame];
    if (self) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:model.ID forKey:@"id"];
        
        self.showWriteComment = show;

        if ([TTAccountManager isLogin]) {
             [TTTrackerWrapper category:@"umeng" event:[self umengEventName] label:@"enter" dict:dict];
        }
        else {
            [TTTrackerWrapper category:@"umeng" event:[self umengEventName] label:@"enter_logoff" dict:dict];
        }
        
        self.sourceType = sourceType;
        
        self.replyMomentCommentModel = replyMomentCommentModel;
        
        self.manager = [[ArticleMomentCommentManager alloc] initWithMomentID:model.ID isNewComment:NO isFromeComment:NO];
        
        [self commonInitialization];
        
        [self refreshMomentModel:model];
        [self refreshHeaderView];
        
        [self loadMore];
        
        //强制刷新
        if (manager == nil) {
            self.momentManager = [[ArticleMomentManager alloc] init];
        }
        else {
            self.momentManager = manager;
        }
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent() * 1000.f;
        [_momentManager startGetMomentDetailWithID:_momentModel.ID sourceType:sourceType modifyTime:_momentModel.modifyTime finishBlock:^(ArticleMomentModel *model, NSError *error) {
            CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent() * 1000.f;
            NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
            [extra setValue:error? @(error.code): nil forKey:@"err_code"];
            [extra setValue:error.localizedFailureReason forKey:@"err_reason"];
            [extra setValue:model.ID forKey:@"moment_id"];
            if (!error) {
                [self refreshMomentModel:model];
                [self refreshHeaderView];
                [self notifyDeleteIfNeed];
                [self refreshBottomSendMomentButtonTitle];
                [self refreshDiggButtonStatus];
                [[TTMonitor shareManager] trackService:@"momentdetail_detail_finish_load" value:@(endTime - startTime) extra:extra];
                [[TTMonitor shareManager] trackService:@"momentdetail_detail_status" status:0 extra:extra];
            } else {
                [[TTMonitor shareManager] trackService:@"momentdetail_detail_status" status:1 extra:extra];
                NSDictionary *info = [error.userInfo valueForKey:@"tips"];
                if ([info isKindOfClass:[NSDictionary class]]) {
                    NSString *tip = [info stringValueForKey:@"display_info" defaultValue:@""];
                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tip indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:^(BOOL isUserDismiss) {
                        if (self.fromVideoDetail) {
                            [self backButtonClicked];
                        }
                    }];
                }
            }
        }];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
        momentModel:(ArticleMomentModel *)model
articleMomentManager:(ArticleMomentManager *)manager
         sourceType:(ArticleMomentSourceType)sourceType
{
    return [self initWithFrame:frame momentModel:model articleMomentManager:manager sourceType:sourceType replyMomentCommentModel:nil showWriteComment:NO];
}
- (id)initWithFrame:(CGRect)frame commentId:(int64_t)commentId momentModel:(ArticleMomentModel *)momentModel delegate:(id<ExploreMomentListCellUserActionItemDelegate>)delegate showWriteComment:(BOOL)show
{
    return [self initWithFrame:frame commentId:commentId momentModel:momentModel delegate:delegate showWriteComment:show fromVideoDetail:NO];
}
- (id)initWithFrame:(CGRect)frame commentId:(int64_t)commentId momentModel:(ArticleMomentModel *)momentModel delegate:(id<ExploreMomentListCellUserActionItemDelegate>)delegate showWriteComment:(BOOL)show fromVideoDetail:(BOOL)fromVideoDetail
{
    self = [super initWithFrame:frame];
    if (self) {
        self.mediaId = momentModel.mediaId;
        self.commentId = [NSString stringWithFormat:@"%lld", commentId];
        self.gid = momentModel.gid;
        
        self.sourceType = ArticleMomentSourceTypeArticleDetail;
        self.showWriteComment = show;
        self.fromVideoDetail = fromVideoDetail;
        [self commonInitialization];
        
        //preload
        [self loadHeaderViewForMomentModel:momentModel delegate:delegate];
        
        if (!isEmptyString(momentModel.ID)) {
            self.manager = [[ArticleMomentCommentManager alloc] initWithMomentID:momentModel.ID isNewComment:NO isFromeComment:NO];
        }
        
        //update
        self.momentManager = [[ArticleMomentManager alloc] init];
        [_momentManager startGetMomentDetailWithID: @(commentId).stringValue
                                        sourceType:ArticleMomentSourceTypeArticleDetail
                                        modifyTime:0
                                       finishBlock:^(ArticleMomentModel *model, NSError *error) {
                                           if (!error && model) {
                                               [self refreshMomentDetailViewWithModel:model delegate:delegate];
                                               [self refreshDiggButtonStatus];
                                               [self showWriteCommentIfNeed];
                                               
                                               if (self.updateMomentCountBlock && model.commentsCount) {
                                                   self.updateMomentCountBlock(model.commentsCount, 0);
                                               }
                                               
                                               [[NSNotificationCenter defaultCenter] postNotificationName:ArticleMomentDetailViewAddMomentNoti object:nil userInfo:@{@"count":@(model.commentsCount)}];
//                                               [self requestThreadDetailInfoIfNeed];
                                           } else {
                                               [self.loadMoreCell stopAnimating];
                                               _hasMore = NO;
                                               [self.loadMoreCell hiddenLabel:YES];
                                               [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"加载失败", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                                           }
                                       }];
    }
    return self;
}
//- (void)requestThreadDetailInfoIfNeed {
//    if (self.momentModel.itemType == MomentItemTypeArticle && self.momentModel.group.groupType == ArticleMomentGroupThread) {
//        int64_t userID = [TTAccountManager userIDLongInt];
//        WeakSelf;
//        if ([self.momentModel.group.itemID longLongValue] <= 0) {
//            return;
//        }
//
//        [FRThreadSmartDetailManager requestDetailInfoWithThreadID:[self.momentModel.group.itemID longLongValue] userID:userID callback:^(NSError * _Nullable error, NSObject<TTResponseModelProtocol> * _Nullable responseModel, FRForumMonitorModel *_Nullable monitorModel) {
//            if ([responseModel isKindOfClass:[FRUgcThreadDetailV2InfoResponseModel class]]) {
//                StrongSelf;
//                FRUgcThreadDetailV2InfoResponseModel * response = (FRUgcThreadDetailV2InfoResponseModel *)responseModel;
//                self.thread = [Thread generateThreadWithModel:response.thread];
//                self.thread.contentRichSpanJSONString = response.content_rich_span;
//                [self.thread save];
//                self.repostType = [response.repost_type integerValue];
//                self.repostOriginType = TTThreadRepostOriginTypeNone;
//                if (response.origin_group) {
//                    self.repostOriginType = TTThreadRepostOriginTypeArticle;
//                    NSString *primaryID = [Article primaryIDByUniqueID:[response.origin_group.group_id longLongValue] itemID:[response.origin_group.item_id stringValue] adID:nil];
//                    Article *originArticle = [Article updateWithDictionary:[response.origin_group toDictionary] forPrimaryKey:primaryID];
//                    originArticle.itemID = [response.origin_group.item_id stringValue];
//                    [originArticle save];
//                    self.originArticle = originArticle;
//                }
//                if (response.origin_thread) {
//                    self.repostOriginType = TTThreadRepostOriginTypeThread;//,原来写的是双==直接给他改了，感觉没问题
//                    NSString *originThreadId = [response.origin_thread.thread_id stringValue];
//                    //被转发原贴要传转发贴的primaryID
//                    Thread *originThread = [Thread updateWithDictionary:[response.origin_thread toDictionary] threadId:originThreadId parentPrimaryKey:self.thread.threadPrimaryID];
//                    self.originThread = originThread;
//                }
//            }
//        }];
//    }
//}
- (void)didAppear
{
    [super didAppear];
    _isViewAppear = YES;
    [self performSelector:@selector(markShowCommentViewTimeout) withObject:nil afterDelay:0.4];
    [self showWriteCommentIfNeed];
}
- (void)willDisappear{
    [super willDisappear];
    _isViewAppear = NO;
    
    //如果已经被删除 return @zengruihuan
    if (self.isSelfDeleted) {
        return;
    }
    
    [ArticleMomentManager postSyncNotificationWithMoment:self.momentModel commentCount:@([[self.manager comments] count] + [[self.manager hotComments] count])];
    if ([self.delegate respondsToSelector:@selector(didDigMoment:)]) {
        [self.delegate didDigMoment:self.momentModel];
    }
}
- (void)markShowCommentViewTimeout {
    _showWriteComment = NO;
    _showComment = NO;
}
- (void)refreshDiggButtonStatus{
    [_postCommonButton.diggButton setSelected:_momentModel.digged];
}
- (void)showWriteCommentIfNeed {
    if (_showWriteComment && !isEmptyString(self.momentModel.ID) && _isViewAppear) {
        _showWriteComment = NO;
        [self commentButtonClicked:_postCommonButton.button];
    }
}
- (void)scrollCommentIfNeed {
    if (_showComment&& !isEmptyString(self.momentModel.ID) && _isViewAppear){
        _showComment = NO;
        
        WeakSelf;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            StrongSelf;
            UITableView *commentView = self.commentListView;
            
            CGFloat scrollThrougthContentOffset = MIN(commentView.contentSize.height - commentView.height + commentView.contentInset.bottom, commentView.tableHeaderView.height - commentView.contentInset.top);
            if (scrollThrougthContentOffset > 0) {
                [commentView setContentOffset:CGPointMake(0, scrollThrougthContentOffset) animated:YES];
            }
        });
    }
}
- (void)refreshBottomSendMomentButtonTitle
{
    NSString * title = nil;
    if (self.replyMomentCommentModel) {
        title = [NSString stringWithFormat:@"回复 %@:", self.replyMomentCommentModel.user.name];
    } else {
        title = [SSCommonLogic exploreDetailToolBarWriteCommentPlaceholderText];
    }
    
    [self.postCommonButton setPlaceholderContent:title];
}
- (void)commonInitialization
{
    _hasMore = YES;
    UITableViewStyle style = _fromVideoDetail ? UITableViewStyleGrouped : UITableViewStylePlain;
    self.commentListView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationBar.frame), self.frame.size.width, self.frame.size.height - CGRectGetMaxY(self.navigationBar.frame)) style:style];
    self.commentListView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if (@available(iOS 11.0, *)) {
        self.commentListView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _commentListView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _commentListView.delegate = self;
    _commentListView.dataSource = self;
    _commentListView.contentInset = UIEdgeInsetsMake(0, 0, kPostCommentViewHeight, 0);
    _commentListView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, kPostCommentViewHeight, 0);
    [self addSubview:_commentListView];
    
    NSString * title = nil;;
    if (self.replyMomentCommentModel) {
        title = [NSString stringWithFormat:@"回复 %@...", self.replyMomentCommentModel.user.name];
    } else {
        title = [SSCommonLogic exploreDetailToolBarWriteCommentPlaceholderText];
    }
    
    
    // post common button
    __weak typeof(self) weakSelf = self;
    self.postCommonButton = [[FRPostCommonButton alloc] initWithFrame:CGRectMake(0, (self.height) - fr_postCommentButtonHeight(), self.width, fr_postCommentButtonHeight())];
    _postCommonButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [_postCommonButton setPlaceholderContent:NSLocalizedString(@"写评论...", nil)];
    _postCommonButton.postCommentButtonClick = ^(){
        [weakSelf commentButtonClicked:weakSelf.postCommonButton.button];
    };
    // 动态不支持表情回复
    _postCommonButton.emojiButton.hidden = YES;
    _postCommonButton.emojiButton.enabled = NO;
    _postCommonButton.diggButtonClick = ^(){
        [weakSelf commentDiggButtonClicked];
    };
    _postCommonButton.shareButtonClick = ^(){
        [weakSelf shareButtonPressed];
    };
    
    [self addSubview:_postCommonButton];
    
    [self reloadThemeUI];
    
    if (!TTNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"没有网络连接", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontSizeChanged:) name:kSettingFontSizeChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMomentCommentNeedDeleteNotification:) name:kDeleteMomentCommentNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDeleteMomentNotification:) name:kDeleteMomentNotificationKey object:nil];
}
- (ExploreMomentListCellHeaderItem *)getDetailViewHeaderItem
{
    return self.headerView.header;
}
- (void)receiveMomentCommentNeedDeleteNotification:(NSNotification *)notification
{
    NSNumber * cid = [[notification userInfo] objectForKey:@"cid"];
    NSNumber * mid = [[notification userInfo] objectForKey:@"mid"];
    if ( [mid longLongValue] == 0 || [cid longLongValue] == 0 || [mid longLongValue] != [self.momentModel.ID longLongValue]) {
        return;
    }
    ArticleMomentCommentModel * model = [_manager commentModelForID:[NSString stringWithFormat:@"%@", cid]];
    if (model) {
        [_manager deleteComment:model];
        [_commentListView reloadData];
    }
}
- (void)fontSizeChanged:(NSNotification *)notification
{
    [self refreshHeaderView];
    [self.commentListView reloadData];
}
- (void)notifyDeleteIfNeed
{
    if (_momentModel.isDeleted && _momentModel.ID) {
        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:_momentModel.ID, @"momentID", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kMomentDidDeleteNotification object:nil userInfo:userInfo];
    }
}
- (void)receiveDeleteMomentNotification:(NSNotification *)notification
{
    long long momengID = [[[notification userInfo] objectForKey:@"id"] longLongValue];
    if (momengID == 0) {
        return;
    }
    
    //只有评论浮层会赋值该block
    if (self.dismissBlock && momengID == [_momentModel.ID longLongValue]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kDeleteMomentNotificationKey object:nil];
        self.dismissBlock();
        return;
    }
    UINavigationController *navController = [TTUIResponderHelper topNavigationControllerFor: self];
    if (navController.topViewController == self.viewController) {
        if (momengID == [_momentModel.ID longLongValue]) {
            self.isSelfDeleted = YES;
            // 避免收到多个通知
            [[NSNotificationCenter defaultCenter] removeObserver:self name:kDeleteMomentNotificationKey object:nil];
            
            //            [[NSNotificationCenter defaultCenter] postNotificationName:kDeleteCommentNotificationKey object:self userInfo:nil];
            [self backButtonClicked];
        }
    }
}
- (void)refreshMomentModel:(ArticleMomentModel *)model
{
    if (_momentModel != model) {
        [_momentModel removeObserver:self forKeyPath:@"diggUsers"];
        [_momentModel removeObserver:self forKeyPath:@"commentsCount"];
        
        model.digged = _momentModel.digged || model.digged;
        model.diggsCount = MAX(_momentModel.diggsCount, model.diggsCount);
        
        self.momentModel = model;
        if (!isEmptyString(model.group.ID) && self.commentView.extraTrackDict && ![self.commentView.extraTrackDict objectForKey:@"value"]) {
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithDictionary:self.commentView.extraTrackDict];
            [extraDict setValue:model.group.ID forKey:@"value"];
            self.commentView.extraTrackDict = extraDict;
        }
        
        [_momentModel addObserver:self forKeyPath:@"diggUsers" options:NSKeyValueObservingOptionNew context:nil];
        [_momentModel addObserver:self forKeyPath:@"commentsCount" options:NSKeyValueObservingOptionNew context:nil];
    }
}
- (void)refreshMomentDetailViewWithModel:(ArticleMomentModel *)model delegate:(id<ExploreMomentListCellUserActionItemDelegate>)delegate
{
    if (!self.manager) {
        self.manager = [[ArticleMomentCommentManager alloc] initWithMomentID:model.ID isNewComment:NO isFromeComment:NO];
    }
    [self loadHeaderViewForMomentModel:model delegate:delegate];
    [self notifyDeleteIfNeed];
    [self loadMore];
}
- (void)loadHeaderViewForMomentModel:(ArticleMomentModel *)model delegate:(id<ExploreMomentListCellUserActionItemDelegate>)delegate
{
    [self refreshMomentModel:model];
    [self refreshHeaderView];
    self.headerView.header.actionItemView.delegate = delegate;
    self.delegate = delegate;
}
- (CGRect)_headerViewFrame
{
    return CGRectMake(0, CGRectGetMaxY(self.navigationBar.frame), self.frame.size.width, [self _headerViewHeight]);
}
- (CGFloat)_headerViewHeight
{
    return [ArticleMomentDetailViewHeader heightForHeader:_momentModel cellWidth:p_splitViewFrameForView(self).size.width sourceType:_sourceType];
}
- (void)refreshHeaderView
{
    if (_fromVideoDetail) {
        return;
    }
    if (!_headerView) {
        
        self.headerView = [[ArticleMomentDetailViewHeader alloc] initWithFrame: [self _headerViewFrame] sourceType:_sourceType];
        self.headerView.sourceType = self.sourceType;
        self.headerView.likeView.commentId = self.commentId;
        self.headerView.likeView.gid = self.gid;
        self.headerView.likeView.mediaId = self.mediaId;
        NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit fromDate:[NSDate date]];
        [comp setHour:0];
        [comp setMinute:0];
        [comp setSecond:0];
        _midnightInterval = [[[NSCalendar currentCalendar] dateFromComponents:comp] timeIntervalSince1970];
    }
    else {
        _headerView.frame = [self _headerViewFrame];
    }
    
    [_headerView refreshModel:_momentModel cellWidth:self.frame.size.width midnightInterval:_midnightInterval];
    
    [_headerView.header.actionItemView.commentButton addTarget:self action:@selector(commentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_headerView.header.userInfoItemView.diggButton addTarget:self action:@selector(userInfoDiggButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    //    [_headerView.header.userInfoItemView.diggButton setDiggCount:self.momentModel.diggsCount];
    //    [_headerView.header.userInfoItemView.diggButton sizeToFit];
    UIButton *forwardButton = _headerView.header.actionItemView.forwardButton;
    [forwardButton addTarget:self
                      action:@selector(shareButtonPressed)
            forControlEvents:UIControlEventTouchUpInside];
    
    _commentListView.tableHeaderView = _headerView;
    
    if (isEmptyString(_momentModel.user.name) && isEmptyString(_momentModel.user.avatarURLString) && isEmptyString(_momentModel.group.title)) {
        _headerView.hidden = YES;
    }
    else {
        _headerView.hidden = NO;
    }
    
}
- (void)reloadListViewData
{
    [self reloadThemeUI];
    [_commentListView reloadData];
}
- (void)reloadArticleCommentListIfNeeded
{
    UIResponder *needResponder = [self _needResponder];
    if ([needResponder respondsToSelector:NSSelectorFromString(@"commentManager")]) {
        SSCommentManager *commentManager = [needResponder valueForKey:@"commentManager"];
        [commentManager reloadCommentWithTagIndex:commentManager.curTabIndex];
    }
}
- (void)loadMore
{
    if (![self.loadMoreCell isAnimating]) {
        [self.loadMoreCell startAnimating];
        [self.loadMoreCell hiddenLabel:YES];
    }
    
    __weak typeof(self) weakSelf = self;
    if (self.manager.comments.count){
        wrapperTrackEvent(@"update_detail", @"replier_loadmore");
    }
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent() * 1000.f;
    [_manager startLoadMoreCommentWithCount:kLoadOnceCount width:p_splitViewFrameForView(self).size.width finishBlock:^(NSArray *result, NSArray *hotComments,BOOL hasMore, int totalCount, NSError *error) {
        CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent() * 1000.f;
        NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
        [extra setValue:error? @(error.code): nil forKey:@"err_code"];
        [extra setValue:error.localizedFailureReason forKey:@"err_reason"];
        [extra setValue:weakSelf.manager.momentID forKey:@"moment_id"];
        if (error) {
            [[TTMonitor shareManager] trackService:@"momentdetail_comment_status" status:1 extra:extra];
        } else {
            [[TTMonitor shareManager] trackService:@"momentdetail_comment_finish_load" value:@(endTime - startTime) extra:extra];
            [[TTMonitor shareManager] trackService:@"momentdetail_comment_status" status:0 extra:extra];
        }
        
        [self.loadMoreCell stopAnimating];
        [self.loadMoreCell hiddenLabel:NO];
        _hasMore = hasMore;
        if (!error) {
            [weakSelf reloadListViewData];
            [self scrollCommentIfNeed];
        }
    }];
    
    if (_manager.hotComments.count + _manager.comments.count > 0) {
        wrapperTrackEvent(@"profile", @"more_comment");
    }
}
- (void)themeChanged:(NSNotification *)notification
{
    //    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    //    NSUInteger commentCount = self.momentModel.commentsCount;
    //    if([self.momentModel.diggUsers count] > 0 || commentCount > 0){
    _commentListView.backgroundColor = [UIColor tt_themedColorForKey:kCellElementBgColorKey];
    //    }
    //    else{
    //        _commentListView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    //    }
}
- (void)layoutSubviews {
    [super layoutSubviews];
    if ([TTDeviceHelper isPadDevice])
    {
        [_commentListView reloadData];
        [self refreshHeaderView];
        [self.postCommonButton setNeedsLayout];
    }
}
- (void)backButtonClicked
{
    [[TTUIResponderHelper topNavigationControllerFor: self] popViewControllerAnimated:YES];
}
- (void)forwardButtonClicked
{
    if ([TTAccountManager isLogin]) {
        [self openForwardView];
    }
    else {
        [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypeDefault source:@"social_item_share" completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
            if(type == TTAccountAlertCompletionEventTypeDone) {
                if ([TTAccountManager isLogin]) {
                    [self openForwardView];
                }
            }
            else if (type == TTAccountAlertCompletionEventTypeTip) {
                [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:self] type:TTAccountLoginDialogTitleTypeDefault source:@"social_item_share" completion:^(TTAccountLoginState state) {

                }];
            }
        }];
    }
}
//- (void)forwardToWeitoutiao {
//
//    //    能走到这里的只有
//    //    动态详情页中“文章的评论”/旧版文章评论详情页/帖子评论详情页的转发
//
//    if (self.momentModel.itemType == MomentItemTypeArticle) { //MomentItemTypeArticle代表的是“评论”
//        if (self.momentModel.group.groupType == ArticleMomentGroupArticle) { //评论的内容是文章，则实际转发的内容为文章，操作的对象为评论
//            TTRepostOriginArticle *originArticle = [[TTRepostOriginArticle alloc] init];
//            originArticle.groupID = self.momentModel.group.ID;
//            originArticle.itemID = self.momentModel.group.itemID;
//            originArticle.title = self.momentModel.group.title;
//            originArticle.isVideo = (self.momentModel.group.mediaType == ArticleWithVideo);
//            if (!isEmptyString(self.momentModel.group.thumbnailURLString)) {
//                originArticle.thumbImage = [[FRImageInfoModel alloc] initWithURL:self.momentModel.group.thumbnailURLString];;
//            }
//            TTRepostContentSegment *segment = [[TTRepostContentSegment alloc] initWithText:self.momentModel.content userID:self.momentModel.user.ID username:self.momentModel.user.name];
//            NSArray *segments = [[NSArray alloc] initWithObjects:segment, nil];
//            [TTRepostViewController presentRepostToWeitoutiaoViewControllerWithRepostType:TTThreadRepostTypeArticle
//                                                                            originArticle:originArticle
//                                                                             originThread:nil
//                                                                         originShortVideoOriginalData:nil
//                                                                        operationItemType:TTRepostOperationItemTypeComment
//                                                                          operationItemID:self.momentModel.commentID
//                                                                           repostSegments:segments];
//        }
//        else if (self.momentModel.group.groupType == ArticleMomentGroupThread) { //评论的内容是帖子
//            if (self.thread) {
//                if (self.repostOriginType == TTThreadRepostOriginTypeNone) { //被评论的是一个普通帖子，则转发这个帖子，拼接评论，操作的对象为评论
//                    TTRepostOriginThread *originThread = [[TTRepostOriginThread alloc] init];
//                    originThread.threadID = self.thread.threadId ;
//                    originThread.content = self.thread.content;
//                    originThread.title = self.thread.title;
//                    if ([[self.thread getThumbImageModels] count] > 0) {
//                        originThread.thumbImage = [[self.thread getThumbImageModels] firstObject];
//                    }
//                    originThread.userID = [self.thread userID];
//                    originThread.userName = [self.thread screenName];
//                    originThread.userAvatar = [self.thread avatarURL];
//                    originThread.isDeleted = self.thread.actionDataModel.hasDelete;
//                    TTRepostContentSegment *segment = [[TTRepostContentSegment alloc] initWithText:self.momentModel.content userID:self.momentModel.user.ID username:self.momentModel.user.screen_name];
//                    NSArray *segments = [[NSArray alloc] initWithObjects:segment, nil];
//                    [TTRepostViewController presentRepostToWeitoutiaoViewControllerWithRepostType:TTThreadRepostTypeThread
//                                                                                    originArticle:nil
//                                                                                     originThread:originThread
//                                                                                 originShortVideoOriginalData:nil
//                                                                                operationItemType:TTRepostOperationItemTypeComment
//                                                                                  operationItemID:self.momentModel.commentID
//                                                                                   repostSegments:segments];
//                }
//                else if (self.repostOriginType  == TTThreadRepostOriginTypeThread) { //被评论的帖子有原帖，则转发原帖，拼接评论，拼接被转发帖子内容
//                    TTRepostOriginThread *originThread = [[TTRepostOriginThread alloc] initWithThread:self.originThread];
//                    TTRepostContentSegment *segmentThread = [[TTRepostContentSegment alloc] initWithRichSpanText:[[TTRichSpanText alloc] initWithText:self.thread.content richSpans:[TTRichSpans richSpansForJSONString:self.thread.contentRichSpanJSONString]] userID:[self.thread userID] username:[self.thread screenName]];
//                    TTRepostContentSegment *segmentComment = [[TTRepostContentSegment alloc] initWithText:self.momentModel.content userID:self.momentModel.user.ID username:self.momentModel.user.screen_name];
//                    NSArray *segments = [[NSArray alloc] initWithObjects:segmentComment, segmentThread, nil];
//                    [TTRepostViewController presentRepostToWeitoutiaoViewControllerWithRepostType:TTThreadRepostTypeThread
//                                                                                    originArticle:nil
//                                                                                     originThread:originThread
//                                                                                 originShortVideoOriginalData:nil
//                                                                                operationItemType:TTRepostOperationItemTypeComment
//                                                                                  operationItemID:self.momentModel.commentID
//                                                                                   repostSegments:segments];
//                }
//                else if (self.repostOriginType  == TTThreadRepostOriginTypeArticle) { //被评论的帖子有原文，则转发原文，拼接评论，拼接被转发帖子内容，操作的对象为评论
//                    TTRepostOriginArticle *originArticle = [[TTRepostOriginArticle alloc] initWithArticle:self.originArticle];
//                    TTRepostContentSegment *segmentThread = [[TTRepostContentSegment alloc] initWithRichSpanText:[[TTRichSpanText alloc] initWithText:self.thread.content richSpans:[TTRichSpans richSpansForJSONString:self.thread.contentRichSpanJSONString]] userID:[self.thread userID] username:[self.thread screenName]];
//                    TTRepostContentSegment *segmentComment = [[TTRepostContentSegment alloc] initWithText:self.momentModel.content userID:self.momentModel.user.ID username:self.momentModel.user.screen_name];
//                    NSArray *segments = [[NSArray alloc] initWithObjects:segmentComment, segmentThread, nil];
//                    [TTRepostViewController presentRepostToWeitoutiaoViewControllerWithRepostType:TTThreadRepostTypeArticle
//                                                                                    originArticle:originArticle
//                                                                                     originThread:nil
//                                                                                 originShortVideoOriginalData:nil
//                                                                                operationItemType:TTRepostOperationItemTypeComment
//                                                                                  operationItemID:self.momentModel.commentID
//                                                                                   repostSegments:segments];
//                }
//            }
//        }
//    }
//}

- (void)openForwardView
{
    wrapperTrackEvent(self.headerView.header.detailUmengEventName, @"repost");
    ArticleForwardSourceType sourceType = ArticleForwardSourceTypeOther;
    switch (self.sourceType) {
        case ArticleMomentSourceTypeMoment:
            sourceType = ArticleForwardSourceTypeMoment;
            break;
        case ArticleMomentSourceTypeProfile:
            sourceType = ArticleForwardSourceTypeProfile;
            break;
        case ArticleMomentSourceTypeForum:
            sourceType = ArticleForwardSourceTypeTopic;
            break;
        case ArticleMomentSourceTypeMessage:
            sourceType = ArticleForwardSourceTypeNotify;
            break;
        default:
            break;
    }
    ArticleForwardViewController * forwardController = [[ArticleForwardViewController alloc] initWithMomentModel:self.momentModel];
    forwardController.sourceType = sourceType;
    
    TTNavigationController * nav = [[TTNavigationController alloc] initWithRootViewController:forwardController];
    nav.ttDefaultNavBarStyle = @"White";
    
    [[TTUIResponderHelper topNavigationControllerFor: self] presentViewController:nav animated:YES completion:nil];
}
+ (void)configGlobalCustomWidth:(CGFloat)width
{
    globalCustomWidth = width;
}
- (void)insertLocalMomentCommentModel:(ArticleMomentCommentModel *)model
{
    [self.manager insertComment:model];
    [self.commentListView reloadData];
}
#pragma mark -- UITableViewDelegate , UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger hotComCnt = [_manager hotComments].count;
    NSUInteger comCnt = [_manager comments].count;
    if (section == 0) {
        return hotComCnt;
    } else {
        return comCnt + (_hasMore ? 1 : 0);
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        if ([_manager hotComments].count == 0) {
            return 0.01;
        }
    } else {
        if ([_manager comments].count == 0) {
            return 0.01;
        }
    }
    return kSectionHeaderHeight;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        if ([_manager hotComments].count == 0) {
            return nil;
        }
    } else {
        if ([_manager comments].count == 0) {
            return nil;
        }
    }
    UIView *wrapperView = [[UIView alloc] initWithFrame:CGRectMake(p_splitViewFrameForView(self).origin.x, 0, p_splitViewFrameForView(self).size.width, kSectionHeaderHeight)];
    SSThemedView *view = [[SSThemedView alloc] initWithFrame:CGRectMake(p_splitViewFrameForView(self).origin.x, 0, p_splitViewFrameForView(self).size.width, kSectionHeaderHeight)];
    [wrapperView addSubview:view];
    
    view.backgroundColorThemeKey = kCellElementBgColorKey;
    SSThemedLabel *titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColorThemeKey = kCellElementBgColorKey;
    titleLabel.textColorThemeKey = kColorText1;
    titleLabel.verticalAlignment = ArticleVerticalAlignmentMiddle;
    titleLabel.clipsToBounds = YES;
    
    titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSizeForMoment:16.f]];
    [wrapperView addSubview:titleLabel];
    if (section == 0) {
        titleLabel.text = NSLocalizedString(@"热门评论", nil);
    } else {
        titleLabel.text = NSLocalizedString(@"全部评论", nil);
    }
    [titleLabel sizeToFit];
    titleLabel.origin = CGPointMake(kCellAvatarViewLeftPadding + p_splitViewFrameForView(self).origin.x, [TTDeviceUIUtils tt_paddingForMoment:12.f]);
    return wrapperView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if (indexPath.section == 0) {
        if ([_manager hotComments].count > 0) {
            ArticleMomentCommentModel * model = [[_manager hotComments] objectAtIndex:indexPath.row];
            
            if (model.height > 0) {
                return model.height;
            } else {
                return [ArticleMomentDetailViewCommentCell heightForCommentModel:model cellWidth:p_splitViewFrameForView(self).size.width];
            }
        } else {
            return 0;
        }
    } else {
        NSUInteger comCnt = [[_manager comments] count];
        if (comCnt == 0 && !_hasMore) {
            return 0;
        }
        else if (indexPath.row < comCnt) {
            ArticleMomentCommentModel * model = [[_manager comments] objectAtIndex:indexPath.row];
            if (model.height > 0) {
                return model.height;
            } else {
                return [ArticleMomentDetailViewCommentCell heightForCommentModel:model cellWidth:p_splitViewFrameForView(self).size.width];
            }
        }
        else {
            return kLoadMoreCellHeight;
        }
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"cellIdentifier";
    static NSString * loadMoreCellIdentifier = @"loadMoreCellIdentifier";
    if ((indexPath.section == 0 && indexPath.row < [[_manager hotComments] count]) ||
        (indexPath.section == 1 && indexPath.row < [[_manager comments] count]))
    {
        ArticleMomentCommentModel * model = nil;
        if (indexPath.section == 0) {
            model = [[_manager hotComments] objectAtIndex:indexPath.row];
        }
        else if (indexPath.section == 1) {
            model = [[_manager comments] objectAtIndex:indexPath.row];
        }
        
        ArticleMomentDetailViewCommentCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[ArticleMomentDetailViewCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.sourceType = self.sourceType;
        cell.ssDelegate = self;
        cell.groupModel = self.groupModel;
        [cell refreshUserModel:model momentModel:self.momentModel width:p_splitViewFrameForView(self).size.width midnightInterval:_midnightInterval index:indexPath.row];
        cell.backgroundColorThemeKey = kColorBackground4;
        return cell;
    }
    else
    {
        
        if (!self.loadMoreCell)
        {
            self.loadMoreCell = [[SSLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadMoreCellIdentifier];
            self.loadMoreCell.labelStyle = SSLoadMoreCellLabelStyleAlignMiddle;
            [self.loadMoreCell addMoreLabel];
            self.loadMoreCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        return self.loadMoreCell;
    }
    
    return [[UITableViewCell alloc] init];
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (cell == self.loadMoreCell) {
        if (_hasMore && ![_manager isLoading]) {
            [self loadMore];
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    wrapperTrackEvent(@"update_detail", @"reply_replier_content");
    ArticleMomentCommentModel *model = nil;
    
    if (indexPath.section == 0) {
        if (indexPath.row < [[_manager hotComments] count]) {
            model = [[_manager hotComments] objectAtIndex:indexPath.row];
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row < [[_manager comments] count]) {
            model = [[_manager comments] objectAtIndex:indexPath.row];
        } else {
            [self loadMore];
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            return;
        }
    }
    
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [self commentCell:(ArticleMomentDetailViewCommentCell *)cell openComment:model];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
#pragma mark -- scroll view delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.scrollViewDidScrollBlock) {
        self.scrollViewDidScrollBlock(scrollView);
    }
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if ([menu isMenuVisible]) {
        [menu setMenuVisible:NO animated:YES];
    }
}
#pragma mark -- commentAction
- (void)commentButtonClicked:(id)sender
{
    // 拉黑逻辑
    if (self.momentModel.user.isBlocked || self.momentModel.user.isBlocking)
    {
        NSString * description = nil;
        if (self.momentModel.user.isBlocked) {
            description = [[SSIndicatorTipsManager shareInstance] indicatorTipsForKey:kTipForActionToBlockedUser];
        } else {
            description = [[SSIndicatorTipsManager shareInstance] indicatorTipsForKey:kTipForActionToBlockingUser];
        }
        if (!description) {
            description = self.momentModel.user.isBlocked ? @" 根据对方设置，您不能进行此操作" : @"您已拉黑此用户，不能进行此操作";
        }
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:description indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        return;
    }
    
    NSMutableDictionary * contextInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    [contextInfo setValue:self.momentModel forKey:ArticleMomentModelKey];
    if (self.fromVideoDetail) {
        [contextInfo setValue:self.commentModel forKey:ArticleCommentModelKey];
    }
    if (sender == self.postCommonButton.button) {
        [contextInfo setValue:self.replyMomentCommentModel forKey:ArticleMomentCommentModelKey];
    }
    
    [contextInfo setValue:NSStringFromCGPoint(self.commentListView.contentOffset) forKey:@"contentOffset"];
    ArticleCommentView * commentView = [[ArticleCommentView alloc] init];
    commentView.contextInfo = contextInfo;
    commentView.delegate = self;
    [commentView showInView:self animated:YES];
    commentView.fromThread = self.fromThread;
    if (self.sourceType == ArticleMomentSourceTypeFeed){
        NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:3];
        [extraDict setValue:@(self.enterFromClickComment) forKey:@"is_click_button"];
        if (!isEmptyString(self.categoryID)){
            [extraDict setValue:self.categoryID forKey:@"category_id"];
        }
        if (!isEmptyString(_groupModel.groupID)){
            [extraDict setValue:_groupModel.groupID forKey:@"value"];
        } else if (!isEmptyString(self.momentModel.group.ID)) {
            [extraDict setValue:self.momentModel.group.ID forKey:@"value"];
        }
        commentView.extraTrackDict = extraDict;
    }
    self.commentView = commentView;
    
    
    if (sender == _postCommonButton.button) {
        wrapperTrackEvent([self umengEventName], @"comment_box");
    }
    else {
        wrapperTrackEvent([self umengEventName], @"comment");
    }
}
- (void)userInfoDiggButtonClicked:(UIButton *)sender{
    if (![sender isSelected]){
        wrapperTrackEvent(@"update_detail", @"top_digg_click");
    }
    [self diggButtonPressed];
    
}
- (void)commentDiggButtonClicked{
    wrapperTrackEvent(@"update_detail", @"bottom_digg_click");
    [self diggButtonPressed];
}
- (void)diggButtonPressed{
    if (!TTNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"没有网络连接" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        return;
    }
    
    if (self.momentModel.digged) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"您已经赞过" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
        return;
    }
    
    self.momentModel.digged = YES;
    if (self.momentModel.diggLimit <= 0) {
        self.momentModel.diggLimit = 1;
    }
    else {
        self.momentModel.diggLimit += 1;
    }
    self.momentModel.diggsCount += 1;
    
    [self.momentModel insertDiggUser:[[TTAccountManager sharedManager] myUser]];
    
    [ArticleMomentDiggManager startDiggMoment:self.momentModel.ID finishBlock:^(int newCount, NSError *error) {
    }];
    //如果已经被删除 return  @zengruihuan
    if (self.isSelfDeleted) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(didDigMoment:)]) {
        [self.delegate didDigMoment:self.momentModel];
    }
    if (self.syncDigCountBlock) {
        self.syncDigCountBlock();
    }
    [_headerView.header.userInfoItemView.diggButton setDiggCount:self.momentModel.diggsCount];
    [_headerView.header.userInfoItemView.diggButton sizeToFit];
    [_headerView.header.userInfoItemView.diggButton setSelected:YES];
    [_postCommonButton.diggButton setSelected:YES];
}
- (void)shareButtonPressed
{
    [self.activityActionManager clearCondition];
    if (!self.activityActionManager) {
        self.activityActionManager = [[TTActivityShareManager alloc] init];
    }
    
    NSMutableArray * activityItems = [ArticleShareManager shareActivityManager:self.activityActionManager moment:self.momentModel sourceType:_sourceType threadInfoLoaded:(self.thread != nil)];
    
    self.phoneShareView = [[SSActivityView alloc] init];
    _phoneShareView.delegate = self;
    _phoneShareView.activityItems = activityItems;
    [_phoneShareView showOnWindow:self.window];
    [self sendMomentDetailShareTrackWithItemType:TTActivityTypeShareButton];
}
/**
 *  登录后，则直接回复， 没有登录，则先登录， 再回复
 */
- (void)loginOrReplyToCommentModel:(ArticleMomentCommentModel *)model rectInKeyWindow:(CGRect)rect
{
    if (![TTAccountManager isLogin]) {
        
        [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypePost source:@"post_comment" completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
            if (type == TTAccountAlertCompletionEventTypeDone) {
                if ([TTAccountManager isLogin]) {
                    [self replyToCommentModel:model rectInKeyWindow:rect];
                }
            } else if (type == TTAccountAlertCompletionEventTypeTip) {
                [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:self] type:TTAccountLoginDialogTitleTypeDefault source:@"post_comment" completion:^(TTAccountLoginState state) {

                }];
            }
        }];
    }
    else {
        [self replyToCommentModel:model rectInKeyWindow:rect];
    }
}
- (void)replyToCommentModel:(ArticleMomentCommentModel *)model rectInKeyWindow:(CGRect)rect {
    NSMutableDictionary * contextInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    [contextInfo setValue:self.momentModel forKey:ArticleMomentModelKey];
    [contextInfo setValue:model forKey:ArticleMomentCommentModelKey];
    [contextInfo setValue:NSStringFromCGRect(rect) forKey:@"frame"];
    [contextInfo setValue:NSStringFromCGPoint(self.commentListView.contentOffset) forKey:@"contentOffset"];
    ArticleCommentView * commentView = [[ArticleCommentView alloc] init];
    commentView.contextInfo = contextInfo;
    commentView.delegate = self;
    commentView.fromThread = self.fromThread;
    [commentView showInView:self animated:YES];
    self.commentView = commentView;
    if (_sourceType == ArticleMomentSourceTypeFeed){
        NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:3];
        [extraDict setValue:@(_enterFromClickComment) forKey:@"is_click_button"];
        if (!isEmptyString(_categoryID)){
            [extraDict setValue:_categoryID forKey:@"category_id"];
        }
        if (!isEmptyString(_groupModel.groupID)){
            [extraDict setValue:_groupModel.groupID forKey:@"value"];
        } else if (!isEmptyString(self.momentModel.group.ID)) {
            [extraDict setValue:self.momentModel.group.ID forKey:@"value"];
        }
        _commentView.extraTrackDict = extraDict;
    }
    wrapperTrackEvent([self umengEventName], @"reply");
    //    wrapperTrackEvent([self umengEventName], @"reply_replier_button");
}
- (TTShareSourceObjectType)sourceTypeForSharedHeaderItem:(ExploreMomentListCellHeaderItem *)headerItem momentModel:(ArticleMomentModel *)moment
{
    if ([headerItem.forwardItemView isForumItemViewShown]) {
        return TTShareSourceObjectTypeForumPost;
    }
    else if (moment.itemType == MomentItemTypeOnlyShowInForum ||
             moment.itemType == MomentItemTypeForum) {
        return TTShareSourceObjectTypeForumPost;
    }
    else {
        return TTShareSourceObjectTypeMoment;
    }
}
#pragma mark -- Track
- (void)sendMomentDetailShareTrackWithItemType:(TTActivityType)itemType
{
    TTShareSourceObjectType sourceType = [self sourceTypeForSharedHeaderItem:self.headerView.header momentModel:_momentModel];
    NSString *tag = [TTActivityShareManager tagNameForShareSourceObjectType:sourceType];
    NSString *label = [TTActivityShareManager labelNameForShareActivityType:itemType];
    NSString *forumId = _momentModel.forumID ? [NSString stringWithFormat:@"%lld", _momentModel.forumID] : nil;
    wrapperTrackEventWithCustomKeys(tag, label, _momentModel.ID, forumId, nil);
}
#pragma mark - Helper
- (UIResponder *)_needResponder
{
    UIResponder *responder = self.nextResponder;
    while (responder) {
        if ([responder isKindOfClass:NSClassFromString(@"ArticleMomentDetailViewController")]) {
            return responder;
        }
        responder = [responder nextResponder];
    }
    return nil;
}
#pragma mark - SSActivityViewDelegate
- (void)activityView:(SSActivityView *)view didCompleteByItemType:(TTActivityType)itemType
{
    if (view == _phoneShareView) {
        TTShareSourceObjectType sourceType = [self sourceTypeForSharedHeaderItem:self.headerView.header momentModel:self.momentModel];
//        if (itemType == TTActivityTypeWeitoutiao) {
//            wrapperTrackEventWithCustomKeys(@"comment_detail_share", @"share_weitoutiao", self.momentModel.group.ID, nil, nil);
//            [self forwardToWeitoutiao];
//            if (ttvs_isShareIndividuatioEnable()){
//                [[TTActivityShareSequenceManager sharedInstance_tt] instalAllShareActivitySequenceFirstActivity:itemType];
//            }
//        }
//        else {
            [_activityActionManager performActivityActionByType:itemType inViewController:[TTUIResponderHelper topViewControllerFor: self] sourceObjectType:sourceType uniqueId:self.momentModel.ID];
//        }
        [self sendMomentDetailShareTrackWithItemType:itemType];
        self.phoneShareView = nil;
    }
}
#pragma mark - ArticleCommentDelegate
- (void) commentView:(ArticleCommentView *)commentView didFinishPublishComment:(ArticleMomentCommentModel *)commentModel {
    [_manager insertComment:commentModel];
    [_commentListView reloadData];
    
    if (self.updateMomentCountBlock) {
        self.updateMomentCountBlock(0, 1);
    }
    if (self.replyMomentCommentModel) {
        self.replyMomentCommentModel = nil;
        [self.postCommonButton setPlaceholderContent:[SSCommonLogic exploreDetailToolBarWriteCommentPlaceholderText]];
    }
    
    [commentView dismissAnimated:YES];
    //    self.commentView = nil;
    
    // 统计
    // 回复推荐者的评论（只记实际发送成功）——发回gid、作者mid、uid
    if (!isEmptyString(self.mediaId)) {
        NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithCapacity:2];
        [extra setValue:self.mediaId forKey:@"media_id"];
        [extra setValue:self.momentModel.user.ID forKey:@"uid"];
        [extra setValue:self.gid forKey:@"gid"];
        
        [TTTrackerWrapper event:@"update_detail" label:@"reply_media_comment" value:self.commentId extValue:nil extValue2:nil dict:extra];
    }
    
    if (self.fromVideoDetail) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ArticleMomentDetailViewAddMomentNoti object:nil userInfo:@{@"increment":@(1)}];
    }
    
    if (_sourceType == ArticleMomentSourceTypeFeed){
        if (_publishStatusForTrack == 1){
            _publishStatusForTrack = 2;
            //发表评论前没有登录，然后登录后发送成功，多发一个埋点统计
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            if (!isEmptyString(_categoryID)){
                [dict setValue:_categoryID forKey:@"category_id"];
            }
            [dict setValue:@(_enterFromClickComment) forKey:@"is_click_button"];
            [dict setValue:@"comment" forKey:@"group_type"];
            wrapperTrackEventWithCustomKeys(@"comment", @"write_confirm_unlog_done", self.groupModel.groupID, nil, dict);
        }
    }
}
- (void) commentView:(ArticleCommentView *)commentView publishWithText:(NSString *)text{
    if (_sourceType != ArticleMomentSourceTypeFeed){
        return;
    }
    if (![TTAccountManager isLogin] && _publishStatusForTrack <= 1){
        _publishStatusForTrack = 1;
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        if (!isEmptyString(_categoryID)){
            [dict setValue:_categoryID forKey:@"category_id"];
        }
        [dict setValue:@(_enterFromClickComment) forKey:@"is_click_button"];
        [dict setValue:@"comment" forKey:@"group_type"];
        wrapperTrackEventWithCustomKeys(@"comment", @"write_confirm_unlog", self.groupModel.groupID, nil, dict);
    }
}
- (void) commentViewDidDismiss:(ArticleCommentView *) commentView {
    //    self.commentView = nil;
    if (self.replyMomentCommentModel) {
        wrapperTrackEvent(@"update_detail", @"reply_replier_cancel");
        self.replyMomentCommentModel = nil;
        [self.postCommonButton setPlaceholderContent:[SSCommonLogic exploreDetailToolBarWriteCommentPlaceholderText]];
    }else{
        wrapperTrackEvent(@"update_detail", @"write_cancel");
    }
}
#pragma mark -- observe
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"diggUsers"] ||
        [keyPath isEqualToString:@"commentsCount"]) {
        [self refreshHeaderView];
        [self reloadThemeUI];
    }
}
#pragma mark -- ArticleMomentDetailViewCommentCellDelegate
- (void)commentCell:(ArticleMomentDetailViewCommentCell *)cell openComment:(ArticleMomentCommentModel *)model
{
    
    if ([TTAccountManager isLogin] &&
        [model.user.ID longLongValue] != 0 &&
        [[TTAccountManager userID] longLongValue] == [model.user.ID longLongValue]) {
        [self commentCell:cell deleteComment:model];
    } else {
        // 拉黑逻辑
        if (model.user.isBlocked || model.user.isBlocking)
        {
            NSString * description = nil;
            if (model.user.isBlocked) {
                description = [[SSIndicatorTipsManager shareInstance] indicatorTipsForKey:kTipForActionToBlockedUser];
            } else {
                description = [[SSIndicatorTipsManager shareInstance] indicatorTipsForKey:kTipForActionToBlockingUser];
            }
            if (!description) {
                description = model.user.isBlocked ? @" 根据对方设置，您不能进行此操作" : @"您已拉黑此用户，不能进行此操作";
            }
            
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:description indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            return;
        }
        
        CGRect rect = [cell.superview convertRect:cell.frame toView:[[UIApplication sharedApplication] keyWindow]];
        [self loginOrReplyToCommentModel:model rectInKeyWindow:rect];
    }
}
- (void)commentCell:(ArticleMomentDetailViewCommentCell *)cell deleteComment:(ArticleMomentCommentModel *)model {
    if (!isEmptyString(model.ID)) {
        BOOL useThemedActionSheet = NO;
        if (useThemedActionSheet) {
            TTThemedAlertController *actionSheet = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"确定删除此评论?", nil) message:nil preferredType:TTThemedAlertControllerTypeActionSheet];
            [actionSheet addActionWithTitle:@"取消" actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
            [actionSheet addActionWithTitle:@"确认删除" actionType:TTThemedAlertActionTypeDestructive actionBlock:^{
                if ([model.ID longLongValue] != 0) {
                    if (!TTNetworkConnected()) {
                        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"没有网络连接" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                    }
                    else {
                        [[ExploreDeleteManager shareManager] deleteMomentCommentForCommentID:[NSString stringWithFormat:@"%@", model.ID]];
                        if (model) {
                            if (self.sourceType == ArticleMomentSourceTypeMoment) {
                                wrapperTrackEvent(@"delete", @"reply_update");
                            } else if (self.sourceType == ArticleMomentSourceTypeForum) {
                                wrapperTrackEvent(@"delete", @"reply_post");
                            } else if (self.sourceType == ArticleMomentSourceTypeProfile) {
                                wrapperTrackEvent(@"delete", @"reply_profile");
                            }
                            
                            [_manager deleteComment:model];
                            [_momentModel deleteComment:model];
                            [self reloadListViewData];
                            if (self.fromVideoDetail) {
                                [[NSNotificationCenter defaultCenter] postNotificationName:ArticleMomentDetailViewAddMomentNoti object:nil userInfo:@{@"increment":@(-1)}];
                                if (self.dismissBlock) {
                                    self.dismissBlock();
                                }
                            }
                            //                            //待优化：删除动态回复后，刷新评论列表
                            //                            [self reloadArticleCommentListIfNeeded];
                        }
                    }
                }
            }];
            [actionSheet showFrom:self.viewController animated:YES];
        }
        else {
            self.needDeleteCommentModel = model;
            UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"确定删除此评论?", nil) delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确认删除" otherButtonTitles:nil, nil];
            sheet.tag = kDeleteCommentActionSheetTag;
            [sheet showInView:self];
        }
    }
    else {
        self.needDeleteCommentModel = nil;
    }
}
#pragma mark -- UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kDeleteCommentActionSheetTag) {
        if ([_needDeleteCommentModel.ID longLongValue] != 0 &&
            buttonIndex != actionSheet.cancelButtonIndex) {
            if (!TTNetworkConnected()) {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"没有网络连接" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            }
            else {
                [[ExploreDeleteManager shareManager] deleteMomentCommentForCommentID:[NSString stringWithFormat:@"%@", _needDeleteCommentModel.ID]];
                if (_needDeleteCommentModel) {
                    if (self.sourceType == ArticleMomentSourceTypeMoment) {
                        wrapperTrackEvent(@"delete", @"reply_update");
                    } else if (self.sourceType == ArticleMomentSourceTypeForum) {
                        wrapperTrackEvent(@"delete", @"reply_post");
                    } else if (self.sourceType == ArticleMomentSourceTypeProfile) {
                        wrapperTrackEvent(@"delete", @"reply_profile");
                    }
                    
                    [_manager deleteComment:_needDeleteCommentModel];
                    [_momentModel deleteComment:_needDeleteCommentModel];
                    [self reloadListViewData];
                    if (self.fromVideoDetail) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:ArticleMomentDetailViewAddMomentNoti object:nil userInfo:@{@"increment":@(-1)}];
                        if (self.dismissBlock) {
                            self.dismissBlock();
                        }
                    }
                }
            }
        }
        self.needDeleteCommentModel = nil;
    }
}
- (NSString *)umengEventName {
    if (_sourceType == ArticleMomentSourceTypeForum) {
        return @"topic_detail";
    } else {
        return @"update_detail";
    }
}
@end
