//
//  TTUniversalCommentCellLite.m
//  Article
//
//  Created by zhaoqin on 14/11/2016.
//
//

#import "TTUniversalCommentCellLite.h"
#import "TTUniversalCommentLayout.h"
#import "TTCommentReplyListView.h"
#import "TTCommentUIHelper.h"
#import <TTDiggButton/TTDiggButton.h>
#import <TTUIWidget/TTAsyncLabel.h>
#import <TTReporter/TTReportManager.h>
#import <TTBatchItemAction/DetailActionRequestManager.h>
#import <TTPlatformUIModel/TTActionSheetController.h>
#import <TTUIWidget/TTUserInfoView.h>
#import <TTAvatar/TTAsyncCornerImageView+VerifyIcon.h>
#import <KVOController/KVOController.h>
#import <TTUGCFoundation/TTRichSpanText.h>
#import <TTUGCFoundation/TTRichSpanText+Emoji.h>
#import <TTRoute/TTRoute.h>
#import <TTBaseLib/UIViewAdditions.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTBaseLib/TTDeviceUIUtils.h>
#import <TTPlatformBaseLib/TTTrackerWrapper.h>
#import <TTThemed/TTThemeManager.h>



#define kTTCommentCellDigButtonHitTestInsets UIEdgeInsetsMake(-30, -30, -10, -30)
#define kTTCommentContentLabelQuotedCommentUserURLString @"com.bytedance.kTTCommentContentLabelQuotedCommentUserURLString"
#define kTTCommentContentLabelTruncationTokenURLString @"com.bytedance.kTTCommentContentLabelTruncationTokenURLString"


@interface TTUniversalCommentCellLite () <TTUGCAttributedLabelDelegate>
@property (nonatomic, strong) TTUniversalCommentLayout *layout;
@property (nonatomic, strong) TTAsyncCornerImageView *avatarView;
@property (nonatomic, strong) TTUserInfoView *nameView;
@property (nonatomic, strong) TTDiggButton *digButton;
@property (nonatomic, strong) TTAsyncLabel *userInfoLabel;         //用户信息(头条号+认证信息)
@property (nonatomic, strong) TTAsyncLabel *timeLabel;             //时间
@property (nonatomic, strong) TTUGCAttributedLabel *contentLabel;     //回复内容
@property (nonatomic, strong) TTAlphaThemedButton *replyButton;          //回复按钮
@property (nonatomic, strong) SSThemedButton *deleteButton;         //删除
@property (nonatomic, strong) TTCommentReplyListView *replyListView;//评论的热门回复
@property (nonatomic, assign) BOOL needLimitLines; //是否限制行数
@property (nonatomic, strong) DetailActionRequestManager *actionManager;
@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) TTActionSheetController *actionSheetController;
@end

@implementation TTUniversalCommentCellLite

- (void)dealloc {
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColorThemeKey = kColorBackground4;
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
    [self.contentView addSubview:self.replyButton];
    [self.contentView addSubview:self.deleteButton];
    [self.contentView addSubview:self.digButton];
}

#pragma mark - refresh view with layout

- (void)tt_refreshConditionWithLayout:(TTUniversalCommentLayout *)layout model:(id<TTCommentModelProtocol>)model {
    if (!model) {
        return;
    }
    [self.KVOController unobserve:self.commentModel];
    self.commentModel = model;
    WeakSelf;
    [self.KVOController observe:self.commentModel
                       keyPaths:@[@"userName", @"userAvatarURL"]
                        options:NSKeyValueObservingOptionNew
                          block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
                              StrongSelf;
                              [self refreshAvatarView];
                              [self refreshNameView];
                          }];
    self.layout = layout;
    self.backgroundColorThemeKey = model.isStick? kColorBackground22: kColorBackground4;
    [self refreshAvatarView];
    [self refreshDigButton];
    [self refreshNameView];
    [self refreshUserInfo];
    [self refreshTimeLabel];
    [self refreshContent];
    [self refreshReplayButton];
    [self refreshDeleteButton];
    [self refreshReplayList];
}

- (void)refreshAvatarView {
    [self.avatarView tt_setImageWithURLString:self.commentModel.userAvatarURL];

    [self.avatarView showOrHideVerifyViewWithVerifyInfo:self.commentModel.userAuthInfo decoratorInfo:self.commentModel.userDecoration];
}

