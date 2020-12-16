//
#import <BDTrackerProtocol/BDTrackerProtocol.h>
//  TTCommentDetailCell.m
//  Article
//
//  Created by muhuai on 08/01/2017.
//
//

#import "TTCommentDetailCell.h"
#import "TTCommentUIHelper.h"
#import <TTReporter/TTReportManager.h>
#import <TTPlatformBaseLib/TTIconFontDefine.h>
#import <TTPlatformBaseLib/TTTrackerWrapper.h>
#import <TTBaseLib/TTDeviceUIUtils.h>
#import <TTBatchItemAction/DetailActionRequestManager.h>
#import <TTPlatformUIModel/TTActionSheetController.h>
#import <TTVerifyKit/TTVerifyIconHelper.h>
#import <TTAvatar/TTAsyncCornerImageView+VerifyIcon.h>
#import <TTUGCFoundation/TTUGCAttributedLabel.h>
#import <TTUGCFoundation/TTRichSpanText.h>
#import <TTUGCFoundation/TTRichSpanText+Emoji.h>
#import <TTRoute/TTRoute.h>
#import <TTUIWidget/TTIndicatorView.h>
#import <TTUIWidget/TTUserInfoView.h>
#import <TTUIWidget/TTAsyncLabel.h>
#import <TTDiggButton/TTDiggButton.h>
#import <TTBaseLib/UIViewAdditions.h>
#import <TTThemed/TTThemeManager.h>
#import "UIColor+Theme.h"
#import "TTAccountLoginManager.h"
#import "TTAccountManager.h"
#import "ToastManager.h"
#import "FHUGCCommonAvatar.h"


NSString *const kTTCommentDetailCellIdentifier = @"kTTCommentDetailCellIdentifier";
#define kTTCommentCellDigButtonHitTestInsets UIEdgeInsetsMake(-30, -30, -10, -30)
#define kTTCommentContentLabelQuotedCommentUserURLString @"com.bytedance.kTTCommentContentLabelQuotedCommentUserURLString"


@interface TTCommentDetailCell () <TTUGCAttributedLabelDelegate>
@property (nonatomic, strong) TTCommentDetailReplyCommentModel *commentModel;
@property (nonatomic, strong) TTCommentDetailCellLayout *layout;
@property (nonatomic, strong) FHUGCCommonAvatar*avatarView;
@property (nonatomic, strong) TTUserInfoView *nameView;
@property (nonatomic, strong) TTDiggButton *digButton;
@property (nonatomic, strong) TTAsyncLabel *userInfoLabel;         //用户信息(头条号+认证信息)
@property (nonatomic, strong) TTAsyncLabel *timeLabel;             //时间
@property (nonatomic, strong) TTUGCAttributedLabel *contentLabel;     //回复内容
@property (nonatomic, strong) SSThemedButton *deleteButton;         //删除
@property (nonatomic, assign) BOOL hasQuotedContent;           //是否有引用内容
@property (nonatomic, strong) DetailActionRequestManager *actionManager;
@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) TTActionSheetController *actionSheetController;
@end

@implementation TTCommentDetailCell

- (void)dealloc {

}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColorThemeKey = kColorBackground4;
        self.isBanShowAuthor = NO;
        self.source = nil;
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    [self.contentView addSubview:self.avatarView];
    [self.contentView addSubview:self.nameView];
    [self.contentView addSubview:self.userInfoLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.deleteButton];
    [self.contentView addSubview:self.digButton];
}

#pragma mark - refresh view with layout

- (void)tt_refreshConditionWithLayout:(TTCommentDetailCellLayout *)layout model:(TTCommentDetailReplyCommentModel *)model {
    if (!model) {
        return;
    }
    self.commentModel = model;
    self.layout = layout;
    
    [self refreshDigButton];
    [self refreshAvatarView];
    [self refreshNameView];
    [self refreshUserInfo];
    [self refreshTimeLabel];
    [self refreshContent];
    [self refreshDeleteButton];
}

- (void)refreshAvatarView {
    [self.avatarView setAvatarUrl:self.commentModel.user.avatarURLString];
    [self.avatarView setUserId: self.commentModel.user.ID];
}

- (void)refreshNameView {
    CGFloat maxWidth = self.width - [TTCommentDetailCellHelper cellRightPadding] - self.digButton.width - [TTCommentDetailCellHelper nameViewRightPadding] - self.nameView.left;
    self.nameView.isBanShowAuthor = self.isBanShowAuthor;
    [self.nameView refreshWithTitle:self.commentModel.user.name relation:[self.commentModel userRelationDescription] verifiedInfo:nil verified:NO owner:self.commentModel.isOwner maxWidth:maxWidth appendLogoInfoArray:self.commentModel.user.authorBadgeList];
}