- (void)refreshNameView {
    CGFloat maxWidth = self.width - [TTUniversalCommentCellLiteHelper cellRightPadding] - self.digButton.width - [TTUniversalCommentCellLiteHelper nameViewRightPadding] - self.nameView.left;
    [self.nameView refreshWithTitle:self.commentModel.userName relation:self.commentModel.userRelationStr verifiedInfo:nil verified:NO owner:self.commentModel.isOwner maxWidth:maxWidth appendLogoInfoArray:self.commentModel.authorBadgeList];
}

- (void)refreshTimeLabel {
    self.timeLabel.top = self.layout.timeLayout.top;
    self.timeLabel.left = self.layout.timeLayout.left;
    self.timeLabel.width = self.layout.timeLayout.width;
    self.timeLabel.height = self.layout.timeLayout.height + 1.f;
    self.timeLabel.text = self.layout.timeLayout.text;
}

- (void)refreshDigButton {
    [self.digButton setDiggCount:[self.commentModel.digCount integerValue]];
    self.digButton.selected = self.commentModel.userDigged;
    [self.digButton sizeToFit];
    // 由于sizeToFit没有将EdagesInset考虑进来，造成文字截断，尝试用UIButton也有同样的问题
    CGSize size = self.digButton.frame.size;
    size.width += 6;
    self.digButton.size = size;
    self.digButton.centerY = self.nameView.centerY - [TTDeviceHelper ssOnePixel];
    self.digButton.right = self.right - [TTUniversalCommentCellLiteHelper cellRightPadding];
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
    self.contentLabel.height = self.layout.isUnFold ? self.layout.contentLayout.unfoldHeight : self.layout.contentLayout.height;
    self.contentLabel.numberOfLines = self.layout.isUnFold ? 0 : [TTUniversalCommentCellLiteHelper contentLabelLimitToNumberOfLines];

    NSMutableAttributedString *attributedString = [self.layout.contentLayout.attributedText mutableCopy];

    [attributedString addAttributes:@{
        NSParagraphStyleAttributeName: [TTUniversalCommentCellLiteHelper contentLabelParagraphStyle],
        NSFontAttributeName: [TTUniversalCommentCellLiteHelper contentLabelFont],
        NSForegroundColorAttributeName: [TTUniversalCommentCellLiteHelper contentLabelTextColor]
    } range:NSMakeRange(0, attributedString.length)];

    self.contentLabel.text = [attributedString copy];

    NSDictionary *linkAttributes = @{
        NSParagraphStyleAttributeName: [TTUniversalCommentCellLiteHelper contentLabelParagraphStyle],
        NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText3],
        NSFontAttributeName : [TTUniversalCommentCellLiteHelper contentLabelFont]
    };
    self.contentLabel.linkAttributes = linkAttributes;
    self.contentLabel.activeLinkAttributes = linkAttributes;
    self.contentLabel.inactiveLinkAttributes = linkAttributes;
    self.contentLabel.attributedTruncationToken = [self attributedTruncationToken];

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

- (void)refreshReplayButton {
    if (self.layout.replyLayout.hidden) {
        self.replyButton.hidden = YES;
    } else {
        self.replyButton.hidden = NO;
        self.replyButton.top = self.layout.replyLayout.top;
        self.replyButton.left = self.timeLabel.right;
        self.replyButton.width = self.layout.replyLayout.width;
        [self.replyButton setTitle:self.layout.replyLayout.text forState:UIControlStateNormal];
    }
}

- (void)refreshDeleteButton {
    self.deleteButton.hidden = self.layout.deleteLayout.hidden;
    if (!self.deleteButton.isHidden) {
        self.deleteButton.width = self.layout.deleteLayout.width;
        self.deleteButton.right = self.layout.deleteLayout.right;
        self.deleteButton.centerY = self.timeLabel.centerY - 1.f;
    }
}

- (void)refreshReplayList {
    if ([self.commentModel hasReply] && !_replyListView) {
        [self.contentView addSubview:self.replyListView];
    }
    
    if ([self.commentModel hasReply]) {
        _replyListView.left = self.nameView.left;
        _replyListView.top = self.replyButton.bottom + [TTUniversalCommentCellLiteHelper contentLabelPadding] + 2.f;
        _replyListView.width = self.width - [TTUniversalCommentCellLiteHelper cellHorizontalPadding] - [TTUniversalCommentCellLiteHelper cellRightPadding] - [TTUniversalCommentCellLiteHelper avatarSize] - [TTUniversalCommentCellLiteHelper avatarRightPadding];
        _replyListView.hidden = NO;
        [_replyListView refreshReplyListWithComment:self.commentModel];
        [self.contentView bringSubviewToFront:_replyListView];
    } else {
        _replyListView.hidden = YES;
    }
}

#pragma mark - actions

- (void)avatarViewOnClick:(id)sender {
    if ([self isDetailComment]) {
        wrapperTrackEvent(@"comment", @"click_avatar");
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(tt_commentCell:avatarTappedWithCommentModel:)]) {
        [self.delegate tt_commentCell:self avatarTappedWithCommentModel:self.commentModel];
    }
}

- (void)nameViewOnClick:(id)sender {
    
    // add by zjing 去掉关注页跳转
    return;
    
    if ([self isDetailComment]) {
        wrapperTrackEvent(@"comment", @"click_name");
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(tt_commentCell:avatarTappedWithCommentModel:)]) {
        [self.delegate tt_commentCell:self nameViewonClickedWithCommentModel:self.commentModel];
    }
}

- (void)replyButtonOnClick:(id)sender {
    if ([self isDetailComment]) {
        wrapperTrackEvent(@"comment", @"click_reply");
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(tt_commentCell:replyButtonClickedWithModel:)]) {
        [self.delegate tt_commentCell:self replyButtonClickedWithModel:self.commentModel];
    }
}

- (void)deleteButtonOnClick:(id)sender {
    if ([self isDetailComment]) {
        wrapperTrackEvent(@"comment", @"delete");
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(tt_commentCell:deleteCommentWithCommentModel:)]) {
        [self.delegate tt_commentCell:self deleteCommentWithCommentModel:self.commentModel];
    }
}

//兼容详情页的评论区
- (void)performDiggAction {
    DetailActionRequestType actionType;
    if (_commentModel.userDigged) {
        _commentModel.digCount = @([_commentModel.digCount intValue] - 1);
        _digButton.selected = NO;
        _commentModel.userDigged = NO;
        actionType = DetailActionCommentUnDigg;
    } else {
        _commentModel.digCount = @([_commentModel.digCount intValue] + 1);
        _commentModel.userDigged = YES;
        actionType = DetailActionCommentDigg;
    }
    
    [_digButton setDiggCount:[_commentModel.digCount intValue]];
    [self.digButton sizeToFit];
    CGSize size = self.digButton.frame.size;
    size.width += 6;
    self.digButton.size = size;
    self.digButton.right = self.right - [TTUniversalCommentCellLiteHelper cellRightPadding];

    // TODO delegate 处理
    TTDetailActionReuestContext *context = [TTDetailActionReuestContext new];
    if (_commentModel.commentID) {
        context.itemCommentID = [NSString stringWithFormat:@"%@", _commentModel.commentID];
    }
    context.groupModel = _commentModel.groupModel;
    
    if (!_actionManager) {
        _actionManager = [[DetailActionRequestManager alloc] init];
    }
    [_actionManager setContext:context];
    [_actionManager startItemActionByType:actionType];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:_commentModel.commentID.stringValue forKey:@"ext_value"];
    wrapperTrackEventWithCustomKeys(@"comment", @"digg_button", _commentModel.groupModel.groupID, nil, dic);
    if (self.delegate && [self.delegate respondsToSelector:@selector(tt_commentCell:digCommentWithCommentModel:)]) {
        [self.delegate tt_commentCell:self digCommentWithCommentModel:_commentModel];
    }
}

- (void)digButtonOnClick:(id)sender {
    if ([self isDetailComment]) {
        [self performDiggAction];
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(tt_commentCell:digCommentWithCommentModel:)]) {
        [self.delegate tt_commentCell:self digCommentWithCommentModel:self.commentModel];
    }
}

- (void)themeChanged:(NSNotification *)notification {
    [self refreshContent];

    self.timeLabel.textColor = [UIColor tt_themedColorForKey:kFHColorCoolGrey3];
    self.userInfoLabel.textColor = [UIColor tt_themedColorForKey:kColorText13];
}

#pragma mark - TTTAttributedLabel Delegate