- (void)refreshTimeLabel {
    self.timeLabel.top = self.layout.timeLayout.top;
    self.timeLabel.left = self.layout.timeLayout.left;
    self.timeLabel.width = self.layout.timeLayout.width;
    self.timeLabel.text = self.layout.timeLayout.text;
}

- (void)refreshDigButton {
    [self.digButton setDiggCount:self.commentModel.diggCount];
    self.digButton.selected = self.commentModel.userDigg;
    [self.digButton sizeToFit];
    // 由于sizeToFit没有将EdagesInset考虑进来，造成文字截断，尝试用UIButton也有同样的问题
    CGSize size = self.digButton.frame.size;
    size.width += 6;
    self.digButton.size = size;
    self.digButton.centerY = self.nameView.centerY - 2.f;
    self.digButton.right = self.contentView.right - [TTCommentDetailCellHelper cellRightPadding];
}

- (void)refreshUserInfo {
    self.userInfoLabel.left = self.layout.userInfoLayout.left;
    self.userInfoLabel.width = self.layout.userInfoLayout.width;
    if (self.userInfoLabel.width > 0) {
        self.userInfoLabel.text = self.layout.userInfoLayout.text;
    }
}

- (void)refreshContent {
    self.contentLabel.top = self.layout.contentLayout.top;
    self.contentLabel.width = self.layout.contentLayout.width;
    self.contentLabel.height = self.layout.contentLayout.height;

    NSMutableAttributedString *attributedString = [self.layout.contentLayout.attributedText mutableCopy];

    [attributedString addAttributes:@{
        NSParagraphStyleAttributeName: [TTCommentDetailCellHelper contentLabelParagraphStyle],
        NSFontAttributeName: [TTCommentDetailCellHelper contentLabelFont],
        NSForegroundColorAttributeName: [TTCommentDetailCellHelper contentLabelTextColor]
    } range:NSMakeRange(0, attributedString.length)];

    self.contentLabel.text = [attributedString copy];

    NSDictionary *linkAttributes = @{
        NSParagraphStyleAttributeName: [TTCommentDetailCellHelper contentLabelParagraphStyle],
        NSForegroundColorAttributeName : [UIColor themeRed3],
        NSFontAttributeName : [TTCommentDetailCellHelper contentLabelFont]
    };
    self.contentLabel.linkAttributes = linkAttributes;
    self.contentLabel.activeLinkAttributes = linkAttributes;
    self.contentLabel.inactiveLinkAttributes = linkAttributes;

    NSArray <TTRichSpanLink *> *richSpanLinks = [self.layout.contentLayout.richSpanText richSpanLinksOfAttributedString];
    for (TTRichSpanLink *richSpanLink in richSpanLinks) {
        NSRange range = NSMakeRange(richSpanLink.start, richSpanLink.length);
        if (NSMaxRange(range) <= self.layout.contentLayout.attributedText.length) {
            if (richSpanLink.type == TTRichSpanLinkTypeQuotedCommentUser) {
                [self.contentLabel addLinkToURL:[NSURL URLWithString:kTTCommentContentLabelQuotedCommentUserURLString] withRange:range];
            } else {
                [self.contentLabel addLinkToURL:[NSURL URLWithString:richSpanLink.link] withRange:range];
            }
        }
    }
}

- (void)refreshDeleteButton {
    self.deleteButton.hidden = self.layout.deleteLayout.hidden;
    if (!self.deleteButton.isHidden) {
        self.deleteButton.width = self.layout.deleteLayout.width;
        self.deleteButton.right = self.layout.deleteLayout.right;
        self.deleteButton.centerY = self.timeLabel.centerY;
    }
}

#pragma mark - actions

- (void)avatarViewOnClick:(id)sender {
    [BDTrackerProtocol trackEventWithCustomKeys:[self _trackerSource] label:@"click_replier_avatar" value:nil source:self.source extraDic:nil];
    if (self.delegate && [self.delegate respondsToSelector:@selector(tt_commentCell:avatarTappedWithCommentModel:)]) {
        [self.delegate tt_commentCell:self avatarTappedWithCommentModel:self.commentModel];
    }
}