- (void)attributedLabel:(TTUGCAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if ([url.absoluteString isEqualToString:kTTCommentContentLabelTruncationTokenURLString]) {
        wrapperTrackEvent(@"comment", @"click_allcontent");
        if (self.delegate && [self.delegate respondsToSelector:@selector(tt_commentCell:contentUnfoldWithCommentModel:)]) {
            [self.delegate tt_commentCell:self contentUnfoldWithCommentModel:self.commentModel];
        }
    } else if ([url.absoluteString isEqualToString:kTTCommentContentLabelQuotedCommentUserURLString]) {
        if (!isEmptyString(self.commentModel.quotedComment.userID)) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(tt_commentCell:tappedWithUserID:)]) {
                [self.delegate tt_commentCell:self tappedWithUserID:self.commentModel.quotedComment.userID];
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

#pragma mark - private methods

- (NSString *)trackerSource {
    if ([self isDetailComment]) {
        return @"comment";
    }

    return @"update_detail";
}

- (BOOL)isDetailComment {
    if (isEmptyString(self.commentModel.groupModel.groupID)) {
        return NO;
    }

    return YES;
}

- (NSAttributedString *)attributedTruncationToken {
    NSMutableAttributedString *truncationToken = [[NSMutableAttributedString alloc] initWithString:@"...全文" attributes:@{
        NSFontAttributeName : [TTUniversalCommentCellLiteHelper contentLabelFont],
        NSForegroundColorAttributeName : SSGetThemedColorWithKey(kColorText5),
        NSLinkAttributeName : [NSURL URLWithString:kTTCommentContentLabelTruncationTokenURLString],
    }];

    [truncationToken addAttributes:@{
        NSForegroundColorAttributeName : SSGetThemedColorWithKey(kColorText1)
    } range:NSMakeRange(0, 3)];

    return truncationToken;
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
        if (copyItem) {
            self.menuItems = menu.menuItems;
            menu.menuItems = @[copyItem, reportItem];
        }
        [menu setTargetRect:self.contentLabel.frame inView:self.contentLabel.superview];
        [menu setMenuVisible:YES animated:YES];
        [self changeContentLabelBackgroundColor];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideMenu) name:UIMenuControllerWillHideMenuNotification object:nil];
        wrapperTrackEvent([self trackerSource], [self isDetailComment]? @"longpress" : @"replier_longpress");
    }
}

- (void)willHideMenu {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
    [self resetContentLabelBackgroundColor];

    UIMenuController *menu = [UIMenuController sharedMenuController];
    menu.menuItems = self.menuItems;
}

- (BOOL)canPerformAction:(SEL)action withSender:(__unused id)sender {
    if (action == @selector(customCopy:) ||
        action == @selector(reportComment:)) {
        return YES;
    }
    return [super canPerformAction:action withSender:sender];
}

- (void)customCopy:(__unused id)sender {
    [[UIPasteboard generalPasteboard] setString:self.layout.contentLayout.richSpanText.text];
    wrapperTrackEvent([self trackerSource], [self isDetailComment]? @"longpress_copy" : @"replier_longpress_copy");
}

- (void)reportComment:(__unused id)sender {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:self.commentModel.commentID.stringValue forKey:@"comment_id"];
    [params setValue:self.commentModel.userID.stringValue forKey:@"user_id"];
    wrapperTrackEvent([self trackerSource], [self isDetailComment]? @"longpress_report" : @"replier_longpress_report");
    
    self.actionSheetController = [[TTActionSheetController alloc] init];
    
    [self.actionSheetController insertReportArray:[TTReportManager fetchReportUserOptions]];
    WeakSelf;
    [self.actionSheetController performWithSource:TTActionSheetSourceTypeUser completion:^(NSDictionary * _Nonnull parameters) {
        StrongSelf;
        if (parameters[@"report"]) {
            TTReportUserModel *model = [[TTReportUserModel alloc] init];
            model.userID = self.commentModel.userID.stringValue;
            model.commentID = self.commentModel.commentID.stringValue;
            model.groupID = self.commentModel.groupModel.groupID;
            [[TTReportManager shareInstance] startReportUserWithType:parameters[@"report"] inputText:parameters[@"criticism"] message:nil source:@(TTReportSourceComment).stringValue userModel:model animated:YES];
        }
    }];
    
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

- (TTAsyncCornerImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[TTAsyncCornerImageView alloc] initWithFrame:CGRectMake([TTUniversalCommentCellLiteHelper cellHorizontalPadding], [TTUniversalCommentCellLiteHelper cellVerticalPadding], [TTUniversalCommentCellLiteHelper avatarSize], [TTUniversalCommentCellLiteHelper avatarSize]) allowCorner:YES];
        _avatarView.cornerRadius = [TTUniversalCommentCellLiteHelper avatarSize] / 2;
        _avatarView.placeholderName = @"big_defaulthead_head";
        _avatarView.borderWidth = 0;
        _avatarView.borderColor = [UIColor clearColor];
        _avatarView.coverColor = [[UIColor blackColor] colorWithAlphaComponent:0.05];
        [_avatarView setupVerifyViewForLength:[TTUniversalCommentCellLiteHelper avatarNormalSize] adaptationSizeBlock:^CGSize(CGSize standardSize) {
            return [TTUniversalCommentCellLiteHelper verifyLogoSize:standardSize];
        }];
        // add by zjing 去掉头像点击
//        [_avatarView addTouchTarget:self action:@selector(avatarViewOnClick:)];
    }
    return _avatarView;
}

- (TTUserInfoView *)nameView {
    if (!_nameView) {
        CGFloat maxWidth = self.width - [TTUniversalCommentCellLiteHelper cellHorizontalPadding] - [TTUniversalCommentCellLiteHelper avatarSize] - [TTUniversalCommentCellLiteHelper avatarRightPadding] - [TTUniversalCommentCellLiteHelper cellRightPadding] - 30.f - [TTUniversalCommentCellLiteHelper nameViewRightPadding];
        _nameView = [[TTUserInfoView alloc] initWithBaselineOrigin:CGPointMake(0, 0) maxWidth:maxWidth limitHeight:[UIFont systemFontOfSize:[TTUniversalCommentCellLiteHelper nameViewFontSize]].lineHeight title:nil fontSize:[TTUniversalCommentCellLiteHelper nameViewFontSize] verifiedInfo:nil verified:NO owner:NO appendLogoInfoArray:nil];
        _nameView.frame = CGRectMake(self.avatarView.right + [TTUniversalCommentCellLiteHelper avatarRightPadding], [TTUniversalCommentCellLiteHelper cellVerticalPadding], maxWidth, [TTDeviceUIUtils tt_newPadding:20.f]);
        _nameView.titleLabel.textColor = [UIColor tt_themedColorForKey:kFHColorDarkIndigo];
        WeakSelf;
        __weak typeof(_nameView) weakNameView = _nameView;
        [_nameView clickTitleWithAction:^(NSString *title) {
            StrongSelf;
            __strong typeof(weakNameView) strongNameView = weakNameView;
            [self nameViewOnClick:strongNameView];
        }];
    }
    return _nameView;
}

- (TTDiggButton *)digButton {
    if (!_digButton) {
        _digButton = [TTDiggButton diggButtonWithStyleType:TTDiggButtonStyleTypeCommentOnly];

        [_digButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 2, 0)];
        [_digButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 6, 0, 0)];
         _digButton.frame = CGRectMake(self.nameView.right, [TTUniversalCommentCellLiteHelper cellVerticalPadding], [TTDeviceUIUtils tt_newPadding:90], [TTDeviceUIUtils tt_newPadding:16]);
        _digButton.hitTestEdgeInsets = kTTCommentCellDigButtonHitTestInsets;
        if ([TTDeviceHelper OSVersionNumber] >= 8.f && UIAccessibilityIsBoldTextEnabled()) {
            [_digButton setImageEdgeInsets:UIEdgeInsetsMake(0, -1, 2, 6)];
        }
        WeakSelf;
        [_digButton setClickedBlock:^(TTDiggButtonClickType type) {
            StrongSelf;
            [self digButtonOnClick:nil];
        }];
    
    }
    return _digButton;
}

- (TTAsyncLabel *)userInfoLabel {
    if (!_userInfoLabel) {
        _userInfoLabel = [[TTAsyncLabel alloc] init];
        _userInfoLabel.frame = CGRectMake(self.nameView.left, self.nameView.bottom, self.width - [TTUniversalCommentCellLiteHelper cellHorizontalPadding] - [TTUniversalCommentCellLiteHelper avatarSize] - [TTUniversalCommentCellLiteHelper avatarRightPadding], [TTDeviceUIUtils tt_newPadding:16.5f]);
        _userInfoLabel.font = [TTUniversalCommentCellLiteHelper userInfoLabelFont];
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
        _timeLabel.frame = CGRectMake(self.nameView.left, self.contentLabel.bottom, self.width - [TTUniversalCommentCellLiteHelper cellHorizontalPadding] - [TTUniversalCommentCellLiteHelper avatarSize] - [TTUniversalCommentCellLiteHelper avatarRightPadding], [TTDeviceUIUtils tt_newPadding:16.5f]);
        _timeLabel.font = [TTUniversalCommentCellLiteHelper timeLabelFont];
        _timeLabel.textColor = [UIColor tt_themedColorForKey:kFHColorCoolGrey3];
        _timeLabel.numberOfLines = 1;
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.layer.backgroundColor = [UIColor clearColor].CGColor;
    }
    return _timeLabel;
}