- (void)nameViewOnClick:(id)sender {
    [BDTrackerProtocol trackEventWithCustomKeys:[self _trackerSource] label:@"click_replier_name" value:nil source:self.source extraDic:nil];
    if (self.delegate && [self.delegate respondsToSelector:@selector(tt_commentCell:avatarTappedWithCommentModel:)]) {
        [self.delegate tt_commentCell:self nameViewonClickedWithCommentModel:self.commentModel];
    }
}

- (void)replyButtonOnClick:(id)sender {
    [BDTrackerProtocol trackEventWithCustomKeys:[self _trackerSource] label:@"reply_replier_button" value:nil source:self.source extraDic:nil];
    if (self.delegate && [self.delegate respondsToSelector:@selector(tt_commentCell:replyButtonClickedWithModel:)]) {
        [self.delegate tt_commentCell:self replyButtonClickedWithModel:self.commentModel];
    }
}

- (void)deleteButtonOnClick:(id)sender {
//    wrapperTrackEvent([self trackerSource], @"reply_replier_button");
    if (self.delegate && [self.delegate respondsToSelector:@selector(tt_commentCell:deleteCommentWithCommentModel:)]) {
        [self.delegate tt_commentCell:self deleteCommentWithCommentModel:self.commentModel];
    }
}

- (void)digButtonOnClick:(id)sender {
//    wrapperTrackEventWithCustomKeys([self _trackerSource], @"replier_digg_click", nil, self.source, nil);
    if (self.delegate && [self.delegate respondsToSelector:@selector(tt_commentCell:digCommentWithCommentModel:)]) {
        [self.delegate tt_commentCell:self digCommentWithCommentModel:self.commentModel];
    }
}

#pragma mark - TTTAttributedLabel Delegate

- (void)attributedLabel:(TTUGCAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if ([url.absoluteString isEqualToString:kTTCommentContentLabelQuotedCommentUserURLString]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(tt_commentCell:quotedNameOnClickedWithCommentModel:)]) {
            if (!isEmptyString(self.commentModel.qutoedCommentModel.userID)) {
                [self.delegate tt_commentCell:self quotedNameOnClickedWithCommentModel:self.commentModel];
            }
        }
    } else {
        if ([[TTRoute sharedRoute] canOpenURL:url]) {
            [[TTRoute sharedRoute] openURLByPushViewController:url];
        }
        else {
            NSString *linkStr = url.absoluteString;
            if (!isEmptyString(linkStr)) {
                [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://webview"]
                                                          userInfo:TTRouteUserInfoWithDict(@{@"url":linkStr})];
            }
        }
    }
}

- (void)themeChanged:(NSNotification *)notification {
    [self refreshContent];

    self.timeLabel.textColor = [UIColor tt_themedColorForKey:@"grey3"];
    self.userInfoLabel.textColor = [UIColor tt_themedColorForKey:kColorText13];
}

#pragma mark - private methods

- (NSString *)_trackerSource {
    return @"update_detail";
}

- (BOOL)isDetailComment {
    return YES;
}

#pragma mark - UIMenuController

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)handleLongPress:(UIGestureRecognizer*)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"复制", nil) action:@selector(customCopy:)];
        UIMenuItem *reportItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"举报", nil) action:@selector(reportComment:)];
        UIMenuItem *shieldItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"屏蔽", nil) action:@selector(shieldComment:)];
        if (copyItem) {
            self.menuItems = menu.menuItems;
            menu.menuItems = @[copyItem, reportItem, shieldItem];
        }
        [menu setTargetRect:self.contentLabel.frame inView:self.contentLabel.superview];
        [menu setMenuVisible:YES animated:YES];
        [self changeContentLabelBackgroundColor];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideMenu) name:UIMenuControllerWillHideMenuNotification object:nil];
        [BDTrackerProtocol trackEventWithCustomKeys:[self _trackerSource] label:@"replier_longpress" value:nil source:self.source extraDic:nil];
    }
}

- (void)willHideMenu {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
    [self resetContentLabelBackgroundColor];

    UIMenuController *menu = [UIMenuController sharedMenuController];
    if ([menu isMenuVisible]) {
        [menu setMenuVisible:NO animated:YES];
        return;
    }
//    UIMenuController *menu = [UIMenuController sharedMenuController];
//    menu.menuItems = self.menuItems;

}

- (BOOL)canPerformAction:(SEL)action withSender:(__unused id)sender {
    return (action == @selector(customCopy:) ||
            action == @selector(reportComment:)||
            action == @selector(shieldComment:));
}

- (void)customCopy:(__unused id)sender {
    [[UIPasteboard generalPasteboard] setString:self.layout.contentLayout.richSpanText.text];
    [BDTrackerProtocol trackEventWithCustomKeys:[self _trackerSource] label:@"replier_longpress_copy" value:nil source:self.source extraDic:nil];
}