- (TTUGCAttributedLabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[TTUGCAttributedLabel alloc] initWithFrame:CGRectMake(self.nameView.left, self.timeLabel.bottom + [TTUniversalCommentCellLiteHelper contentLabelPadding], 0, 0)];
        _contentLabel.font = [TTCommentUIHelper tt_fontOfSize:[TTUniversalCommentCellLiteHelper contentLabelFont].pointSize]; // 采用苹方字体能正确居中对齐...
        _contentLabel.textColor = SSGetThemedColorWithKey(kFHColorCoolGrey3);
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.layer.backgroundColor = [UIColor clearColor].CGColor;
        _contentLabel.attributedTruncationToken = [self attributedTruncationToken];
        _contentLabel.delegate = self;

        _contentLabel.longPressGestureRecognizer.enabled = NO;
        [_contentLabel addGestureRecognizer:({
            [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        })];
    }
    return _contentLabel;
}

- (TTAlphaThemedButton *)replyButton {
    if (!_replyButton) {
        _replyButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _replyButton.titleLabel.font = [TTUniversalCommentCellLiteHelper timeLabelFont];
        _replyButton.frame = CGRectMake(self.nameView.left, 0, 0, [TTDeviceUIUtils tt_newPadding:24]);
        _replyButton.titleLabel.numberOfLines = 1;
        _replyButton.hitTestEdgeInsets = UIEdgeInsetsMake(-13, -8, -13, -8);
        _replyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_replyButton addTarget:self action:@selector(replyButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];
        _replyButton.hidden = YES;
        _replyButton.layer.cornerRadius = _replyButton.height / 2.f;
        _replyButton.layer.masksToBounds = YES;
        _replyButton.backgroundColorThemeKey = kColorBackground3;
        _replyButton.titleColorThemeKey = kColorText1;
        _replyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    }
    return _replyButton;
}

- (SSThemedButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.backgroundColor = [UIColor clearColor];
        _deleteButton.titleLabel.font = [TTUniversalCommentCellLiteHelper deleteButtonFont];
        _deleteButton.titleColorThemeKey = kColorText1;
        [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        _deleteButton.hidden = YES;
        _deleteButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_deleteButton addTarget:self action:@selector(deleteButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];
        _deleteButton.hitTestEdgeInsets = UIEdgeInsetsMake(-13, -8, -13, -8);
        _deleteButton.height = [TTUniversalCommentCellLiteHelper deleteButtonFont].lineHeight;
    }
    return _deleteButton;
}

- (TTCommentReplyListView *)replyListView {
    if (!_replyListView) {
        CGFloat width = self.width - [TTUniversalCommentCellLiteHelper cellHorizontalPadding] - [TTUniversalCommentCellLiteHelper cellRightPadding] - [TTUniversalCommentCellLiteHelper avatarSize] - [TTUniversalCommentCellLiteHelper avatarRightPadding];
        _replyListView = [[TTCommentReplyListView alloc] initWithWidth:width toComment:_commentModel];
        WeakSelf;
        [_replyListView didClickReplyToMakeAction:^(TTCommentReplyModel *replyModel) {
            StrongSelf;
            if ([self.delegate respondsToSelector:@selector(tt_commentCell:replyListClickedWithModel:)]) {
                [self.delegate tt_commentCell:self
                    replyListClickedWithModel:self.commentModel];
            }
        }];
        [_replyListView didClickReplyToViewUser:^(TTCommentReplyModel *replyModel) {
            StrongSelf;
            //定位到profile或moment详情页
            if (!isEmptyString(replyModel.userID)) {
                if ([self.delegate respondsToSelector:@selector(tt_commentCell:replyListAvatarClickedWithUserID:commentModel:)]) {
                    [self.delegate tt_commentCell:self replyListAvatarClickedWithUserID:replyModel.userID commentModel:self.commentModel];
                }
            }
            else {
                if ([self.delegate respondsToSelector:@selector(tt_commentCell:replyListClickedWithModel:)]) {
                    wrapperTrackEvent(@"comment", @"enter_detail_comment");
                    [self.delegate tt_commentCell:wself replyListClickedWithModel:wself.commentModel];
                }
            }
        }];
    }
    return _replyListView;
}

@end