- (void)reportComment:(__unused id)sender {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:self.commentModel.commentID forKey:@"comment_id"];
    [params setValue:self.commentModel.user.ID forKey:@"user_id"];
    [BDTrackerProtocol trackEventWithCustomKeys:[self _trackerSource] label:@"replier_longpress_report" value:nil source:self.source extraDic:nil];

    self.actionSheetController = [[TTActionSheetController alloc] init];

    [self.actionSheetController insertReportArray:[TTReportManager fetchReportUserOptions]];
    WeakSelf;
    [self.actionSheetController performWithSource:TTActionSheetSourceTypeUser completion:^(NSDictionary * _Nonnull parameters) {
        if (parameters[@"report"]) {
            TTReportUserModel *model = [[TTReportUserModel alloc] init];
            model.userID = wself.commentModel.user.ID;
            model.commentID = wself.commentModel.commentID;
            model.groupID = wself.commentModel.groupID;
            [[TTReportManager shareInstance] startReportUserWithType:parameters[@"report"] inputText:parameters[@"criticism"] message:nil source:@(TTReportSourceComment).stringValue userModel:model animated:YES];
        }
    }];
}

- (void)shieldComment:(__unused id)sender {
    [[ToastManager manager] showToast:@"屏蔽成功"];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if ([menu isMenuVisible]) {
        [menu setMenuVisible:NO animated:YES];
        return;
    }

    [super touchesBegan:touches withEvent:event];
}

- (void)hideMenu {
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if ([menu isMenuVisible]) {
        [menu setMenuVisible:NO animated:YES];
    }
}

- (void)changeContentLabelBackgroundColor {
    self.contentLabel.backgroundColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"d4d4d4" nightColorName:@"353535"]];
}

- (void)resetContentLabelBackgroundColor {
    self.contentLabel.backgroundColor = [UIColor clearColor];
}

#pragma mark - getter & setter

- (FHUGCCommonAvatar *)avatarView {
    if (!_avatarView) {
        _avatarView = [[FHUGCCommonAvatar alloc] initWithFrame:CGRectMake([TTCommentDetailCellHelper cellHorizontalPadding], [TTCommentDetailCellHelper cellVerticalPadding], [TTCommentDetailCellHelper avatarSize], [TTCommentDetailCellHelper avatarSize])];
        [_avatarView setPlaceholderImage:@"big_defaulthead_head"];
        [_avatarView addGestureRecognizer:({
            UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarViewOnClick:)];
            gesture;
        })];
    }
    return _avatarView;
}

- (TTUserInfoView *)nameView {
    if (!_nameView) {
        CGFloat maxWidth = self.width - [TTCommentDetailCellHelper cellHorizontalPadding] - [TTCommentDetailCellHelper avatarSize] - [TTCommentDetailCellHelper avatarRightPadding] - [TTCommentDetailCellHelper cellRightPadding] - 30.f - [TTCommentDetailCellHelper nameViewRightPadding];
        _nameView = [[TTUserInfoView alloc] initWithBaselineOrigin:CGPointMake(0, 0) maxWidth:maxWidth limitHeight:[UIFont systemFontOfSize:[TTCommentDetailCellHelper nameViewFontSize]].lineHeight title:nil fontSize:[TTCommentDetailCellHelper nameViewFontSize] verifiedInfo:nil appendLogoInfoArray:nil];
        _nameView.frame = CGRectMake(self.avatarView.right + [TTCommentDetailCellHelper avatarRightPadding], [TTCommentDetailCellHelper cellVerticalPadding], maxWidth, [TTDeviceUIUtils tt_newPadding:20.f]);
        WeakSelf;
        __weak typeof(_nameView) weakNameView = _nameView;
        [_nameView clickTitleWithAction:^(NSString *title) {
            [wself nameViewOnClick:weakNameView];
        }];
    }
    return _nameView;
}

- (TTDiggButton *)digButton {
    if (!_digButton) {
        _digButton = [TTDiggButton diggButtonWithStyleType:TTDiggButtonStyleTypeCommentOnly];
        _digButton.frame = CGRectMake(self.nameView.right, [TTCommentDetailCellHelper cellVerticalPadding], [TTDeviceUIUtils tt_newPadding:80], [TTDeviceUIUtils tt_newPadding:15]);
        _digButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        _digButton.imageEdgeInsets = UIEdgeInsetsMake(-2, 0, 2, 0);
        _digButton.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);

        _digButton.hitTestEdgeInsets = kTTCommentCellDigButtonHitTestInsets;
        if ([TTDeviceHelper OSVersionNumber] >= 8.f && UIAccessibilityIsBoldTextEnabled()) {
            _digButton.imageEdgeInsets = UIEdgeInsetsMake(-2, -1, 2, 1);
        }
        WeakSelf;
        [_digButton setClickedBlock:^(TTDiggButtonClickType type) {
            [wself digButtonOnClick:nil];
        }];
        
        _digButton.shouldClickBlock = ^BOOL{
            BOOL ret = [TTAccountManager isLogin];
            if(ret == NO) {
                [wself gotoLogin];
            }
            return ret;
        };
    }
    return _digButton;
}

- (void)gotoLogin {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *enterFrom = @"feed_detail";
    [params setObject:enterFrom forKey:@"enter_from"];
    [params setObject:@"feed_like" forKey:@"enter_type"];
    // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
    [params setObject:@(YES) forKey:@"need_pop_vc"];
    params[@"from_ugc"] = @(YES);
    __weak typeof(self) wSelf = self;
    [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
        if (type == TTAccountAlertCompletionEventTypeDone) {
            // 登录成功
            if ([TTAccountManager isLogin]) {
                [wSelf digButtonOnClick:wSelf.digButton];
            }
        }
    }];
}

- (TTAsyncLabel *)userInfoLabel {
    if (!_userInfoLabel) {
        _userInfoLabel = [[TTAsyncLabel alloc] init];
        _userInfoLabel.frame = CGRectMake(self.nameView.left, self.nameView.bottom, self.width - [TTCommentDetailCellHelper cellHorizontalPadding] - [TTCommentDetailCellHelper avatarSize] - [TTCommentDetailCellHelper avatarRightPadding], [TTDeviceUIUtils tt_newPadding:16.5f]);
        _userInfoLabel.font = [TTCommentDetailCellHelper userInfoLabelFont];
        _userInfoLabel.textColor = [UIColor tt_themedColorForKey:kColorText13];
        _userInfoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _userInfoLabel.backgroundColor = [UIColor clearColor];
        _userInfoLabel.layer.backgroundColor = [UIColor clearColor].CGColor;
        _userInfoLabel.numberOfLines = 1;
    }
    return _userInfoLabel;
}

- (TTAsyncLabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[TTAsyncLabel alloc] init];
        _timeLabel.frame = CGRectMake(self.nameView.left, self.contentLabel.bottom, self.width - [TTCommentDetailCellHelper cellHorizontalPadding] - [TTCommentDetailCellHelper avatarSize] - [TTCommentDetailCellHelper avatarRightPadding], [TTDeviceUIUtils tt_newPadding:16.5f]);
        _timeLabel.font = [TTCommentDetailCellHelper timeLabelFont];
        _timeLabel.textColor = [UIColor tt_themedColorForKey:@"grey3"];
        _timeLabel.numberOfLines = 1;
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.layer.backgroundColor = [UIColor clearColor].CGColor;
    }
    return _timeLabel;
}

- (TTUGCAttributedLabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[TTUGCAttributedLabel alloc] initWithFrame:CGRectMake(self.nameView.left, self.timeLabel.bottom + [TTCommentDetailCellHelper contentLabelPadding], 0, 0)];
        _contentLabel.font = [TTCommentUIHelper tt_fontOfSize:[TTCommentDetailCellHelper contentLabelFont].pointSize]; // 采用苹方字体能正确居中对齐...
        _contentLabel.textColor = SSGetThemedColorWithKey(kColorText1);
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.layer.backgroundColor = [UIColor clearColor].CGColor;
        _contentLabel.numberOfLines = 0;
        _contentLabel.delegate = self;

        _contentLabel.longPressGestureRecognizer.enabled = NO;
        [_contentLabel addGestureRecognizer:({
            [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        })];
    }
    return _contentLabel;
}

- (SSThemedButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.backgroundColor = [UIColor clearColor];
        _deleteButton.titleLabel.font = [TTCommentDetailCellHelper deleteButtonFont];
        _deleteButton.titleColorThemeKey = kColorText1;
        [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        _deleteButton.hidden = YES;
        _deleteButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_deleteButton addTarget:self action:@selector(deleteButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];
        _deleteButton.hitTestEdgeInsets = UIEdgeInsetsMake(-13, -8, -13, -8);
        _deleteButton.height = [TTCommentDetailCellHelper deleteButtonFont].lineHeight;
    }
    return _deleteButton;
}

@end
